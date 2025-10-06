import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ynfny/core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/role_service.dart';
import './widgets/login_footer_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/login_header_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Set status bar style for dark theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.backgroundDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use real Supabase authentication
      final response = await _authService.signIn(
        email: email.trim(),
        password: password,
      );

      if (response?.user != null) {
        // Successful login - trigger haptic feedback
        HapticFeedback.lightImpact();

        // Initialize user role before navigation
        await _initializeUserRoleAndNavigate();
      } else {
        // Handle unexpected case where response exists but no user
        setState(() {
          _errorMessage = 'Login failed. Please try again.';
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      // Handle authentication errors
      String errorMessage;
      final errorString = e.toString().toLowerCase();
      
      if (errorString.contains('invalid login credentials') || 
          errorString.contains('invalid email or password')) {
        errorMessage = 'Invalid email or password. Please check your credentials and try again.';
      } else if (errorString.contains('email not confirmed')) {
        errorMessage = 'Please check your email and click the confirmation link before signing in.';
      } else if (errorString.contains('network') || errorString.contains('connection')) {
        errorMessage = 'Network error. Please check your connection and try again.';
      } else {
        errorMessage = 'Login failed. Please try again.';
      }

      setState(() {
        _errorMessage = errorMessage;
      });
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initializeUserRoleAndNavigate() async {
    try {
      // Initialize RoleService - it will load the current user's role automatically
      final roleService = RoleService.instance;
      await roleService.initialize();
      debugPrint('User role initialized after login');
      
      // Navigate to discovery feed (main app screen)
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/discovery-feed');
      }
    } catch (e) {
      debugPrint('Role initialization error: $e');
      // Fallback to discovery feed even if role loading fails
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/discovery-feed');
      }
    }
  }

  void _dismissError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Dismiss keyboard and error message when tapping outside
            FocusScope.of(context).unfocus();
            _dismissError();
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Header with logo and branding
                    const LoginHeaderWidget(),

                    const SizedBox(height: 16),

                    // Error message display
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 8.0),
                        decoration: BoxDecoration(
                          color: AppTheme.accentRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: AppTheme.accentRed.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppTheme.accentRed,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.accentRed,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _dismissError,
                              child: Icon(
                                Icons.close,
                                color: AppTheme.accentRed,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Login form
                    LoginFormWidget(
                      onLogin: _handleLogin,
                      isLoading: _isLoading,
                    ),

                    // Footer with additional options
                    const LoginFooterWidget(),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
