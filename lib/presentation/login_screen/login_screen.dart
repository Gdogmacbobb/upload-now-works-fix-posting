import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'package:ynfny/utils/responsive_scale.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
=======
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
  final SupabaseService _supabaseService = SupabaseService();
=======

  // Mock credentials for testing
  final Map<String, Map<String, String>> _mockCredentials = {
    'performer@ynfny.com': {
      'password': 'performer123',
      'type': 'performer',
      'name': 'Marcus Rodriguez'
    },
    'newyorker@ynfny.com': {
      'password': 'newyorker123',
      'type': 'newyorker',
      'name': 'Sarah Chen'
    },
    'admin@ynfny.com': {
      'password': 'admin123',
      'type': 'admin',
      'name': 'Admin User'
    },
  };
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

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
<<<<<<< HEAD
      debugPrint('[LOGIN] Attempting login with: $email');
      
      // Real Supabase authentication
      await _supabaseService.waitForInitialization();
      final response = await _supabaseService.signInWithPassword(email, password);
      
      if (response.session != null && response.user != null) {
        debugPrint('[LOGIN] Sign in successful for: $email');
        
        // Successful login - trigger haptic feedback
        HapticFeedback.lightImpact();
        
        // Get user role and navigate based on role
        final role = await _supabaseService.getUserRole();
        debugPrint('[LOGIN] User role: $role');
        
        if (mounted) {
          if (role == 'street_performer') {
            // Navigate to discovery feed for performers 
            Navigator.pushReplacementNamed(context, '/discovery-feed');
          } else if (role == 'new_yorker') {
            // Navigate to following feed for New Yorkers
            Navigator.pushReplacementNamed(context, '/following-feed');
          } else {
            // Default to discovery feed if role is unclear
            Navigator.pushReplacementNamed(context, '/discovery-feed');
          }
        }
        return;
      }
      
      // If we get here, login failed
      setState(() {
        _errorMessage = 'Invalid email or password. Please check your credentials and try again.';
      });
      HapticFeedback.mediumImpact();
      
    } catch (e) {
      debugPrint('[LOGIN] Authentication error: $e');
      
      setState(() {
        if (e.toString().contains('Invalid login credentials')) {
          _errorMessage = 'Invalid email or password. Please check your credentials and try again.';
        } else if (e.toString().contains('network') || e.toString().contains('connection')) {
          _errorMessage = 'Network error. Please check your connection and try again.';
        } else {
          _errorMessage = 'Login failed. Please try again later.';
        }
=======
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Check mock credentials
      if (_mockCredentials.containsKey(email.toLowerCase())) {
        final userCredentials = _mockCredentials[email.toLowerCase()]!;
        if (userCredentials['password'] == password) {
          // Successful login - trigger haptic feedback
          HapticFeedback.lightImpact();

          // Navigate to following feed
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/following-feed');
          }
          return;
        }
      }

      // Invalid credentials
      setState(() {
        _errorMessage =
            'Invalid email or password. Please check your credentials and try again.';
      });

      // Error haptic feedback
      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _errorMessage =
            'Network error. Please check your connection and try again.';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),

                    // Header with logo and branding
                    const LoginHeaderWidget(),

                    SizedBox(height: 4.h),

                    // Error message display
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(3.w),
                        margin: EdgeInsets.only(bottom: 2.h),
                        decoration: BoxDecoration(
<<<<<<< HEAD
                          color: AppTheme.accentRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2.w),
                          border: Border.all(
                            color: AppTheme.accentRed.withOpacity(0.3),
=======
                          color: AppTheme.accentRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2.w),
                          border: Border.all(
                            color: AppTheme.accentRed.withValues(alpha: 0.3),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'error_outline',
                              color: AppTheme.accentRed,
                              size: 5.w,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTheme.darkTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.accentRed,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _dismissError,
                              child: CustomIconWidget(
                                iconName: 'close',
                                color: AppTheme.accentRed,
                                size: 4.w,
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

                    SizedBox(height: 2.h),
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
