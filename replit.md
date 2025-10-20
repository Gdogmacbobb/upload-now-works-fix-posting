# Overview
YNFNY is a cross-platform Flutter mobile application designed as a social platform for street performers. It integrates multiple AI services, Supabase for backend services, and Stripe for payment processing. The project aims to provide a robust and engaging platform for street artists to connect with their audience and monetize their performances, supporting both mobile and web deployment. The application features a production-ready video preview with TikTok-style chrome and synchronized audio replay, optimized for deployment.

# User Preferences
Preferred communication style: Simple, everyday language.

# Recent Changes (October 20, 2025)

## TikTok-Style Feed Layout
- **Immersive video display**: Restructured Discovery and Following feeds from Column to Stack layout for TikTok/Instagram-style video display
- **Video background layer**: Video content now fills entire screen using Positioned.fill, with PageView handling vertical scrolling through videos
- **Overlay navigation**: Top navigation bar (Following | Discovery) and bottom navigation overlay on top of video using SafeArea + Align positioning
- **Proper layering**: Videos play underneath UI chrome while maintaining full accessibility of navigation elements
- **Consistent implementation**: Both Discovery and Following feeds use identical Stack structure for unified user experience
- **Pixel-perfect TikTok spacing**: Completely removed all Container/Padding wrappers around navigation Row, leaving only SafeArea for notch protection. Navigation bar now sits flush with status bar exactly like TikTok. Tightened button spacing (8.w → 6.w gap, 4.w → 3.w horizontal padding) and removed all vertical padding to achieve identical visual hierarchy
- **Video extends behind notch**: Added `extendBody: true` and `extendBodyBehindAppBar: true` to both Discovery and Following feed Scaffolds with transparent backgroundColor. Video background now renders behind iPhone notch/status bar and extends behind bottom navigation, with UI overlays floating on top. This eliminates all black gaps/padding for true edge-to-edge immersive display matching TikTok reference exactly
- **Vertically centered action buttons**: Changed side action buttons from fixed bottom positioning to full-height Positioned with Align.center wrapper, ensuring profile/heart/comment/share/dollar icons are perfectly centered vertically on all device sizes

# Recent Changes (October 10, 2025)

## Splash Screen Logo and Text Update
- **Logo replacement**: Updated AnimatedLogoWidget to use correct logo `YNFNY_Logo-1753669643145.png` (Statue of Liberty artwork) instead of compressed versions
- **Tagline text update**: Changed tagline from "You Are Not From New York" to "You Not From New York" while maintaining identical styling (orange #FF8C00, 21px, Inter font, weight 600)
- **Asset cleanup**: Removed unused logo files (YNFNY_Logo-1753709879889.png, ynfny_logo_compressed.png, ynfny_logo_compressed.webp)
- **Asset loading fix**: Added `assets/images/` to pubspec.yaml flutter section to resolve AssetManifest.bin.json 502 errors and enable proper logo/asset bundling
- **Preserved elements**: "WE OUTSIDE" subtitle, all animations (glow, scale), error fallbacks, and splash flow logic remain unchanged

# Recent Changes (October 9, 2025)

## Video Player Enhancements
- **Full-width scrub bar in preview**: Scrub bar now spans edge-to-edge using independent Positioned widget (left: 0, right: 0, bottom: 16) instead of Transform.translate hack. Debug logging with `[SCRUBBAR_PREVIEW]` prefix confirms width application.
- **End-frame capture fix**: Added re-seek after 200ms playback cycle in `_primeThumbnail` to prevent overshoot that caused black thumbnails at video end.

## UI Consistency Updates
- **Unified performance type badges**: Created shared `PerformanceTypeBadge` widget replacing inconsistent implementations across registration, performer profile, and upload screens. All badges now use:
  - Oval/capsule shape (BorderRadius.circular(20))
  - Active: solid orange (#FF8C00), Inactive: dark gray (#1C1C1E)
  - Material Icons (music_note, directions_run, brush, theater_comedy, auto_awesome, star)
  - Consistent typography (14px bold white text) and spacing (12px horizontal, 6px vertical padding)
  - Backend integration preserved: no changes to Supabase schema, API calls, or performance type values
- **Splash screen simplification**: Removed subtitle text "Discover NYC Street Performers" from splash screen, maintaining only the centered animated logo and loading indicator. Navigation flow and all initialization logic remain unchanged.

# System Architecture

## Frontend Architecture
The application uses Flutter for a single codebase across mobile and web. Key features include:
- **Environment Configuration**: Secure management of environment variables via `env.json` and `--dart-define-from-file`.
- **Video Recording & Upload**: TikTok/Reels-style UI for vertical video recording and a modernized upload screen, optimized for quality and cross-platform compatibility, including full-screen preview, portrait lock, maximum resolution, responsive controls, and pinch-to-zoom.
- **Video Preview with Audio Replay**: Production-ready video preview with manual replay system that fully reinitializes the VideoPlayerController on each replay to ensure synchronized audio/video playback. Uses controller disposal and recreation instead of seekTo() to restore complete audio context. HtmlElementView fallback uses video.load() to force browser media stream reload.
- **Interactive Video Scrubber**: Full-width edge-to-edge progress timeline with iPhone Photos/Reels-style scrubber positioned below location text in preview player. Features 3px orange track (#FF8C00), draggable thumb for precise seeking with sub-second accuracy, dual-path support (VideoPlayer + HtmlElementView), and automatic playback resumption after seeking to maintain audio sync. Uses independent Positioned widget (left: 0, right: 0, bottom: 16) to achieve true full-screen width spanning both edges on all devices. Debug logging with `[SCRUBBAR_PREVIEW]` prefix tracks width application.
- **Unified Thumbnail-Preview Button**: Interactive preview element that merges thumbnail display and video preview into a single tappable component. Features 85% width centered container with fixed 4:5 (0.8) aspect ratio, displaying the current video frame (paused at selected timestamp) with centered play icon overlay (56px, semi-transparent) and duration badge. Automatically shows first frame (Duration.zero) as default thumbnail on upload screen load using `_primeThumbnail()` function called via postFrameCallback after VideoPlayer widget is built: mute controller, seek to position, play 180ms to force texture rendering (critical for web), pause at frame, restore volume, verify rendering success with optional retry. Uses shared orientation state system with comprehensive debug logging for reliable rotation across all contexts. Uses PointerInterceptor for web compatibility to capture tap events above HtmlElementView platform views. Tapping opens full-screen TikTok-style preview with synchronized audio replay and transform cleanup on dispose to prevent rotation persistence.
- **Thumbnail Selection with Real-Time Preview**: Thumbnail selection UI appears below the unified preview when "Select Thumbnail" is clicked. Features a scrubber bar that seeks the main VideoPlayerController in real-time, with instant preview updates via 100ms silent play-pause technique on each scrub position change. Confirmation button saves the selected timestamp (in milliseconds) to `_selectedThumbnailFramePosition` and refreshes preview via `_primeThumbnail(selected)` for database persistence. Single controller architecture eliminates duplicate containers and ensures consistent orientation handling. Database field `thumbnail_frame_time` added to `videos` table for persistence.
- **Web Transform Cleanup**: Full-screen video preview implements simplified transform cleanup on dispose to prevent rotation persistence. For both Replit sandbox (HtmlElementView) and standard Flutter web, removes all inline transform/style properties (transform, will-change, object-fit, position, top, left, width, height) from video elements when preview closes. This ensures the shared controller's video element returns to clean state for upload screen display, which uses Transform.rotate wrapper for orientation handling instead of inline HTML transforms.
- **Shared Orientation State System**: Production-ready video orientation management using a single source of truth to prevent drift across contexts. Calculates `_orientationRadians` once during controller initialization from video metadata (rotationCorrection), falling back to 90° rotation for landscape videos without metadata. Supports positive (+90°), negative (-90°), and zero (0°) rotations. Threads orientation state to full-screen preview via constructor parameter, eliminating recalculation. All rotation contexts (Transform.rotate wrapper, Replit sandbox DOM, standard web DOM) use shared state with absolute value checks (abs() > 1e-3) to handle bidirectional rotations. Implements post-preview thumbnail refresh: awaits dialog closure, re-primes thumbnail at selected position, and forces setState to rebuild Transform.rotate wrapper, ensuring upright orientation after exiting preview. Comprehensive debug logging with `[THUMBNAIL]` and `[ROTATION]` prefixes tracks orientation calculation, postFrameCallback timing, frame priming with retry, verification results, rotation application, transform cleanup, and post-preview refresh. PostFrameCallback timing fix prevents race conditions by setting `_hasDisplayedInitialFrame` flag before scheduling callback. Frame verification includes 200ms play time with re-seek to prevent overshoot, ±80ms position tolerance, controller ready state, and web readyState >= 2 checks with max 2 retry attempts at 150ms delay intervals.
- **End-Frame Capture System**: Prevents black thumbnail after video completion by detecting playback end and capturing the final visible frame. When video reaches end (position >= duration), automatically seeks to last frame (duration - 33ms) and pauses. On preview close, checks if video completed and intelligently selects thumbnail position: uses last frame if video ended, selected thumbnail if user chose one, or first frame as fallback. The `_primeThumbnail` function includes critical re-seek after 200ms playback cycle to ensure controller remains at exact target position, preventing overshoot that causes black frames. Comprehensive logging with `[END_FRAME]` prefix tracks video completion, final frame capture, and re-priming operations.
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