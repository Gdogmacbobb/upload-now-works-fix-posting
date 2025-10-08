# Overview

YNFNY is a cross-platform Flutter mobile application serving as a social platform for street performers. It integrates multiple AI services (OpenAI, Gemini, Anthropic, Perplexity), Supabase for backend services, and Stripe for payment processing, targeting both mobile and web deployment. The project aims to provide a robust and engaging platform for street artists to connect with their audience and monetize their performances.

**Current Status**: ✅ **VIDEO RECORDING & UPLOAD COMPLETE** (Oct 8, 2025) - Production-ready TikTok/Reels-style recording with full-screen preview modal and thumbnail selection in upload screen.

**Recent Enhancements (Oct 8, 2025)**:
- **Upload Screen Modernization**: Full-screen video preview modal (tap to expand), 8-thumbnail generation/selection with orange border (#FF8C00) on selected, platform-safe with web compatibility (blob URLs for web, File-based for mobile)
- **Platform-Safe Video Controllers**: Proper `dart:io` import guards prevent web compilation errors; `VideoPlayerController.networkUrl()` for web, `VideoPlayerController.file()` for mobile
- **Thumbnail Generation**: Mobile-only feature using `video_thumbnail` package (v0.5.6); web shows feedback snackbar "not available on web"
- **Continuous Torch Light**: Torch stays ON for full recording duration when flash enabled before start; auto-disables when recording stops. Platform-aware: hardware torch on native rear camera, visual-only feedback on web/front camera
- **Navigation Restored**: DEV_SKIP_GEO_AUTH set to false; authenticated users → /discovery-feed, non-authenticated → /login-screen
- **Recording Stop Protection**: Added comprehensive null/state checks before stopRecording() to prevent crashes
- **Flash Auto-Off Fix**: Platform-aware flash disable after recording - visual-only on web, hardware call on native to prevent NoSuchMethodError

**Previous Structural Fixes (Oct 7, 2025)**:
- **Z-Index Layering**: Camera preview wrapped in RepaintBoundary+Positioned.fill, overlay elevated with Material(elevation:10) to force icons above browser <video> element
- **Web Flash Mock**: kIsWeb check enables visual-only flash toggle on web (no hardware calls, preserves icon state for mobile)
- **Navigation Safety**: DEV_SKIP_GEO_AUTH bypass uses addPostFrameCallback with mounted guard to prevent route stack corruption
- **Build Config**: Deployment uses `flutter build web --no-tree-shake-icons` (release mode disabled due to Flutter 3.32.0 Matrix4 compilation bug)
- **Diagnostic Logging**: Added [NAV_STATE], [UI_RENDER], [CAMERA_STACK], [FLASH_UI] prefixes for comprehensive debugging

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## Frontend Architecture
The application utilizes Flutter's standard architecture, focusing on a single codebase for mobile and web. Key features include:
- **Environment Configuration**: Secure management of environment variables via `env.json` and `--dart-define-from-file`.
- **Video Recording & Upload**: A TikTok/Reels-style UI for vertical video recording and modernized upload screen, optimized for maximum quality and cross-platform compatibility.
  - **Recording Screen**: Full-screen preview, portrait lock, maximum resolution, widest view start (minZoom), responsive controls (back, mute, flash, camera switch)
  - **Upload Screen**: Full-screen video preview modal (tap to expand with TikTok-style overlay), 8-thumbnail generation/selection (mobile-only) with orange selection border, caption input, performance type chips, location card, privacy settings
  - **Pinch-to-zoom**: 60fps-optimized zoom with throttling, GPU isolation, and hardware-aware zoom limits
  - **Platform-Safe Controllers**: `dart:io` imports properly guarded; `VideoPlayerController.networkUrl()` for web blob URLs, `VideoPlayerController.file()` for mobile
  - **Thumbnail Generation**: `video_thumbnail` package (v0.5.6) generates 8 preview frames on mobile; web displays "not available" snackbar
  - **Debug Overlay**: On-screen diagnostics for camera parameters
  - **Enhanced Logging**: Comprehensive camera initialization and event diagnostics
  - **Error Handling**: SnackBar feedback for all camera operations
- **Null Safety**: Extensive use of nullable types and `_isInitialized` flags with `mounted` checks for robust camera/video controller management.

## Backend Architecture
A serverless approach leveraging external services:
- **Supabase Integration**: Primary BaaS for authentication, database, and real-time features.
- **Serverless Functions**: Deno-based edge functions for business logic and payment processing.

## Data Storage Solutions
- **Secure PostgreSQL**: Database with Row-Level Security (RLS) and role-based access.
- **Performance Optimization**: Indexes on RLS policy predicates.
- **Real-time Capabilities**: Supabase real-time subscriptions.
- **File Storage**: Supabase storage for media with role-based access controls.

## Authentication and Authorization
- **Supabase Auth**: Manages user registration, login, and sessions.
- **Registration Flow**: Email/password signup with profile creation and username availability system. Includes `check_username_availability` and `get_username_suggestions` RPC functions for real-time validation and suggestions.
- **Performance Type Selection**: Street performers can select from six categories (Music, Dance, Visual Arts, Comedy, Magic, Other) with emoji icons during registration.
- **Profile Persistence**: User data (id, email, username, full_name, role, borough) stored in `user_profiles`, with role-specific fields like `performance_types` and social media links for performers, and `birth_date` for New Yorkers.
- **JWT Tokens**: Secure authentication.
- **Enterprise Security Architecture**: Two-layer security with UI controls and database enforcement (RLS).
- **RoleGate Widget System**: Production-ready role enforcement (`performerOnly`, `authenticated`, etc.) with flexible display modes and whole-page guards.
- **Profile Management**: Full profile editing for both roles.
- **Security Functions**: PostgreSQL `app.current_user_id()` and `app.set_current_user()` for secure backend context.

## System Design Choices
- **UI/UX**: Focus on a polished, intuitive user experience, especially for video recording with TikTok/Reels-like interactions.
- **Cross-Platform Development**: Single codebase with platform-specific adaptations where necessary.
- **Scalability**: Designed with serverless functions and managed services for scalability.

# External Dependencies

## Third-party Services
- **AI Services**: OpenAI API, Google Gemini API, Anthropic API, Perplexity API.
- **Payment Processing**: Stripe (with test environment).
- **Backend Services**: Supabase (hosted instance).

## Development Tools
- **Flutter Framework**: Version 3.32.0 (Nix package) with Dart SDK 3.8.0.
- **Build Tools**: Standard Flutter build system; web builds require `flutter build web --release --no-tree-shake-icons`.
- **Package Management**: Flutter Pub for Dart packages (173 dependencies) and NPM for Node.js (Express, Stripe).
- **Web Server**: Node.js Express server (`server.js`) for serving static Flutter web builds.

## Infrastructure
- **Web Hosting**: Static web deployment with CanvasKit rendering.
- **CDN**: Google's infrastructure for Flutter web assets.
- **Environment Management**: JSON-based configuration.
- **Deployment**: Configured for Replit autoscale deployment.