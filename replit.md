# Overview

YNFNY is a cross-platform Flutter mobile application designed as a street performer social platform. The app integrates multiple AI services (OpenAI, Gemini, Anthropic, Perplexity), Supabase for backend services, and Stripe for payment processing. It's built using modern Flutter development practices with support for web deployment and environment-based configuration.

**Current Status**: ✅ **HYBRID CAMERA BRIDGE COMPLETE** - Production-ready camera system with environment-based routing (Oct 7, 2025). **Architecture**: Factory pattern detects `kIsWeb` and returns WebCameraController (Flutter camera plugin) for Replit/web or native PlatformCameraController (CameraX/AVFoundation) for mobile. **Native features**: CameraX/AVFoundation platform channels for hardware control, 60fps with graceful fallback, minZoom start, torch control, 16ms zoom throttling, tap-to-focus. **Web features**: Flutter camera plugin with 7-camera support, front/back switching, 0.5x-10x zoom range, video recording capability. **Interface**: Unified controller API—initialize, setZoom, setTorch, switchCamera, startRecording, stopRecording work identically across platforms. **UI**: VideoRecordingScreen renders CameraPreview widget on web, Texture widget on native. **Logging**: [ENV_MODE] and [CAMERA_SOURCE] prefixes for debugging. **No code duplication**: Single codebase with transparent environment routing.

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## Frontend Architecture
The application follows Flutter's standard architecture patterns:
- **Cross-platform approach**: Single codebase targeting mobile and web platforms using Flutter SDK 3.29.2+
- **Environment configuration**: Uses environment variables loaded from `env.json` files via `--dart-define-from-file` for secure configuration management
- **Multi-platform deployment**: Supports both native mobile apps and web deployment with dedicated web build artifacts
- **Video Recording & Upload**: Full camera-to-upload flow with TikTok/Reels-style UI and web compatibility
  - **VideoRecordingScreen**: Polished vertical video recording interface with maximum quality settings
    - **Full-screen preview**: Transform.scale with aspect ratio calculation to fill entire screen without black bars
    - **Portrait lock**: SystemChrome locks orientation to portraitUp only, restored on dispose
    - **Maximum Quality**: ResolutionPreset.max for highest available resolution and video quality
    - **Widest View Start**: Defaults to hardware minZoom (typically 0.6x) instead of 1.0x for maximum field of view at startup
    - **Top controls**: Stack overlay architecture with SafeArea and Positioned widgets for guaranteed visibility (32px icons, 8px radius, black54 backgrounds)
      - **SafeArea wrapper**: Ensures all controls stay clear of notches/status bars with proper inset padding
      - **Stack+Positioned layout**: Controls positioned at exact coordinates (top: 12, left/right: 12/72) from safe area bounds
      - Back button (Positioned top:12, left:12) - Icons.arrow_back, **always visible** outside initialization guard for guaranteed navigation
      - Mute toggle (Positioned top:12, left:72) - Icons.mic/mic_off, conditional on camera ready, reconfigures controller
      - Flash toggle (Positioned top:12, right:12) - Icons.flash_on/flash_off, **always visible** with 40% opacity when unsupported, success SnackBar feedback ("Flash enabled/disabled")
      - Camera switch (Positioned top:12, right:72) - Icons.cameraswitch, preserves flash state, disabled during recording
    - **Pinch-to-zoom**: 60fps-optimized zoom with 16ms throttling for maximum responsiveness
      - **Throttling architecture**: Single Timer.periodic(16ms) started in onScaleStart, stopped in onScaleEnd with trailing update flush
      - **Update flow**: onScaleUpdate queues latest zoom in _pendingZoom, timer applies every 16ms (62.5 updates/second) via Future.microtask
      - **GPU isolation**: RepaintBoundary wraps CameraPreview to create separate rendering layer, prevents unnecessary texture uploads when overlay updates
      - **Trailing flush**: onScaleEnd flushes any pending zoom before stopping timer (prevents snap-back on release)
      - **UI thread offloading**: Future.microtask moves zoom operations off main thread, prevents blocking
      - **Stream safety**: Checks controller.value.isStreamingImages before applying zoom to avoid frame conflicts
      - Hardware-aware zoom limits: Queries actual camera min/max via getMinZoomLevel()/getMaxZoomLevel()
      - Dynamic range support: Clamps zoom within camera's full reported capabilities (preserves wide-angle support)
      - Zoom defaults: Starts at minZoom (widest view), resets to minZoom when switching cameras or toggling mute
      - Full range access: Pinch-to-zoom works across entire hardware range (e.g., 0.6x wide to 10x tele if supported)
      - Error feedback: Silent debug logging for zoom failures (non-intrusive)
      - Base zoom tracking: onScaleStart stores current zoom, onScaleUpdate calculates delta
    - **Debug Overlay**: On-screen diagnostic display (top-left, below controls) showing:
      - Current zoom level with 2 decimal precision (e.g., "0.60x")
      - Hardware zoom range (e.g., "Range: 0.60x - 10.00x")
      - Camera type ("Back Camera" or "Front Camera")
      - Resolution setting ("ResolutionPreset.max")
      - Monospace font, semi-transparent styling, updates in real-time during zoom
    - **Enhanced Logging**: Comprehensive camera initialization diagnostics with visual separators:
      - Lens direction (Back/Front)
      - Flash support status
      - Hardware zoom range (min-max)
      - Starting zoom level
      - Resolution preset and preview size
      - Audio state
      - Camera switch and mute toggle events
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