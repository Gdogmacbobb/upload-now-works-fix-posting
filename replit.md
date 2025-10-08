# Overview

YNFNY is a cross-platform Flutter mobile application designed as a social platform for street performers. It integrates multiple AI services (OpenAI, Gemini, Anthropic, Perplexity), Supabase for backend services, and Stripe for payment processing. The project aims to provide a robust and engaging platform for street artists to connect with their audience and monetize their performances, supporting both mobile and web deployment.

**Current Status** (Oct 8, 2025): ✅ **VIDEO PREVIEW BLACK SCREEN DEBUGGING ENHANCED** - Implemented comprehensive renderer verification and visual debugging for Flutter web video preview black screen issue.

## Recent Video Preview Fixes (Oct 8, 2025)

### Hardware Compositing & Cross-Origin Fix (Latest - Oct 8, 2025)
- **GPU Acceleration**: Forces hardware compositing with `willChange`, `transform: translateZ(0)`, `backfaceVisibility: hidden`, `perspective: 1000px`, `mixBlendMode: normal`
- **Cross-Origin Safety**: Sets `crossOrigin='anonymous'` to prevent video texture rejection when blending with Flutter's WebGL layer
- **Smart Paint Detection**: Finds VISIBLE video element (first with non-zero bounding box) instead of always using first DOM element
- **Compositor Verification**: Logs computed opacity and transform values to confirm GPU compositing is active
- **Enhanced Diagnostics**: Detects when video has dimensions but compositor blocks blending - logs "Hardware compositor or sandbox blocked HTML video blending"
- **Complete Flow**: DOM detected → Apply GPU acceleration + CORS → Find visible video → Verify compositor → Paint ✅

### Hard Dimension Forcing Fix (Oct 8, 2025)
- **Explicit Sizing Fix**: Sets both HTML attributes (`video.width`/`height` = viewport pixels) AND CSS (`100vw`/`100vh`) to force browser allocation
- **Forced Reflow Sequence**: `pause()` → read `offsetHeight` (triggers synchronous layout) → `play()` to commit dimensions
- **Style Lifecycle**: Saves and restores maxHeight, objectFit, backgroundColor in addition to previous styles

### Renderer Verification & Visual Debugging
- **Explicit HTML Renderer Mode**: Added `<meta name='flutter-web-renderer' content='html'>` to web/index.html to force HTML renderer
- **Runtime Renderer Detection**: Checks `window.flutterWebRenderer` and logs active mode ("html", "canvaskit", or "unknown")
- **Visual DOM Debugging**: Injects lime outline (`4px solid lime`) on video elements with bounding rect logging for visual confirmation
- **Fallback Warning Overlay**: When paint check times out, displays orange warning in debug overlay showing renderer mode and compositing failure
- **Complete Debug Flow**: DOM detected → Detect renderer → Apply lime outline → Log bounds → Poll paint → If timeout: Show "⚠️ Renderer: [mode] - Video not composited"

### Full-Screen Rendering Fix with Style Restoration
- **Fixed Positioning with Viewport Units**: Uses `position: fixed` (not absolute) with `100vw/100vh` to completely detach video from Flutter layout and force full-screen rendering
- **Parent Overflow Reset**: Clears `overflow: hidden` on body/html/flt-glass-pane to prevent clipping
- **Style Lifecycle Management**: Saves all original CSS before modification, restores in dispose() to prevent persistent full-screen video after dialog closes
- **Paint Polling Verification**: Retries `getBoundingClientRect()` every 200ms until browser reports non-zero dimensions (timeout: 3 seconds)
- **Complete Fix Flow**: DOM detected → Save original styles → Reset parent overflow → Apply fixed position with viewport sizing → Playback starts → 150ms delay → Pause/play repaint → Poll bounding rect → Paint confirmed → On dialog close: Restore all original styles

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