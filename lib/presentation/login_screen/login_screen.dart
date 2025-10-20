import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ynfny/utils/responsive_scale.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
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
  final ApiService _apiService = ApiService();

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
      debugPrint('[LOGIN] Attempting login with: $email');
      
      // API authentication
      final response = await _apiService.login(email: email, password: password);
      
      if (response['user'] != null) {
        debugPrint('[LOGIN] Sign in successful for: $email');
        
        // Successful login - trigger haptic feedback
        HapticFeedback.lightImpact();
        
        // Get user role and navigate based on role
        final role = response['user']['role'];
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
                          color: AppTheme.accentRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2.w),
                          border: Border.all(
                            color: AppTheme.accentRed.withOpacity(0.3),
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
