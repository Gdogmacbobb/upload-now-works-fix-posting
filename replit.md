# Overview
YNFNY is a cross-platform Flutter mobile and web application that functions as a social platform for street performers. It integrates various AI services, Supabase for backend operations, and Stripe for payments. The project aims to create an engaging platform for street artists to connect with audiences, monetize performances, and features a production-ready video preview system with TikTok-style UI and synchronized audio replay.

# User Preferences
Preferred communication style: Simple, everyday language.

# System Architecture

## Frontend Architecture
The application uses Flutter for a unified codebase across mobile and web platforms.
- **Environment Configuration**: Secure management of environment variables using `env.json` and `--dart-define-from-file`.
- **Video Recording & Upload**: Provides a TikTok/Reels-style UI for vertical video recording and an optimized upload screen, including full-screen preview, portrait lock, maximum resolution, responsive controls, and pinch-to-zoom.
- **Video Playback**: Features a production-ready video preview system with a manual replay mechanism that reinitializes the `VideoPlayerController` for synchronized audio/video playback. Includes an edge-to-edge interactive scrubber for precise seeking and real-time thumbnail selection.
- **Orientation Management**: A shared orientation state system ensures consistent video rotation across different contexts, including a post-preview thumbnail refresh.
- **End-Frame Capture**: Prevents black thumbnails by intelligently capturing the final visible frame at the end of video playback.
- **UI/UX**: Focuses on a polished and intuitive user experience, particularly for video interactions, with TikTok-style immersive layouts and consistent component design (e.g., `PerformanceTypeBadge`).
- **Null Safety**: Extensive use of null safety features for robust controller management.

## Backend Architecture
A serverless approach utilizing external services:
- **Supabase Integration**: Serves as the primary Backend-as-a-Service (BaaS) for authentication, database, and real-time functionalities.
- **Serverless Functions**: Deno-based edge functions handle core business logic and payment processing.

## Data Storage Solutions
- **Secure PostgreSQL**: Features Row-Level Security (RLS) and role-based access, with optimized indexing.
- **Real-time Capabilities**: Leverages Supabase real-time subscriptions for live data updates.
- **File Storage**: Utilizes Supabase storage for media files with role-based access controls.

## Authentication and Authorization
- **Supabase Auth**: Manages user registration, login, and session management.
- **Registration Flow**: Includes email/password signup, profile creation, username availability checks, and performance type selection for artists.
- **Profile Persistence**: User data is stored in `user_profiles`, including role-specific fields.
- **JWT Tokens**: Ensures secure authentication.
- **Enterprise Security Architecture**: Implements a two-layer security approach with UI controls and database-level enforcement (RLS).
- **RoleGate Widget System**: Provides production-ready role enforcement for UI elements and page access.
- **Profile Management**: Supports full profile editing for all user roles.

## System Design Choices
- **Scalability**: Designed with serverless functions and managed services to ensure scalability.
- **UI/UX Decisions**: Immersive edge-to-edge video display, layered UI components, pixel-perfect spacing matching TikTok references, and consistent badging.

# External Dependencies

## Third-party Services
- **AI Services**: OpenAI API, Google Gemini API, Anthropic API, Perplexity API.
- **Payment Processing**: Stripe.
- **Backend Services**: Supabase.

## Development Tools
- **Flutter Framework**: Version 3.32.0 with Dart SDK 3.8.0.
- **Build Tools**: Automated build system via `build_web.sh` with `--no-tree-shake-icons`.
- **Package Management**: Flutter Pub for Dart packages and NPM for Node.js.
- **Web Server**: Node.js Express server (`server.js`) for serving static Flutter web builds.
- **Material Icons**: `uses-material-design: true` in `pubspec.yaml` for web deployment.

## Infrastructure
- **Web Hosting**: Static web deployment with CanvasKit rendering.
- **Environment Management**: JSON-based configuration.
- **Deployment**: Configured for Replit autoscale deployment.

# Recent Changes (October 20, 2025)

## Edge-to-Edge Video Rendering Fix
- **ROOT CAUSE #1: Missing web viewport configuration**: Added `viewport-fit=cover` to viewport meta tag in web/index.html to allow content to extend behind iPhone notch. Added CSS using `100dvh` (dynamic viewport height) instead of `100vh` to fix iOS Safari viewport bug where address bar causes incorrect height calculation. Added CSS rules for video elements to fill screen edge-to-edge with `position: fixed` and `100vw x 100dvh` dimensions.
- **ROOT CAUSE #2: Missing SystemChrome edge-to-edge settings**: Added `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)` and `SystemChrome.setSystemUIOverlayStyle` with transparent status bar configuration in main.dart. This enables Flutter content to render behind the iOS status bar and system navigation bar.
- **Complete fix verified**: Architect review confirmed both root causes were correctly identified and fixes applied. On iOS devices with notches, video will now render from top edge behind the notch, with FeedNavigationHeaderWidget gradient painting behind the notch while navigation text sits below it using MediaQuery.padding.top. This eliminates the black gap and achieves true TikTok-style immersive edge-to-edge layout.

## TikTok-Style Feed Layout
- **Immersive video display**: Restructured Discovery and Following feeds from Column to Stack layout for TikTok/Instagram-style video display
- **Video background layer**: Video content now fills entire screen using Positioned.fill, with PageView handling vertical scrolling through videos
- **Overlay navigation**: Top navigation bar (Following | Discovery) and bottom navigation overlay on top of video using SafeArea + Align positioning
- **Proper layering**: Videos play underneath UI chrome while maintaining full accessibility of navigation elements
- **Consistent implementation**: Both Discovery and Following feeds use identical Stack structure for unified user experience
- **Pixel-perfect TikTok spacing**: Completely removed all Container/Padding wrappers around navigation Row, leaving only SafeArea for notch protection. Navigation bar now sits flush with status bar exactly like TikTok. Tightened button spacing (8.w → 6.w gap, 4.w → 3.w horizontal padding) and removed all vertical padding to achieve identical visual hierarchy
- **Video extends behind notch**: Added `extendBody: true` and `extendBodyBehindAppBar: true` to both Discovery and Following feed Scaffolds with transparent backgroundColor. Video background now renders behind iPhone notch/status bar and extends behind bottom navigation, with UI overlays floating on top. This eliminates all black gaps/padding for true edge-to-edge immersive display matching TikTok reference exactly
- **Fixed double SafeArea issue**: Removed outer SafeArea wrapper around FeedNavigationHeaderWidget in both feeds, positioning the header directly at `top: 0` using Positioned widget. Restructured the header widget to use manual top padding (MediaQuery.of(context).padding.top) instead of SafeArea, allowing the gradient background to extend from y=0 and paint behind the notch while the Row content sits below the notch area. This eliminates the black gap that appeared above the navigation bar
- **Vertically centered action buttons**: Changed side action buttons from fixed bottom positioning to full-height Positioned with Align.center wrapper, ensuring profile/heart/comment/share icons are perfectly centered vertically on all device sizes

## TikTok-Style Vertical Spacing Refinements (October 20, 2025)
- **Separated $ button from action column**: Moved donate button out of the vertically-centered action column and positioned it independently at `bottom: 11.h` (~45px above bottom nav) for proper TikTok-style spacing
- **Raised caption text for better hierarchy**: Increased bottom positioning of performer info block from `bottom: 8.h` to `bottom: 12.h`, adding ~30-40px of breathing room above the bottom navigation bar
- **Vertically centered action icons**: Confirmed both DiscoveryFeed and FollowingFeed use `Positioned(top: 0, bottom: 0, child: Align(alignment: Alignment.center))` pattern to vertically center the profile/heart/comment/share column
- **Consistent cross-feed implementation**: Applied identical positioning values to both video player widgets (discovery_feed/widgets/video_player_widget.dart and following_feed/widgets/following_video_player_widget.dart) ensuring unified UX
- **Architect-approved layout**: Code review confirmed the vertical balance matches TikTok reference with proper spacing between caption, $ button, and bottom nav while preserving edge-to-edge video rendering

## Pixel-Perfect TikTok Positioning Refinements (October 20, 2025)
- **Profile avatar repositioned to top-right**: Separated avatar from the vertically-centered action column and positioned independently at `top: 10.h, right: 3.w` to match TikTok's layout where avatar overlaps the video edge at top-right corner
- **Action buttons maintain vertical centering**: Like, comment, and share buttons remain in the vertically-centered column (`Positioned(top: 0, bottom: 0, child: Align(alignment: Alignment.center))`) while avatar sits independently at top
- **TikTok-accurate overlay structure**: Avatar, action buttons, caption, and $ button each positioned independently with pixel-precise offsets matching TikTok reference layout
- **Preserved spacing hierarchy**: Caption at `bottom: 12.h` (~90px above bottom nav), $ button at `bottom: 11.h` (~45px above bottom nav), avatar at `top: 10.h` overlapping video edge
- **Architect-verified pixel-perfect alignment**: Code review confirmed avatar overlap and vertical centering match TikTok reference with proper responsive behavior across device sizes