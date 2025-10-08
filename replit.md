# Overview

YNFNY is a cross-platform Flutter mobile application designed as a social platform for street performers. It integrates multiple AI services (OpenAI, Gemini, Anthropic, Perplexity), Supabase for backend services, and Stripe for payment processing. The project aims to provide a robust and engaging platform for street artists to connect with their audience and monetize their performances, supporting both mobile and web deployment.

**Current Status** (Oct 8, 2025): ✅ **VIDEO PREVIEW BLACK SCREEN FIXED** - Implemented comprehensive fix for Flutter web first-load black screen issue via DOM visibility detection, CSS enforcement, and paint refresh sequence.

## Recent Video Preview Fixes (Oct 8, 2025)

### Layer Composition Fix (Latest)
- **Z-Index Promotion**: After DOM detection, sets `z-index=9999` + `position=absolute` + full viewport sizing (top=0, left=0, width/height=100%) to bring video element above Flutter canvas layer
- **Bounding Box Detection**: Uses `getBoundingClientRect()` instead of `videoWidth/videoHeight` for reliable visibility confirmation - only confirms paint when browser reports non-zero rendered box
- **Clip Prevention**: Added `clipBehavior: Clip.none` to Stack and Container wrappers to prevent Flutter from clipping the promoted DOM video element
- **Complete Fix Flow**: DOM detected → CSS visibility + z-index layer promotion → Playback starts → 150ms delay → Pause/play repaint → Bounding rect check → Paint confirmed

### Paint Visibility Enforcement
- **CSS Visibility Enforcement**: After DOM detection, explicitly sets `visibility='visible'`, `opacity='1'`, `display='block'` on all video elements to override hidden styles
- **Paint Refresh Sequence**: 150ms delay after CSS changes, then pause/play cycle in postFrameCallback to force browser texture repaint
- **Enhanced Debug Overlay**: Added "Paint ✅/❌" indicator (web-only) to confirm video texture has dimensions

### DOM Visibility Detection
- **Cross-Platform Stub Pattern**: Created `web_dom_stub.dart` with Document/ElementList stubs for mobile builds, conditional import switches to real `dart:html` on web
- **Direct DOM Access**: Replaced eval() with `html.document.getElementsByTagName('video').length` for CSP-safe checking
- **Retry Logic**: Polls every 200ms for up to 3 seconds (15 attempts) to detect when HTML `<video>` element attaches to DOM
- **Dynamic Texture Refresh**: ValueKey based on timestamp forces texture layer recreation on timeout

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## Frontend Architecture
The application uses Flutter for a single codebase across mobile and web. Key features include:
- **Environment Configuration**: Secure management of environment variables via `env.json` and `--dart-define-from-file`.
- **Video Recording & Upload**: TikTok/Reels-style UI for vertical video recording and a modernized upload screen, optimized for quality and cross-platform compatibility. This includes full-screen preview, portrait lock, maximum resolution, responsive controls, pinch-to-zoom, and platform-safe video controllers.
- **Thumbnail Generation**: Mobile-only feature using `video_thumbnail` for generating 8 preview frames; web displays a "not available" message.
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
- **Payment Processing**: Stripe (with test environment).
- **Backend Services**: Supabase (hosted instance).

## Development Tools
- **Flutter Framework**: Version 3.32.0 with Dart SDK 3.8.0.
- **Build Tools**: Automated build system via `build_web.sh` for clean rebuilds and icon/font preservation.
- **Package Management**: Flutter Pub for Dart packages and NPM for Node.js.
- **Web Server**: Node.js Express server (`server.js`) for serving static Flutter web builds.

## Infrastructure
- **Web Hosting**: Static web deployment with CanvasKit rendering, utilizing Google's CDN for assets.
- **Environment Management**: JSON-based configuration.
- **Deployment**: Configured for Replit autoscale deployment.