# Overview
YNFNY is a cross-platform Flutter mobile application designed as a social platform for street performers. It integrates multiple AI services, Supabase for backend services, and Stripe for payment processing. The project aims to provide a robust and engaging platform for street artists to connect with their audience and monetize their performances, supporting both mobile and web deployment. The application features a production-ready video preview with TikTok-style chrome and synchronized audio replay, optimized for deployment.

# User Preferences
Preferred communication style: Simple, everyday language.

# System Architecture

## Frontend Architecture
The application uses Flutter for a single codebase across mobile and web. Key features include:
- **Environment Configuration**: Secure management of environment variables via `env.json` and `--dart-define-from-file`.
- **Video Recording & Upload**: TikTok/Reels-style UI for vertical video recording and a modernized upload screen, optimized for quality and cross-platform compatibility, including full-screen preview, portrait lock, maximum resolution, responsive controls, and pinch-to-zoom.
- **Video Preview with Audio Replay**: Production-ready video preview with manual replay system that fully reinitializes the VideoPlayerController on each replay to ensure synchronized audio/video playback. Uses controller disposal and recreation instead of seekTo() to restore complete audio context. HtmlElementView fallback uses video.load() to force browser media stream reload.
- **Interactive Video Scrubber**: Full-width edge-to-edge progress timeline with iPhone Photos/Reels-style scrubber positioned 12px below location text. Features 3px orange track (#FF8C00), draggable thumb for precise seeking with sub-second accuracy, dual-path support (VideoPlayer + HtmlElementView), and automatic playback resumption after seeking to maintain audio sync. Uses Transform.translate to achieve full device width while flowing naturally below overlay content.
- **Unified Thumbnail-Preview Button**: Interactive preview element that merges thumbnail display and video preview into a single tappable component. Features 85% width centered container with fixed 4:5 (0.8) aspect ratio, displaying the current video frame (paused at selected timestamp) with centered play icon overlay (56px, semi-transparent) and duration badge. Automatically shows first frame (Duration.zero) as default thumbnail on upload screen load using silent play-pause technique: mute controller, play 300ms to force texture rendering (critical for web), pause at frame, restore volume. Automatically detects video orientation and applies 90° clockwise rotation for landscape videos to display them upright in portrait mode. Uses PointerInterceptor for web compatibility to capture tap events above HtmlElementView platform views. Tapping opens full-screen TikTok-style preview with synchronized audio replay.
- **Thumbnail Selection with Real-Time Preview**: Thumbnail selection UI appears below the unified preview when "Select Thumbnail" is clicked. Features a scrubber bar that seeks the main VideoPlayerController in real-time, with instant preview updates via 100ms silent play-pause technique on each scrub position change. Confirmation button saves the selected timestamp (in milliseconds) to `_selectedThumbnailFramePosition` for database persistence. Single controller architecture eliminates duplicate containers and ensures consistent orientation handling. Database field `thumbnail_frame_time` added to `videos` table for persistence.
- **Null Safety**: Extensive use of nullable types, FutureBuilder patterns, and `mounted` checks for robust camera/video controller management.
- **UI/UX**: Focus on a polished, intuitive user experience, especially for video recording interactions.
- **Cross-Platform Development**: Single codebase with platform-specific adaptations where necessary.

## Backend Architecture
A serverless approach using external services:
- **Supabase Integration**: Primary BaaS for authentication, database, and real-time features.
- **Serverless Functions**: Deno-based edge functions for business logic and payment processing.

## Data Storage Solutions
- **Secure PostgreSQL**: Database with Row-Level Security (RLS) and role-based access, optimized with indexes.
- **Real-time Capabilities**: Supabase real-time subscriptions.
- **File Storage**: Supabase storage for media with role-based access controls.

## Authentication and Authorization
- **Supabase Auth**: Manages user registration, login, and sessions.
- **Registration Flow**: Email/password signup with profile creation, username availability checks, and performance type selection for artists.
- **Profile Persistence**: User data stored in `user_profiles`, including role-specific fields.
- **JWT Tokens**: Secure authentication.
- **Enterprise Security Architecture**: Two-layer security with UI controls and database enforcement (RLS).
- **RoleGate Widget System**: Production-ready role enforcement for UI elements and page access.
- **Profile Management**: Full profile editing for all user roles.

## System Design Choices
- **Scalability**: Designed with serverless functions and managed services.

# External Dependencies

## Third-party Services
- **AI Services**: OpenAI API, Google Gemini API, Anthropic API, Perplexity API.
- **Payment Processing**: Stripe.
- **Backend Services**: Supabase.

## Development Tools
- **Flutter Framework**: Version 3.32.0 with Dart SDK 3.8.0.
- **Build Tools**: Automated build system via `build_web.sh` with `--no-tree-shake-icons` flag to preserve Material icons.
- **Package Management**: Flutter Pub for Dart packages and NPM for Node.js.
- **Web Server**: Node.js Express server (`server.js`) for serving static Flutter web builds.
- **Material Icons**: Configured with `uses-material-design: true` in pubspec.yaml to bundle MaterialIcons font for web deployment.

## Infrastructure
- **Web Hosting**: Static web deployment with CanvasKit rendering.
- **Environment Management**: JSON-based configuration.
- **Deployment**: Configured for Replit autoscale deployment.