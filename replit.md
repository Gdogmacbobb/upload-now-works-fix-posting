# Overview

YNFNY is a cross-platform Flutter mobile application serving as a social platform for street performers. It integrates multiple AI services (OpenAI, Gemini, Anthropic, Perplexity), Supabase for backend services, and Stripe for payment processing, targeting both mobile and web deployment. The project aims to provide a robust and engaging platform for street artists to connect with their audience and monetize their performances.

**Current Status**: ✅ **CAMERA SYSTEM PRODUCTION-READY** (Oct 8, 2025) - TikTok/Reels-style video recording with flash support, camera switching, and web compatibility. Navigation flow restored to production settings.

**Recent Fixes (Oct 8, 2025)**:
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
- **Video Recording & Upload**: A TikTok/Reels-style UI for vertical video recording, optimized for maximum quality and web compatibility.
  - Features include full-screen preview, portrait lock, maximum resolution, widest view start (minZoom), and responsive controls (back, mute, flash, camera switch).
  - **Pinch-to-zoom**: 60fps-optimized zoom with throttling, GPU isolation, and hardware-aware zoom limits.
  - **Debug Overlay**: On-screen diagnostics for camera parameters.
  - **Enhanced Logging**: Comprehensive camera initialization and event diagnostics.
  - **Error Handling**: SnackBar feedback for all camera operations.
  - **Web Compatibility**: Conditional imports (`lib/platform/`) for platform-specific video controller implementations, supporting `dart:io` for mobile and network URLs for web.
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