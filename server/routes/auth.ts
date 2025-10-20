import { Router, Request, Response } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { db } from '../db';
import { userProfiles } from '../shared/schema';
import { eq, or } from 'drizzle-orm';

const router = Router();

const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-change-in-production';
const JWT_EXPIRES_IN = '7d';

interface RegisterRequest {
  email: string;
  password: string;
  username: string;
  full_name: string;
  role: 'street_performer' | 'new_yorker';
  performance_types?: string[];
}

interface LoginRequest {
  email: string;
  password: string;
}

router.post('/register', async (req: Request, res: Response) => {
  try {
    const { email, password, username, full_name, role, performance_types }: RegisterRequest = req.body;

    if (!email || !password || !username || !full_name || !role) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    if (password.length < 8) {
      return res.status(400).json({ error: 'Password must be at least 8 characters' });
    }

    const existingUser = await db
      .select()
      .from(userProfiles)
      .where(or(eq(userProfiles.email, email), eq(userProfiles.username, username)))
      .limit(1);

    if (existingUser.length > 0) {
      if (existingUser[0].email === email) {
        return res.status(400).json({ error: 'Email already registered' });
      }
      return res.status(400).json({ error: 'Username already taken' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const [newUser] = await db
      .insert(userProfiles)
      .values({
        email,
        passwordHash: hashedPassword,
        username,
        fullName: full_name,
        role,
        performanceTypes: performance_types || [],
        verificationStatus: 'pending',
        isSuspended: false,
        totalDonationsReceived: '0',
        totalDonationsGiven: '0',
        followerCount: 0,
        followingCount: 0,
        videoCount: 0,
      })
      .returning();

    const token = jwt.sign(
      { 
        userId: newUser.id, 
        email: newUser.email, 
        role: newUser.role 
      },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    res.json({
      user: {
        id: newUser.id,
        email: newUser.email,
        username: newUser.username,
        full_name: newUser.fullName,
        role: newUser.role,
        performance_types: newUser.performanceTypes,
        avatar_url: newUser.profileImageUrl,
        verification_status: newUser.verificationStatus,
      },
      token,
    });
  } catch (error) {
    console.error('[AUTH] Registration error:', error);
    res.status(500).json({ error: 'Registration failed' });
  }
});

router.post('/login', async (req: Request, res: Response) => {
  try {
    const { email, password }: LoginRequest = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password required' });
    }

    const [user] = await db
      .select()
      .from(userProfiles)
      .where(eq(userProfiles.email, email))
      .limit(1);

    if (!user) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    if (user.isSuspended) {
      return res.status(403).json({ 
        error: 'Account suspended',
        suspended_until: user.suspendedUntil,
      });
    }

    const validPassword = await bcrypt.compare(password, user.passwordHash);
    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const token = jwt.sign(
      { 
        userId: user.id, 
        email: user.email, 
        role: user.role 
      },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    res.json({
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        full_name: user.fullName,
        role: user.role,
        performance_types: user.performanceTypes,
        avatar_url: user.profileImageUrl,
        bio: user.bio,
        verification_status: user.verificationStatus,
        follower_count: user.followerCount,
        following_count: user.followingCount,
      },
      token,
    });
  } catch (error) {
    console.error('[AUTH] Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

router.post('/verify', async (req: Request, res: Response) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const token = authHeader.substring(7);
    const decoded = jwt.verify(token, JWT_SECRET) as any;

    const [user] = await db
      .select()
      .from(userProfiles)
      .where(eq(userProfiles.id, decoded.userId))
      .limit(1);

    if (!user) {
      return res.status(401).json({ error: 'User not found' });
    }

    if (user.isSuspended) {
      return res.status(403).json({ 
        error: 'Account suspended',
        suspended_until: user.suspendedUntil,
      });
    }

    res.json({
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        full_name: user.fullName,
        role: user.role,
        performance_types: user.performanceTypes,
        avatar_url: user.profileImageUrl,
        bio: user.bio,
        verification_status: user.verificationStatus,
        follower_count: user.followerCount,
        following_count: user.followingCount,
      },
    });
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      return res.status(401).json({ error: 'Invalid token' });
    }
    console.error('[AUTH] Verify error:', error);
    res.status(500).json({ error: 'Verification failed' });
  }
});

router.get('/check-username/:username', async (req: Request, res: Response) => {
  try {
    const { username } = req.params;

    const [existing] = await db
      .select()
      .from(userProfiles)
      .where(eq(userProfiles.username, username))
      .limit(1);

    res.json({ available: !existing });
  } catch (error) {
    console.error('[AUTH] Check username error:', error);
    res.status(500).json({ error: 'Check failed' });
  }
});

export default router;
