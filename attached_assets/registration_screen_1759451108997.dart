import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/account_type_header.dart';
import './widgets/common_form_fields.dart';
import './widgets/location_verification_widget.dart';
import './widgets/new_yorker_specific_fields.dart';
import './widgets/password_strength_indicator.dart';
import './widgets/performer_specific_fields.dart';
import './widgets/terms_and_privacy_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Common form controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _handleController = TextEditingController();

  // Performer-specific controllers
  final _instagramController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _youtubeController = TextEditingController();

  // Form state
  String _accountType = 'Street Performer'; // Default from previous screen
  String? _selectedPerformanceType;
  DateTime? _selectedBirthDate;
  String? _selectedBorough;
  bool _isLocationVerified = false;
  bool _isTermsAccepted = false;
  bool _isLoading = false;

  // Validation state
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isEmailChecking = false;
  Timer? _emailDebounceTimer;

  // Mock user data for testing
  final List<Map<String, dynamic>> existingUsers = [
    {
      "email": "performer@test.com",
      "type": "performer",
      "name": "Test Performer"
    },
    {
      "email": "newyorker@test.com",
      "type": "newyorker",
      "name": "Test New Yorker"
    },
    {"email": "admin@ynfny.com", "type": "admin", "name": "YNFNY Admin"}
  ];

  @override
  void initState() {
    super.initState();
    // Get account type from previous screen arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['accountType'] != null) {
        setState(() {
          _accountType = args['accountType'];
        });
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _handleController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _youtubeController.dispose();
    _scrollController.dispose();
    _emailDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textPrimary,
            size: 24,
          ),
        ),
        title: Text(
          'Create Account',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Type Header
                  AccountTypeHeader(accountType: _accountType),
                  SizedBox(height: 4.h),

                  // Welcome Message
                  Text(
                    'Join the NYC Street Performance Community',
                    style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _accountType == 'Street Performer'
                        ? 'Showcase your talent and connect with NYC audiences'
                        : 'Discover and support amazing street performers in your city',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Common Form Fields
                  CommonFormFields(
                    fullNameController: _fullNameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    handleController: _handleController,
                    onEmailChanged: _onEmailChanged,
                    onPasswordChanged: _onPasswordChanged,
                    onChangeHandle: _navigateToHandleCreation,
                    emailError: _emailError,
                    passwordError: _passwordError,
                    confirmPasswordError: _confirmPasswordError,
                    isEmailChecking: _isEmailChecking,
                  ),
                  SizedBox(height: 3.h),

                  // Password Strength Indicator
                  if (_passwordController.text.isNotEmpty)
                    Column(
                      children: [
                        PasswordStrengthIndicator(
                            password: _passwordController.text),
                        SizedBox(height: 4.h),
                      ],
                    ),

                  // Account Type Specific Fields
                  if (_accountType == 'Street Performer') ...[
                    PerformerSpecificFields(
                      selectedPerformanceType: _selectedPerformanceType,
                      onPerformanceTypeChanged: (type) {
                        setState(() {
                          _selectedPerformanceType = type;
                        });
                      },
                      instagramController: _instagramController,
                      tiktokController: _tiktokController,
                      youtubeController: _youtubeController,
                    ),
                    SizedBox(height: 4.h),

                    // Location Verification for Performers
                    LocationVerificationWidget(
                      isLocationVerified: _isLocationVerified,
                      onVerifyLocation: () {
                        setState(() {
                          _isLocationVerified = true;
                        });
                      },
                      selectedBorough: _selectedBorough,
                      onBoroughChanged: (borough) {
                        setState(() {
                          _selectedBorough = borough;
                          if (borough != null) {
                            _isLocationVerified = true;
                          }
                        });
                      },
                    ),
                  ] else ...[
                    NewYorkerSpecificFields(
                      selectedBirthDate: _selectedBirthDate,
                      onBirthDateChanged: (date) {
                        setState(() {
                          _selectedBirthDate = date;
                        });
                      },
                      selectedBorough: _selectedBorough,
                      onBoroughChanged: (borough) {
                        setState(() {
                          _selectedBorough = borough;
                        });
                      },
                    ),
                  ],
                  SizedBox(height: 4.h),

                  // Terms and Privacy
                  TermsAndPrivacyWidget(
                    isTermsAccepted: _isTermsAccepted,
                    onTermsChanged: (accepted) {
                      setState(() {
                        _isTermsAccepted = accepted;
                      });
                    },
                  ),
                  SizedBox(height: 4.h),

                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: _canSubmitForm() ? _handleRegistration : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canSubmitForm()
                            ? AppTheme.primaryOrange
                            : AppTheme.borderSubtle,
                        foregroundColor: _canSubmitForm()
                            ? AppTheme.backgroundDark
                            : AppTheme.textSecondary,
                        elevation: _canSubmitForm() ? 2 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.backgroundDark,
                                ),
                              ),
                            )
                          : Text(
                              'Create Account',
                              style: AppTheme.darkTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Login Link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, '/login-screen');
                      },
                      child: RichText(
                        text: TextSpan(
                          style:
                              AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                color: AppTheme.primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToHandleCreation() async {
    final selectedHandle = await Navigator.pushNamed(
      context,
      '/handle-creation-screen',
    ) as String?;

    if (selectedHandle != null) {
      setState(() {
        _handleController.text = selectedHandle;
      });
    }
  }

  void _onEmailChanged(String email) {
    _emailDebounceTimer?.cancel();
    _emailDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _checkEmailAvailability(email);
    });
  }

  void _onPasswordChanged(String password) {
    setState(() {
      _passwordError = null;
      if (_confirmPasswordController.text.isNotEmpty) {
        _validateConfirmPassword();
      }
    });
  }

  Future<void> _checkEmailAvailability(String email) async {
    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _emailError = null;
        _isEmailChecking = false;
      });
      return;
    }

    setState(() {
      _isEmailChecking = true;
      _emailError = null;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Check against mock existing users
      final existingUser = existingUsers.any((user) =>
          (user['email'] as String).toLowerCase() == email.toLowerCase());

      if (mounted) {
        setState(() {
          _emailError =
              existingUser ? 'This email is already registered' : null;
          _isEmailChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _emailError = 'Unable to verify email availability';
          _isEmailChecking = false;
        });
      }
    }
  }

  void _validateConfirmPassword() {
    if (_confirmPasswordController.text != _passwordController.text) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
    } else {
      setState(() {
        _confirmPasswordError = null;
      });
    }
  }

  bool _canSubmitForm() {
    if (_isLoading || _isEmailChecking) return false;

    // Basic validation
    if (_fullNameController.text.trim().length < 2) return false;
    if (_emailError != null || _emailController.text.isEmpty) return false;
    if (_passwordController.text.length < 8) return false;
    if (_confirmPasswordController.text != _passwordController.text)
      return false;
    if (_handleController.text.isEmpty) return false;
    if (!_isTermsAccepted) return false;

    // Account type specific validation
    if (_accountType == 'Street Performer') {
      if (_selectedPerformanceType == null) return false;
      if (!_isLocationVerified && _selectedBorough == null) return false;
      // At least one social media handle required
      if (_instagramController.text.trim().isEmpty &&
          _tiktokController.text.trim().isEmpty &&
          _youtubeController.text.trim().isEmpty) return false;
    } else {
      if (_selectedBirthDate == null) return false;
      if (_selectedBorough == null) return false;
      // Age validation
      final age = DateTime.now().year - _selectedBirthDate!.year;
      if (age < 18) return false;
    }

    return true;
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate registration API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful registration
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.successGreen,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    _accountType == 'Street Performer'
                        ? 'Account created! Check your email for verification.'
                        : 'Welcome to YNFNY! Your account is ready.',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.darkTheme.colorScheme.surface,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to appropriate screen
        if (_accountType == 'Street Performer') {
          // Performers need email verification
          Navigator.pushReplacementNamed(context, '/login-screen');
        } else {
          // New Yorkers can go directly to discovery feed
          Navigator.pushReplacementNamed(context, '/discovery-feed');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: AppTheme.accentRed,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Registration failed. Please try again.',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.darkTheme.colorScheme.surface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
