# Overview
YNFNY is a cross-platform Flutter mobile application designed as a social platform for street performers. It integrates multiple AI services, Supabase for backend services, and Stripe for payment processing. The project aims to provide a robust and engaging platform for street artists to connect with their audience and monetize their performances, supporting both mobile and web deployment. The application features a production-ready video preview with TikTok-style chrome, optimized for deployment.

# User Preferences
Preferred communication style: Simple, everyday language.

# System Architecture

## Frontend Architecture
The application uses Flutter for a single codebase across mobile and web. Key features include:
- **Environment Configuration**: Secure management of environment variables via `env.json` and `--dart-define-from-file`.
- **Video Recording & Upload**: TikTok/Reels-style UI for vertical video recording and a modernized upload screen, optimized for quality and cross-platform compatibility, including full-screen preview, portrait lock, maximum resolution, responsive controls, and pinch-to-zoom.
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
- **Payment Processing**: Stripe.
- **Backend Services**: Supabase.

## Development Tools
- **Flutter Framework**: Version 3.32.0 with Dart SDK 3.8.0.
- **Build Tools**: Automated build system via `build_web.sh`.
- **Package Management**: Flutter Pub for Dart packages and NPM for Node.js.
- **Web Server**: Node.js Express server (`server.js`) for serving static Flutter web builds.

## Infrastructure
- **Web Hosting**: Static web deployment with CanvasKit rendering.
- **Environment Management**: JSON-based configuration.
- **Deployment**: Configured for Replit autoscale deployment.