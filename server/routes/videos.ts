import { Router, Response } from 'express';
import { ObjectStorageService, ObjectNotFoundError } from '../objectStorage';
import { authenticateToken, AuthRequest } from '../middleware/auth';
import { db } from '../db';
import { videos, videoInteractions, comments, follows, userProfiles, reposts } from '../shared/schema';
import { eq, desc, and, sql, inArray } from 'drizzle-orm';

const router = Router();

// Get object storage upload URL for videos
router.post('/upload-url', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const objectStorageService = new ObjectStorageService();
    const uploadURL = await objectStorageService.getObjectEntityUploadURL();
    res.json({ uploadURL });
  } catch (error) {
    console.error('[VIDEO] Error getting upload URL:', error);
    res.status(500).json({ error: 'Failed to get upload URL' });
  }
});

// Create a new video
router.post('/', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const {
      title,
      description,
      videoUrl,
      thumbnailUrl,
      thumbnailFrameTime,
      duration,
      locationLatitude,
      locationLongitude,
      locationName,
      borough,
      hashtags,
    } = req.body;

    if (!title || !videoUrl || !duration || !locationLatitude || !locationLongitude || !borough) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Verify NYC location (approximate boundaries)
    const minLat = 40.4774;
    const maxLat = 40.9176;
    const minLng = -74.2591;
    const maxLng = -73.7004;
    
    const lat = parseFloat(locationLatitude);
    const lng = parseFloat(locationLongitude);

    if (lat < minLat || lat > maxLat || lng < minLng || lng > maxLng) {
      return res.status(400).json({ error: 'Videos can only be uploaded from within NYC boundaries' });
    }

    const objectStorageService = new ObjectStorageService();
    const normalizedVideoUrl = objectStorageService.normalizeObjectEntityPath(videoUrl);
    const normalizedThumbnailUrl = thumbnailUrl 
      ? objectStorageService.normalizeObjectEntityPath(thumbnailUrl)
      : null;

    const [video] = await db
      .insert(videos)
      .values({
        performerId: req.user!.userId,
        title,
        description: description || null,
        videoUrl: normalizedVideoUrl,
        thumbnailUrl: normalizedThumbnailUrl,
        thumbnailFrameTime: thumbnailFrameTime || 0,
        duration,
        locationLatitude: locationLatitude.toString(),
        locationLongitude: locationLongitude.toString(),
        locationName: locationName || null,
        borough,
        hashtags: hashtags || [],
        isApproved: false,
        isFlagged: false,
        viewCount: 0,
        likeCount: 0,
        commentCount: 0,
        shareCount: 0,
        repostCount: 0,
      })
      .returning();

    // Update user's video count
    await db.execute(sql`
      UPDATE ${userProfiles}
      SET video_count = video_count + 1
      WHERE id = ${req.user!.userId}
    `);

    res.json({ video });
  } catch (error) {
    console.error('[VIDEO] Error creating video:', error);
    res.status(500).json({ error: 'Failed to create video' });
  }
});

// Get discovery feed (approved videos for all users)
router.get('/discovery', async (req, res: Response) => {
  try {
    const limit = parseInt(req.query.limit as string) || 20;
    const offset = parseInt(req.query.offset as string) || 0;

    const videoList = await db
      .select({
        id: videos.id,
        title: videos.title,
        description: videos.description,
        videoUrl: videos.videoUrl,
        thumbnailUrl: videos.thumbnailUrl,
        thumbnailFrameTime: videos.thumbnailFrameTime,
        duration: videos.duration,
        likeCount: videos.likeCount,
        commentCount: videos.commentCount,
        shareCount: videos.shareCount,
        viewCount: videos.viewCount,
        repostCount: videos.repostCount,
        locationName: videos.locationName,
        locationLatitude: videos.locationLatitude,
        locationLongitude: videos.locationLongitude,
        borough: videos.borough,
        hashtags: videos.hashtags,
        createdAt: videos.createdAt,
        performer: {
          id: userProfiles.id,
          username: userProfiles.username,
          fullName: userProfiles.fullName,
          profileImageUrl: userProfiles.profileImageUrl,
          performanceTypes: userProfiles.performanceTypes,
          isVerified: userProfiles.isVerified,
        },
      })
      .from(videos)
      .leftJoin(userProfiles, eq(videos.performerId, userProfiles.id))
      .where(and(eq(videos.isApproved, true), eq(videos.isFlagged, false)))
      .orderBy(desc(videos.createdAt))
      .limit(limit)
      .offset(offset);

    res.json({ videos: videoList });
  } catch (error) {
    console.error('[VIDEO] Error fetching discovery feed:', error);
    res.status(500).json({ error: 'Failed to fetch discovery feed' });
  }
});

// Get following feed (videos from followed performers)
router.get('/following', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const limit = parseInt(req.query.limit as string) || 20;
    const offset = parseInt(req.query.offset as string) || 0;
    const userId = req.user!.userId;

    // Get followed performer IDs
    const followedPerformers = await db
      .select({ followingId: follows.followingId })
      .from(follows)
      .where(eq(follows.followerId, userId));

    const followedIds: string[] = followedPerformers.map(f => f.followingId);

    if (followedIds.length === 0) {
      return res.json({ videos: [] });
    }

    const videoList = await db
      .select({
        id: videos.id,
        title: videos.title,
        description: videos.description,
        videoUrl: videos.videoUrl,
        thumbnailUrl: videos.thumbnailUrl,
        thumbnailFrameTime: videos.thumbnailFrameTime,
        duration: videos.duration,
        likeCount: videos.likeCount,
        commentCount: videos.commentCount,
        shareCount: videos.shareCount,
        viewCount: videos.viewCount,
        repostCount: videos.repostCount,
        locationName: videos.locationName,
        locationLatitude: videos.locationLatitude,
        locationLongitude: videos.locationLongitude,
        borough: videos.borough,
        hashtags: videos.hashtags,
        createdAt: videos.createdAt,
        performer: {
          id: userProfiles.id,
          username: userProfiles.username,
          fullName: userProfiles.fullName,
          profileImageUrl: userProfiles.profileImageUrl,
          performanceTypes: userProfiles.performanceTypes,
          isVerified: userProfiles.isVerified,
        },
      })
      .from(videos)
      .leftJoin(userProfiles, eq(videos.performerId, userProfiles.id))
      .where(and(
        eq(videos.isApproved, true),
        inArray(videos.performerId, followedIds)
      ))
      .orderBy(desc(videos.createdAt))
      .limit(limit)
      .offset(offset);

    res.json({ videos: videoList });
  } catch (error) {
    console.error('[VIDEO] Error fetching following feed:', error);
    res.status(500).json({ error: 'Failed to fetch following feed' });
  }
});

// Get performer's videos
router.get('/performer/:performerId', async (req, res: Response) => {
  try {
    const { performerId } = req.params;
    const limit = parseInt(req.query.limit as string) || 20;
    const offset = parseInt(req.query.offset as string) || 0;

    const videoList = await db
      .select()
      .from(videos)
      .where(and(
        eq(videos.performerId, performerId),
        eq(videos.isApproved, true),
        eq(videos.isFlagged, false)
      ))
      .orderBy(desc(videos.createdAt))
      .limit(limit)
      .offset(offset);

    res.json({ videos: videoList });
  } catch (error) {
    console.error('[VIDEO] Error fetching performer videos:', error);
    res.status(500).json({ error: 'Failed to fetch performer videos' });
  }
});

// Get specific video by ID
router.get('/:id', async (req, res: Response) => {
  try {
    const { id } = req.params;

    const [video] = await db
      .select()
      .from(videos)
      .where(eq(videos.id, id))
      .limit(1);

    if (!video) {
      return res.status(404).json({ error: 'Video not found' });
    }

    res.json({ video });
  } catch (error) {
    console.error('[VIDEO] Error fetching video:', error);
    res.status(500).json({ error: 'Failed to fetch video' });
  }
});

// Toggle video like
router.post('/:videoId/like', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const { videoId } = req.params;
    const userId = req.user!.userId;

    // Check if already liked
    const [existingLike] = await db
      .select()
      .from(videoInteractions)
      .where(and(
        eq(videoInteractions.userId, userId),
        eq(videoInteractions.videoId, videoId),
        eq(videoInteractions.interactionType, 'like')
      ))
      .limit(1);

    if (existingLike) {
      // Unlike - remove interaction
      await db
        .delete(videoInteractions)
        .where(and(
          eq(videoInteractions.userId, userId),
          eq(videoInteractions.videoId, videoId),
          eq(videoInteractions.interactionType, 'like')
        ));

      // Decrement like count
      await db.execute(sql`
        UPDATE ${videos}
        SET like_count = GREATEST(like_count - 1, 0)
        WHERE id = ${videoId}
      `);

      res.json({ liked: false });
    } else {
      // Like - add interaction
      await db.insert(videoInteractions).values({
        userId,
        videoId,
        interactionType: 'like',
      });

      // Increment like count
      await db.execute(sql`
        UPDATE ${videos}
        SET like_count = like_count + 1
        WHERE id = ${videoId}
      `);

      res.json({ liked: true });
    }
  } catch (error) {
    console.error('[VIDEO] Error toggling like:', error);
    res.status(500).json({ error: 'Failed to toggle like' });
  }
});

// Record video view
router.post('/:videoId/view', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const { videoId } = req.params;
    const userId = req.user!.userId;

    // Check if already viewed
    const [existingView] = await db
      .select()
      .from(videoInteractions)
      .where(and(
        eq(videoInteractions.userId, userId),
        eq(videoInteractions.videoId, videoId),
        eq(videoInteractions.interactionType, 'view')
      ))
      .limit(1);

    if (!existingView) {
      // Record view
      await db.insert(videoInteractions).values({
        userId,
        videoId,
        interactionType: 'view',
      });

      // Increment view count
      await db.execute(sql`
        UPDATE ${videos}
        SET view_count = view_count + 1
        WHERE id = ${videoId}
      `);
    }

    res.json({ success: true });
  } catch (error) {
    console.error('[VIDEO] Error recording view:', error);
    res.status(500).json({ error: 'Failed to record view' });
  }
});

// Add comment to video
router.post('/:videoId/comments', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const { videoId } = req.params;
    const { content } = req.body;
    const userId = req.user!.userId;

    if (!content || content.trim().length === 0) {
      return res.status(400).json({ error: 'Comment content is required' });
    }

    const commentResult = await db
      .insert(comments)
      .values({
        videoId,
        userId,
        content: content.trim(),
      })
      .returning();

    const comment = (commentResult as any[])[0];

    // Increment comment count
    await db.execute(sql`
      UPDATE ${videos}
      SET comment_count = comment_count + 1
      WHERE id = ${videoId}
    `);

    // Fetch user details for the comment
    const userResult = await db
      .select({
        username: userProfiles.username,
        fullName: userProfiles.fullName,
        profileImageUrl: userProfiles.profileImageUrl,
      })
      .from(userProfiles)
      .where(eq(userProfiles.id, userId))
      .limit(1);

    const user = userResult[0];

    res.json({
      comment: {
        ...comment,
        user,
      },
    });
  } catch (error) {
    console.error('[VIDEO] Error adding comment:', error);
    res.status(500).json({ error: 'Failed to add comment' });
  }
});

// Get video comments
router.get('/:videoId/comments', async (req, res: Response) => {
  try {
    const { videoId } = req.params;
    const limit = parseInt(req.query.limit as string) || 50;
    const offset = parseInt(req.query.offset as string) || 0;

    const commentList = await db
      .select({
        id: comments.id,
        videoId: comments.videoId,
        content: comments.content,
        createdAt: comments.createdAt,
        user: {
          username: userProfiles.username,
          fullName: userProfiles.fullName,
          profileImageUrl: userProfiles.profileImageUrl,
        },
      })
      .from(comments)
      .leftJoin(userProfiles, eq(comments.userId, userProfiles.id))
      .where(and(
        eq(comments.videoId, videoId),
        eq(comments.isFlagged, false)
      ))
      .orderBy(desc(comments.createdAt))
      .limit(limit)
      .offset(offset);

    res.json({ comments: commentList });
  } catch (error) {
    console.error('[VIDEO] Error fetching comments:', error);
    res.status(500).json({ error: 'Failed to fetch comments' });
  }
});

// Repost video
router.post('/:videoId/repost', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const { videoId } = req.params;
    const { repostText } = req.body;
    const userId = req.user!.userId;

    // Check if already reposted
    const [existingRepost] = await db
      .select()
      .from(reposts)
      .where(and(
        eq(reposts.reposterId, userId),
        eq(reposts.videoId, videoId)
      ))
      .limit(1);

    if (existingRepost) {
      return res.status(400).json({ error: 'Already reposted this video' });
    }

    const [repost] = await db
      .insert(reposts)
      .values({
        reposterId: userId,
        videoId,
        repostText: repostText || null,
      })
      .returning();

    // Increment repost count
    await db.execute(sql`
      UPDATE ${videos}
      SET repost_count = repost_count + 1
      WHERE id = ${videoId}
    `);

    res.json({ repost });
  } catch (error) {
    console.error('[VIDEO] Error reposting video:', error);
    res.status(500).json({ error: 'Failed to repost video' });
  }
});

// Get user's reposts
router.get('/reposts/:userId', async (req, res: Response) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit as string) || 20;
    const offset = parseInt(req.query.offset as string) || 0;

    const repostList = await db
      .select({
        id: reposts.id,
        repostText: reposts.repostText,
        createdAt: reposts.createdAt,
        video: {
          id: videos.id,
          title: videos.title,
          description: videos.description,
          videoUrl: videos.videoUrl,
          thumbnailUrl: videos.thumbnailUrl,
          duration: videos.duration,
          likeCount: videos.likeCount,
          commentCount: videos.commentCount,
          viewCount: videos.viewCount,
          locationName: videos.locationName,
          borough: videos.borough,
        },
      })
      .from(reposts)
      .leftJoin(videos, eq(reposts.videoId, videos.id))
      .where(eq(reposts.reposterId, userId))
      .orderBy(desc(reposts.createdAt))
      .limit(limit)
      .offset(offset);

    res.json({ reposts: repostList });
  } catch (error) {
    console.error('[VIDEO] Error fetching reposts:', error);
    res.status(500).json({ error: 'Failed to fetch reposts' });
  }
});

// Check if user liked a video
router.get('/:videoId/liked', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const { videoId } = req.params;
    const userId = req.user!.userId;

    const [like] = await db
      .select()
      .from(videoInteractions)
      .where(and(
        eq(videoInteractions.userId, userId),
        eq(videoInteractions.videoId, videoId),
        eq(videoInteractions.interactionType, 'like')
      ))
      .limit(1);

    res.json({ liked: !!like });
  } catch (error) {
    console.error('[VIDEO] Error checking like status:', error);
    res.status(500).json({ error: 'Failed to check like status' });
  }
});

export default router;
