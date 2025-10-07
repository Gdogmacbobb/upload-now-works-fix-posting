# Overview

YNFNY is a cross-platform Flutter mobile application designed as a street performer social platform. The app integrates multiple AI services (OpenAI, Gemini, Anthropic, Perplexity), Supabase for backend services, and Stripe for payment processing. It's built using modern Flutter development practices with support for web deployment and environment-based configuration.

**Current Status**: ✅ **PRODUCTION-GRADE CAMERA CONTROLS** - Complete camera controller rebuild with isolate-based zoom and always-visible flash icons (Oct 7, 2025). Implemented 30px icons for optimal visibility. Flash icon now always renders with grey-out state for unsupported cameras (lens direction check). Production-ready zoom throttling using Timer.periodic (60ms intervals) with Future.microtask offloading, stream safety checks, and trailing update flush to prevent snap-back. Smooth continuous zoom during sustained pinch gestures with no UI freeze or dropped updates. Enhanced camera initialization logging. Previous: Polished TikTok/Reels-style vertical video interface with full-screen camera preview, portrait-only lock, four top controls, centered orange record button with live timer, and comprehensive error handling. App builds successfully for web (52-55s) with no LSP errors.

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## Frontend Architecture
The application follows Flutter's standard architecture patterns:
- **Cross-platform approach**: Single codebase targeting mobile and web platforms using Flutter SDK 3.29.2+
- **Environment configuration**: Uses environment variables loaded from `env.json` files via `--dart-define-from-file` for secure configuration management
- **Multi-platform deployment**: Supports both native mobile apps and web deployment with dedicated web build artifacts
- **Video Recording & Upload**: Full camera-to-upload flow with TikTok/Reels-style UI and web compatibility
  - **VideoRecordingScreen**: Polished vertical video recording interface
    - **Full-screen preview**: Transform.scale with aspect ratio calculation to fill entire screen without black bars
    - **Portrait lock**: SystemChrome locks orientation to portraitUp only, restored on dispose
    - **Top controls**: Four buttons with consistent dark rounded backgrounds (8px radius, black54, 30px icons)
      - Back button (top-left) - Icons.arrow_back
      - Mute/Unmute toggle (top-left) - Icons.mic/mic_off, fully functional, reconfigures camera controller
      - Flash on/off toggle (top-right) - Icons.flash_on/flash_off, **always visible** with grey-out state when unsupported (_hasFlashSupport getter checks lens direction), comprehensive error handling
      - Camera switch (top-right) - Icons.cameraswitch, preserves flash state, disabled during recording
    - **Pinch-to-zoom**: Production-grade zoom with Timer.periodic throttling for smooth, freeze-free control
      - **Throttling architecture**: Single Timer.periodic(60ms) started in onScaleStart, stopped in onScaleEnd with trailing update flush
      - **Update flow**: onScaleUpdate queues latest zoom in _pendingZoom, timer applies every 60ms via Future.microtask
      - **Trailing flush**: onScaleEnd flushes any pending zoom before stopping timer (prevents snap-back on release)
      - **UI thread offloading**: Future.microtask moves zoom operations off main thread, prevents blocking
      - **Stream safety**: Checks controller.value.isStreamingImages before applying zoom to avoid frame conflicts
      - Hardware-aware zoom limits: Queries actual camera min/max via getMinZoomLevel()/getMaxZoomLevel()
      - Dynamic range support: Clamps zoom within camera's full reported capabilities (preserves wide-angle support)
      - Zoom reset: Resets to 1.0x (normal view) via setZoomLevel(1.0) when switching cameras or toggling mute
      - Full range access: Pinch-to-zoom works across entire hardware range (e.g., 0.6x wide to 10x tele if supported)
      - Error feedback: Silent debug logging for zoom failures (non-intrusive)
      - Base zoom tracking: onScaleStart stores current zoom, onScaleUpdate calculates delta
    - **Record button**: Centered at bottom with orange ring (5px), changes from white circle to red square when recording
    - **Live timer**: MM:SS format above record button with red indicator dot, only visible during recording
    - **Error handling**: SnackBar feedback for all failures (recording start/stop, flash toggle, zoom, camera operations)
    - **Navigation**: Stops recording and navigates to '/video-upload' with file path
  - **VideoUploadScreen**: Video preview with playback controls, caption input, performance type selection, location tagging, privacy settings
  - **Navigation flow**: Feed → Camera button → Video Recording → Video Upload with file path passing
  - **Web Compatibility**: Conditional import pattern (lib/platform/) for platform-specific code
    - `video_controller_factory.dart`: Export with dart.library.io/html conditions
    - `video_controller_mobile.dart`: Uses dart:io File for mobile platforms
    - `video_controller_web.dart`: Uses networkUrl for web blob URLs
    - `video_controller_stub.dart`: Fallback UnimplementedError
  - **Null Safety**: All camera/video controllers nullable with _isInitialized flags, mounted checks before setState

## Backend Architecture
The system uses a serverless architecture with external services:
- **Supabase integration**: Primary backend-as-a-service for authentication, database, and real-time features
- **Serverless functions**: Deno-based edge functions for payment processing and business logic
- **Payment processing**: Stripe integration with server-side payment intent creation for secure transactions

## Data Storage Solutions
- **Secure PostgreSQL database**: Database with comprehensive Row-Level Security (RLS) policies preventing privilege escalation
- **Role-based data access**: Street Performers can create videos/receive donations, New Yorkers have profile access only
- **Performance optimized**: Proper indexes on all RLS policy predicates for optimal query performance
- **Real-time capabilities**: Leverages Supabase's real-time subscriptions for live updates
- **File storage**: Supabase storage for media and user-generated content with role-based access controls

## Authentication and Authorization
- **Supabase Auth**: Handles user registration, login, and session management
- **Registration Flow**: Complete email/password signup with profile UPDATE to trigger-created `user_profiles` row. Supabase's `handle_new_user` trigger automatically creates base profile on auth signup, then app UPDATEs with full user data. Includes verification that UPDATE succeeded, session cleanup on failures to prevent orphaned auth accounts, specific error messages for username conflicts/permissions/auth failures
- **Username Availability System**: Real-time username validation with 500ms debouncing. Supabase RPC functions: `check_username_availability(p_username)` checks availability efficiently, `get_username_suggestions(p_username, p_borough, p_performance_types)` generates smart alternatives. UI shows visual indicators (green checkmark for available, red X for taken, spinner while checking) with border color changes. Suggestion chips display when username is taken, offering numeric (hork1, hork2), location-based (hork_nyc, hork_brooklyn), and category-based (hork_music, hork_dance) alternatives. Form submission blocked until username availability confirmed.
- **Performance Type Selection**: Street performers select one or more performance types during registration using a simple toggle UI. 6 category options with emoji icons: Music 🎵, Dance 💃, Visual Arts 🎨, Comedy 🎭, Magic ✨, Other ⭐
- **Profile Persistence**: All user data (id, email, username, full_name, role, borough) stored in `user_profiles`. Role-specific fields: `performance_types` (JSONB array storing List<String> of selected category names like ['Music', 'Dance']), social media (Instagram, TikTok, YouTube) for Street Performers; `birth_date` for New Yorkers. Migration 20251006 added performance_types column with GIN index.
- **JWT tokens**: Secure authentication using Supabase's JWT implementation
- **Anonymous key configuration**: Public API access controlled through Supabase's row-level security
- **Enterprise Security Architecture**: Two-layer security system with UI controls and database enforcement
- **Database-Level Security**: PostgreSQL Row-Level Security (RLS) with backend-only user context setting preventing client-side privilege escalation
- **RoleGate Widget System**: Production-ready role enforcement with multiple constructors (performerOnly, authenticated, adminOnly, newYorkerOnly, requiresFeature, requiresAnyFeature), flexible display modes (hideWhenRestricted, fallback, showInfoMessage, disabled overlay), loading states, real-time updates, and defense-in-depth whole-page guards
- **Profile Management**: Full profile editing functionality for both roles with role-appropriate UI hints and validation
- **Security Functions**: PostgreSQL app.current_user_id() and SECURITY DEFINER app.set_current_user() functions for secure backend authentication context

## External Dependencies

### Third-party Services
- **AI Services Integration**: 
  - OpenAI API for conversational AI capabilities
  - Google Gemini API for additional AI features
  - Anthropic API for Claude AI integration
  - Perplexity API for search and knowledge queries
- **Payment Processing**: Stripe with test environment configuration
- **Backend Services**: Supabase (hosted at oemeugiejcjfbpmsftot.supabase.co)

### Development Tools
- **Flutter Framework**: Version 3.32.0 (Nix package) with Dart SDK 3.8.0
  - **Theme API Migration**: Updated to Flutter 3.32.0 API (CardTheme→CardThemeData, TabBarTheme→TabBarThemeData, DialogTheme→DialogThemeData)
  - Installed via Nix packager (replaces previous manual installation)
- **Build Tools**: Standard Flutter build system with web compilation support
  - **CRITICAL**: Use `flutter build web --release --no-tree-shake-icons` for all web builds - includes flag to preserve Material Icons font glyphs
  - Without this flag, Flutter optimizations may remove icon glyphs making icons invisible in the UI
  - Verification: MaterialIcons-Regular.otf (11KB) bundled in build/web/assets/fonts/
- **Package Management**: 
  - Flutter: Pub package manager with 173 dependencies
  - Node.js: NPM with Express, Stripe packages for web server
- **Web Server**: Node.js Express server (server.js) serves static Flutter build from build/web on port 5000
  - CORS enabled for all origins
  - Cache-Control headers set to no-cache for immediate updates
  - Custom /__log endpoint for camera preview debugging

### Infrastructure
- **Web Hosting**: Static web deployment with CanvasKit rendering
- **CDN**: Uses Google's infrastructure for Flutter web assets
- **Environment Management**: JSON-based configuration for different deployment environments
- **Deployment**: Configured for Replit autoscale deployment
  - Build command: `flutter build web --release --no-tree-shake-icons && npm install`
  - Run command: `node server.js`
  - Port: 5000 (webview output)