# Overview

YNFNY is a cross-platform Flutter mobile application designed as a street performer social platform. The app integrates multiple AI services (OpenAI, Gemini, Anthropic, Perplexity), Supabase for backend services, and Stripe for payment processing. It's built using modern Flutter development practices with support for web deployment and environment-based configuration.

**Current Status**: ✅ **REGISTRATION FLOW FIXED** - Resolved duplicate key error in registration caused by Supabase database trigger. Supabase's `handle_new_user` trigger automatically creates a user_profiles row when auth.signUp() is called. Fixed Flutter registration to UPDATE the trigger-created profile instead of INSERT (which was causing primary key conflicts). Registration now: (1) Creates auth account, (2) Trigger auto-creates basic profile, (3) App UPDATEs profile with complete data (username, performance types, social media), (4) Navigates to Discovery Feed. Includes verification that UPDATE succeeded and comprehensive error handling for username conflicts. Previous work: Username availability checking with real-time validation and smart suggestions; Performance types simplified to 6 categories. Latest update (Oct 6, 2025): Registration trigger-UPDATE fix.

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## Frontend Architecture
The application follows Flutter's standard architecture patterns:
- **Cross-platform approach**: Single codebase targeting mobile and web platforms using Flutter SDK 3.29.2+
- **Environment configuration**: Uses environment variables loaded from `env.json` files via `--dart-define-from-file` for secure configuration management
- **Multi-platform deployment**: Supports both native mobile apps and web deployment with dedicated web build artifacts

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
  - Previous manual Flutter 3.24.5 installation removed; now using stable Nix Flutter
- **Build Tools**: Standard Flutter build system with web compilation support
  - **CRITICAL**: Use `./build_web.sh` script for all web builds - includes `--no-tree-shake-icons` flag to preserve Material Icons font glyphs
  - Without this flag, Flutter optimizations may remove icon glyphs making icons invisible in the UI
  - Verification: MaterialIcons-Regular.otf (11KB) bundled in build/web/assets/fonts/
- **Package Management**: Pub package manager with dependencies on async, args, boolean_selector, and other Flutter ecosystem packages

### Infrastructure
- **Web Hosting**: Static web deployment with CanvasKit rendering
- **CDN**: Uses Google's infrastructure for Flutter web assets
- **Environment Management**: JSON-based configuration for different deployment environments