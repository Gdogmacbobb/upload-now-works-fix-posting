import { Router, Response } from 'express';
import { authenticateToken, AuthRequest } from '../middleware/auth';
import { db } from '../db';
import { follows, videoInteractions, userProfiles, videos } from '../shared/schema';
import { eq, and, desc, sql } from 'drizzle-orm';

const router = Router();

router.post('/follow/:userId', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const { userId } = req.params;

    if (userId === req.user!.userId) {
      return res.status(400).json({ error: 'Cannot follow yourself' });
    }

    const existing = await db
      .select()
      .from(follows)
      .where(and(eq(follows.followerId, req.user!.userId), eq(follows.followingId, userId)))
      .limit(1);

    if (existing.length > 0) {
      return res.status(400).json({ error: 'Already following' });
    }

    await db.transaction(async (tx) => {
      await tx.insert(follows).values({
        followerId: req.user!.userId,
        followingId: userId,
      });

      await tx
        .update(userProfiles)
        .set({ followingCount: sql`${userProfiles.followingCount} + 1` })
        .where(eq(userProfiles.id, req.user!.userId));

      await tx
        .update(userProfiles)
        .set({ followerCount: sql`${userProfiles.followerCount} + 1` })
        .where(eq(userProfiles.id, userId));
    });

    res.json({ success: true });
  } catch (error) {
    console.error('[SOCIAL] Error following user:', error);
    res.status(500).json({ error: 'Failed to follow user' });
  }
});

router.delete('/follow/:userId', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const { userId } = req.params;

    await db.transaction(async (tx) => {
      const result = await tx
        .delete(follows)
        .where(and(eq(follows.followerId, req.user!.userId), eq(follows.followingId, userId)))
        .returning();

      if (result.length === 0) {
        throw new Error('Not following this user');
      }

      await tx
        .update(userProfiles)
        .set({ followingCount: sql`GREATEST(${userProfiles.followingCount} - 1, 0)` })
        .where(eq(userProfiles.id, req.user!.userId));

      await tx
        .update(userProfiles)
        .set({ followerCount: sql`GREATEST(${userProfiles.followerCount} - 1, 0)` })
        .where(eq(userProfiles.id, userId));
    });

    res.json({ success: true });
  } catch (error: any) {
    console.error('[SOCIAL] Error unfollowing user:', error);
    if (error.message === 'Not following this user') {
      return res.status(404).json({ error: error.message });
    }
    res.status(500).json({ error: 'Failed to unfollow user' });
  }
});

router.get('/followers/:userId', async (req, res: Response) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit as string) || 20;
    const offset = parseInt(req.query.offset as string) || 0;

    const followers = await db
      .select({
        id: userProfiles.id,
        username: userProfiles.username,
        fullName: userProfiles.fullName,
        profileImageUrl: userProfiles.profileImageUrl,
        verificationStatus: userProfiles.verificationStatus,
      })
      .from(follows)
      .innerJoin(userProfiles, eq(follows.followerId, userProfiles.id))
      .where(eq(follows.followingId, userId))
      .orderBy(desc(follows.createdAt))
      .limit(limit)
      .offset(offset);

    res.json({ followers });
  } catch (error) {
    console.error('[SOCIAL] Error fetching followers:', error);
    res.status(500).json({ error: 'Failed to fetch followers' });
  }
});

router.get('/following/:userId', async (req, res: Response) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit as string) || 20;
    const offset = parseInt(req.query.offset as string) || 0;

    const following = await db
      .select({
        id: userProfiles.id,
        username: userProfiles.username,
        fullName: userProfiles.fullName,
        profileImageUrl: userProfiles.profileImageUrl,
        verificationStatus: userProfiles.verificationStatus,
      })
      .from(follows)
      .innerJoin(userProfiles, eq(follows.followingId, userProfiles.id))
      .where(eq(follows.followerId, userId))
      .orderBy(desc(follows.createdAt))
      .limit(limit)
      .offset(offset);

    res.json({ following });
  } catch (error) {
    console.error('[SOCIAL] Error fetching following:', error);
    res.status(500).json({ error: 'Failed to fetch following' });
  }
});

router.get('/follow-status/:userId', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const { userId } = req.params;

    const [follow] = await db
      .select()
      .from(follows)
      .where(and(
        eq(follows.followerId, req.user!.userId),
        eq(follows.followingId, userId)
      ))
      .limit(1);

    res.json({ isFollowing: !!follow });
  } catch (error) {
    console.error('[SOCIAL] Error checking follow status:', error);
    res.status(500).json({ error: 'Failed to check follow status' });
  }
});

router.post('/interact/:videoId', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const { videoId } = req.params;
    const { type } = req.body;

    if (!['like', 'save', 'view'].includes(type)) {
      return res.status(400).json({ error: 'Invalid interaction type' });
    }

    const existing = await db
      .select()
      .from(videoInteractions)
      .where(
        and(
          eq(videoInteractions.userId, req.user!.userId),
          eq(videoInteractions.videoId, videoId),
          eq(videoInteractions.interactionType, type)
        )
      )
      .limit(1);

    if (existing.length > 0) {
      return res.status(400).json({ error: 'Already interacted' });
    }

    await db.transaction(async (tx) => {
      await tx.insert(videoInteractions).values({
        userId: req.user!.userId,
        videoId,
        interactionType: type,
      });

      if (type === 'like') {
        await tx
          .update(videos)
          .set({ likeCount: sql`${videos.likeCount} + 1` })
          .where(eq(videos.id, videoId));
      } else if (type === 'view') {
        await tx
          .update(videos)
          .set({ viewCount: sql`${videos.viewCount} + 1` })
          .where(eq(videos.id, videoId));
      }
    });

    res.json({ success: true });
  } catch (error) {
    console.error('[SOCIAL] Error creating interaction:', error);
    res.status(500).json({ error: 'Failed to create interaction' });
  }
});

router.delete('/interact/:videoId/:type', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const { videoId, type } = req.params;

    await db.transaction(async (tx) => {
      const result = await tx
        .delete(videoInteractions)
        .where(
          and(
            eq(videoInteractions.userId, req.user!.userId),
            eq(videoInteractions.videoId, videoId),
            eq(videoInteractions.interactionType, type)
          )
        )
        .returning();

      if (result.length === 0) {
        throw new Error('Interaction not found');
      }

      if (type === 'like') {
        await tx
          .update(videos)
          .set({ likeCount: sql`GREATEST(${videos.likeCount} - 1, 0)` })
          .where(eq(videos.id, videoId));
      }
    });

    res.json({ success: true });
  } catch (error: any) {
    console.error('[SOCIAL] Error removing interaction:', error);
    if (error.message === 'Interaction not found') {
      return res.status(404).json({ error: error.message });
    }
    res.status(500).json({ error: 'Failed to remove interaction' });
  }
});

export default router;
