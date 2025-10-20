import express, { Request, Response, NextFunction } from 'express';
import path from 'path';
import fs from 'fs';
import dotenv from 'dotenv';
import stripeRoutes from './routes/stripe';
import authRoutes from './routes/auth';
import videoRoutes from './routes/videos';
import profileRoutes from './routes/profiles';
import socialRoutes from './routes/social';

// Load environment variables
dotenv.config();

const app = express();
const PORT = 5000;

// Enable CORS for all routes
app.use((req: Request, res: Response, next: NextFunction) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, stripe-signature');
  
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

// Parse JSON and text bodies (except for stripe webhook which needs raw body)
app.use('/api/stripe/webhook', express.raw({ type: 'application/json' }));
app.use(express.json({ limit: '10mb' }));
app.use(express.text({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// /__log endpoint - capture camera preview logs
app.post('/__log', (req: Request, res: Response) => {
  try {
    let logMessage = '';
    
    if (typeof req.body === 'string') {
      logMessage = req.body;
    } else if (req.body && req.body.message) {
      logMessage = req.body.message;
    } else if (req.body) {
      logMessage = JSON.stringify(req.body);
    } else {
      logMessage = 'Empty log message';
    }
    
    console.log(`[WEB_LOG] ${new Date().toISOString()} - ${logMessage}`);
    res.status(204).send();
  } catch (error: any) {
    console.log(`[WEB_LOG_ERROR] ${new Date().toISOString()} - Failed to process log: ${error.message}`);
    res.status(204).send();
  }
});

// Handle GET requests to /__log (for URL-encoded logs)
app.get('/__log', (req: Request, res: Response) => {
  try {
    const message = req.query.m || req.query.message || 'Empty log message';
    const decodedMessage = decodeURIComponent(message as string);
    
    console.log(`[WEB_LOG] ${new Date().toISOString()} - ${decodedMessage}`);
    res.status(204).send();
  } catch (error: any) {
    console.log(`[WEB_LOG_ERROR] ${new Date().toISOString()} - Failed to process GET log: ${error.message}`);
    res.status(204).send();
  }
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/profiles', profileRoutes);
app.use('/api/videos', videoRoutes);
app.use('/api/social', socialRoutes);
app.use('/api/stripe', stripeRoutes);

// Health check endpoint
app.get('/api/health', (req: Request, res: Response) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    database: process.env.DATABASE_URL ? 'connected' : 'not configured'
  });
});

// Serve static files from build/web
const buildPath = path.join(__dirname, '..', 'build', 'web');

// Check if build directory exists
if (!fs.existsSync(buildPath)) {
  console.log(`[SERVER_ERROR] Build directory not found: ${buildPath}`);
  process.exit(1);
}

app.use(express.static(buildPath, {
  setHeaders: (res: Response, filePath: string) => {
    res.set('Cache-Control', 'no-cache, no-store, must-revalidate');
    res.set('Pragma', 'no-cache');
    res.set('Expires', '0');
  }
}));

// Specific route for root
app.get('/', (req: Request, res: Response) => {
  res.sendFile(path.join(buildPath, 'index.html'));
});

// Fallback for unmatched routes (Flutter web SPA routing)
app.use((req: Request, res: Response) => {
  res.sendFile(path.join(buildPath, 'index.html'));
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`[SERVER] YNFNY Flutter server running on http://0.0.0.0:${PORT}`);
  console.log(`[SERVER] Serving Flutter build from: ${buildPath}`);
  console.log(`[SERVER] API endpoints ready at /api/*`);
  console.log(`[SERVER] /__log endpoint ready for camera preview logs`);
  console.log(`[SERVER] CORS enabled for all origins`);
  console.log(`[SERVER] Database: ${process.env.DATABASE_URL ? 'Connected' : 'Not configured'}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('[SERVER] Received SIGTERM, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('[SERVER] Received SIGINT, shutting down gracefully');
  process.exit(0);
});
