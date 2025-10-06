import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ynfny/core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';
import '../../services/auth_service.dart';
import '../../services/role_service.dart';
import '../../utils/connectivity_check.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/gradient_background_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/retry_connection_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  bool _showRetry = false;
  bool _hasConnectivityIssue = false;
  String _loadingText = 'Initializing YNFNY...';
  Timer? _timeoutTimer;
  Timer? _loadingTextTimer;

  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _setSystemUIOverlay();
    _startInitialization();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _loadingTextTimer?.cancel();
    super.dispose();
  }

  void _setSystemUIOverlay() {
    // Hide status bar on Android, use dark theme on iOS
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.backgroundDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _startInitialization() {
    _startLoadingTextAnimation();
    _startTimeoutTimer();
    _performInitializationTasks();
  }

  void _startLoadingTextAnimation() {
    final loadingMessages = [
      'Initializing YNFNY...',
      'Connecting to Supabase...',
      'Checking authentication...',
      'Loading user role...',
      'Loading user preferences...',
      'Verifying NYC location services...',
      'Preparing video cache...',
      'Almost ready...',
    ];

    int messageIndex = 0;
    _loadingTextTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted && _isLoading) {
        setState(() {
          _loadingText = loadingMessages[messageIndex % loadingMessages.length];
          messageIndex++;
        });
      }
    });
  }

  void _startTimeoutTimer() {
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && _isLoading) {
        // Only show retry if we have a genuine connectivity issue
        _checkConnectivityAndShowRetry();
        _loadingTextTimer?.cancel();
      }
    });
  }

  Future<void> _performInitializationTasks() async {
    try {
      // Initialize Supabase and check authentication
      await _supabaseService.client; // This will trigger initialization

      // Simulate other background tasks
      await Future.wait([
        _checkAuthenticationStatus(),
        _loadUserPreferences(),
        _verifyGeofencingCapabilities(),
        _prepareCachedVideoData(),
      ]);

      // Ensure minimum splash display time
      await Future.delayed(const Duration(milliseconds: 2500));

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
      
      // Only show connectivity error if this appears to be a network issue
      if (_isNetworkError(e)) {
        bool hasConnectivity = await _checkInternetConnectivity();
        if (!hasConnectivity) {
          _showConnectivityError();
          return;
        }
      }
      
      // For other errors or if connectivity exists, proceed to app
      if (mounted) {
        _navigateToNextScreen();
      }
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      // Wait for Supabase to initialize and check for initial session
      final session = await _supabaseService.waitForInitialSession();
      
      if (session != null) {
        debugPrint('Session restored: User ${session.user.email} is authenticated');
        
        // Initialize RoleService with user profile data
        await _initializeUserRole();
      } else {
        debugPrint('No session found: User needs to log in');
      }
    } catch (e) {
      debugPrint('Auth check error: $e');
    }
  }

  Future<void> _initializeUserRole() async {
    try {
      // Initialize RoleService - it will load the current user's role automatically
      final roleService = RoleService.instance;
      await roleService.initialize();
      debugPrint('User role initialized successfully');
    } catch (e) {
      debugPrint('Role initialization error: $e');
    }
  }

  Future<void> _loadUserPreferences() async {
    // Load user preferences
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _verifyGeofencingCapabilities() async {
    // Verify NYC geofencing capabilities
    await Future.delayed(const Duration(milliseconds: 700));
  }

  Future<void> _prepareCachedVideoData() async {
    // Prepare video cache
    await Future.delayed(const Duration(milliseconds: 900));
  }

  void _navigateToNextScreen() async {
    _timeoutTimer?.cancel();
    _loadingTextTimer?.cancel();

    // Restore system UI before navigation
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Navigation logic based on reliable session checking
    String nextRoute;

    try {
      bool hasSession = await _supabaseService.hasValidSession();
      
      if (hasSession) {
        // Authenticated users go to Discovery Feed
        nextRoute = '/discovery-feed';
        debugPrint('Navigating to discovery feed - user is authenticated');
      } else {
        // Non-authenticated users go directly to login screen
        nextRoute = '/login-screen';
        debugPrint('Navigating to login screen - no valid session');
      }
    } catch (e) {
      // Fallback to login screen if session check fails
      nextRoute = '/login-screen';
      debugPrint('Session check failed, defaulting to login: $e');
    }

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  Future<bool> _checkInternetConnectivity() async {
    try {
      return await ConnectivityChecker.hasInternetConnection();
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
      return false;
    }
  }

  Future<void> _checkConnectivityAndShowRetry() async {
    // On timeout, we'll just proceed to app instead of showing connectivity error
    // The connectivity error should only show for genuine network failures
    if (mounted) {
      _navigateToNextScreen();
    }
  }

  bool _isNetworkError(dynamic error) {
    // Check if the error indicates a network connectivity issue
    String errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('socket') ||
           errorString.contains('failed to fetch') ||
           errorString.contains('xhr');
  }

  void _showConnectivityError() {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _showRetry = true;
        _hasConnectivityIssue = true;
      });
    }
  }

  void _retryInitialization() {
    setState(() {
      _isLoading = true;
      _showRetry = false;
      _hasConnectivityIssue = false;
    });
    _startInitialization();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: GradientBackgroundWidget(
          child: _showRetry ? _buildRetryView() : _buildSplashView(),
        ),
      ),
    );
  }

  Widget _buildSplashView() {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: AnimatedLogoWidget(
              onAnimationComplete: () {
                // Logo animation completed
              },
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingIndicatorWidget(
                loadingText: _loadingText.replaceAll('...', ''),
              ),
              const SizedBox(height: 16),
              // NYC Street Culture tagline
              Text(
                'Discover NYC Street Performers',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary.withOpacity(0.8),
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRetryView() {
    return Center(
      child: RetryConnectionWidget(
        onRetry: _retryInitialization,
        message: 'Unable to connect to YNFNY servers',
      ),
    );
  }
}
