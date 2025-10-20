import { Router, Response } from 'express';
import { authenticateToken, AuthRequest } from '../middleware/auth';
import { db } from '../db';
import { userProfiles, videos, follows } from '../shared/schema';
import { eq, or, like, sql, and } from 'drizzle-orm';
import { ObjectStorageService } from '../objectStorage';
import multer from 'multer';

const router = Router();
const objectStorage = new ObjectStorageService();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 5 * 1024 * 1024 } });

router.get('/me', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const [profile] = await db
      .select()
      .from(userProfiles)
      .where(eq(userProfiles.id, req.user!.userId))
      .limit(1);

    if (!profile) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    res.json({
      profile: {
        id: profile.id,
        email: profile.email,
        username: profile.username,
        full_name: profile.fullName,
        role: profile.role,
        avatar_url: profile.profileImageUrl,
        bio: profile.bio,
        performance_types: profile.performanceTypes,
        verification_status: profile.verificationStatus,
        follower_count: profile.followerCount,
        following_count: profile.followingCount,
        video_count: profile.videoCount,
      },
    });
  } catch (error) {
    console.error('[PROFILE] Error fetching profile:', error);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

router.get('/username/:username', async (req, res: Response) => {
  try {
    const { username } = req.params;

    const [profile] = await db
      .select()
      .from(userProfiles)
      .where(eq(userProfiles.username, username))
      .limit(1);

    if (!profile) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    res.json({
      profile: {
        id: profile.id,
        username: profile.username,
        full_name: profile.fullName,
        role: profile.role,
        avatar_url: profile.profileImageUrl,
        bio: profile.bio,
        performance_types: profile.performanceTypes,
        verification_status: profile.verificationStatus,
        follower_count: profile.followerCount,
        following_count: profile.followingCount,
        video_count: profile.videoCount,
      },
    });
  } catch (error) {
    console.error('[PROFILE] Error fetching profile:', error);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

router.put('/me', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const { full_name, bio, avatar_url, performance_types } = req.body;

    const [updated] = await db
      .update(userProfiles)
      .set({
        fullName: full_name,
        bio: bio || null,
        profileImageUrl: avatar_url || null,
        performanceTypes: performance_types || [],
      })
      .where(eq(userProfiles.id, req.user!.userId))
      .returning();

    res.json({
      profile: {
        id: updated.id,
        username: updated.username,
        full_name: updated.fullName,
        bio: updated.bio,
        avatar_url: updated.profileImageUrl,
        performance_types: updated.performanceTypes,
      },
    });
  } catch (error) {
    console.error('[PROFILE] Error updating profile:', error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

router.get('/search', async (req, res: Response) => {
  try {
    const query = req.query.q as string;
    if (!query) {
      return res.status(400).json({ error: 'Query parameter required' });
    }

    const profiles = await db
      .select()
      .from(userProfiles)
      .where(
        or(
          like(userProfiles.username, `%${query}%`),
          like(userProfiles.fullName, `%${query}%`)
        )
      )
      .limit(20);

    res.json({
      profiles: profiles.map((p) => ({
        id: p.id,
        username: p.username,
        full_name: p.fullName,
        avatar_url: p.profileImageUrl,
        role: p.role,
        verification_status: p.verificationStatus,
      })),
    });
  } catch (error) {
    console.error('[PROFILE] Error searching profiles:', error);
    res.status(500).json({ error: 'Failed to search profiles' });
  }
});

router.get('/:userId', async (req, res: Response) => {
  try {
    const { userId } = req.params;

    const [profile] = await db
      .select()
      .from(userProfiles)
      .where(eq(userProfiles.id, userId))
      .limit(1);

    if (!profile) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    const [supportersResult] = await db
      .select({ count: sql<number>`count(*)::int` })
      .from(follows)
      .where(eq(follows.followingId, userId));

    const [supportingResult] = await db
      .select({ count: sql<number>`count(*)::int` })
      .from(follows)
      .where(eq(follows.followerId, userId));

    const [videosResult] = await db
      .select({ count: sql<number>`count(*)::int` })
      .from(videos)
      .where(and(
        eq(videos.performerId, userId),
        eq(videos.isApproved, true)
      ));

    res.json({
      profile: {
        id: profile.id,
        username: profile.username,
        full_name: profile.fullName,
        role: profile.role,
        avatar_url: profile.profileImageUrl,
        bio: profile.bio,
        performance_types: profile.performanceTypes,
        verification_status: profile.verificationStatus,
        follower_count: supportersResult?.count || 0,
        following_count: supportingResult?.count || 0,
        video_count: videosResult?.count || 0,
        total_donations_received: profile.totalDonationsReceived,
        social_media_links: profile.socialMediaLinks,
      },
    });
  } catch (error) {
    console.error('[PROFILE] Error fetching profile:', error);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

router.get('/:userId/videos', async (req, res: Response) => {
  try {
    const { userId } = req.params;

    const userVideos = await db
      .select()
      .from(videos)
      .where(and(
        eq(videos.performerId, userId),
        eq(videos.isApproved, true)
      ))
      .orderBy(sql`${videos.createdAt} DESC`);

    res.json({
      videos: userVideos.map((v) => ({
        id: v.id,
        performer_id: v.performerId,
        video_url: v.videoUrl,
        thumbnail_url: v.thumbnailUrl,
        title: v.title,
        description: v.description,
        location: v.locationName,
        borough: v.borough,
        duration: v.duration,
        is_approved: v.isApproved,
        created_at: v.createdAt,
      })),
    });
  } catch (error) {
    console.error('[PROFILE] Error fetching videos:', error);
    res.status(500).json({ error: 'Failed to fetch videos' });
  }
});

router.post('/upload-avatar', authenticateToken, upload.single('image'), async (req: AuthRequest, res: Response) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No image file provided' });
    }

    const uploadUrl = await objectStorage.getObjectEntityUploadURL();
    
    const uploadResponse = await fetch(uploadUrl, {
      method: 'PUT',
      body: req.file.buffer,
      headers: {
        'Content-Type': req.file.mimetype,
      },
    });

    if (!uploadResponse.ok) {
      throw new Error(`Upload failed: ${uploadResponse.statusText}`);
    }

    const publicUrl = uploadUrl.split('?')[0];
    const normalizedPath = objectStorage.normalizeObjectEntityPath(publicUrl);

    await db
      .update(userProfiles)
      .set({ profileImageUrl: normalizedPath })
      .where(eq(userProfiles.id, req.user!.userId));

    res.json({ avatar_url: normalizedPath });
  } catch (error) {
    console.error('[PROFILE] Error uploading avatar:', error);
    res.status(500).json({ error: 'Failed to upload avatar' });
  }
});

router.put('/social-media', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const { instagram, tiktok, youtube } = req.body;

    await db
      .update(userProfiles)
      .set({
        socialMediaLinks: {
          instagram: instagram || null,
          tiktok: tiktok || null,
          youtube: youtube || null,
        },
      })
      .where(eq(userProfiles.id, req.user!.userId));

    res.json({ success: true });
  } catch (error) {
    console.error('[PROFILE] Error updating social media:', error);
    res.status(500).json({ error: 'Failed to update social media' });
  }
});

export default router;
