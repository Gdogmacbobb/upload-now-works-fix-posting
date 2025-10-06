import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ynfny/core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/role_service.dart';
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
  final AuthService _authService = AuthService();

  // Common form controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _handleController = TextEditingController();
  final _bioController = TextEditingController();

  // Performer-specific controllers
  final _instagramController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _youtubeController = TextEditingController();

  // Form state
  String _accountType = 'new_yorker'; // Default safe value
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
    _bioController.dispose();
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
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Type Header
                  AccountTypeHeader(accountType: _accountType),
                  SizedBox(height: AppSpacing.md),

                  // Welcome Message
                  Text(
                    'Join the NYC Street Performance Community',
                    style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    _accountType == 'street_performer'
                        ? 'Showcase your talent and connect with NYC audiences'
                        : 'Discover and support amazing street performers in your city',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Common Form Fields
                  CommonFormFields(
                    fullNameController: _fullNameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    handleController: _handleController,
                    bioController: _bioController,
                    onEmailChanged: _onEmailChanged,
                    onPasswordChanged: _onPasswordChanged,
                    onChangeHandle: _navigateToHandleCreation,
                    emailError: _emailError,
                    passwordError: _passwordError,
                    confirmPasswordError: _confirmPasswordError,
                    isEmailChecking: _isEmailChecking,
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // Password Strength Indicator
                  if (_passwordController.text.isNotEmpty)
                    Column(
                      children: [
                        PasswordStrengthIndicator(
                            password: _passwordController.text),
                        SizedBox(height: AppSpacing.md),
                      ],
                    ),

                  // Account Type Specific Fields
                  if (_accountType == 'street_performer') ...[
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
                    SizedBox(height: AppSpacing.md),

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
                  SizedBox(height: AppSpacing.md),

                  // Terms and Privacy
                  TermsAndPrivacyWidget(
                    isTermsAccepted: _isTermsAccepted,
                    onTermsChanged: (accepted) {
                      setState(() {
                        _isTermsAccepted = accepted;
                      });
                    },
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonMinHeight,
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
                  SizedBox(height: AppSpacing.sm),

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
                  SizedBox(height: AppSpacing.xs),
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

    // Note: We skip client-side email availability checking for security reasons.
    // Supabase will handle this during registration and return appropriate errors.
    try {
      // Simulate a quick check delay for UX, but don't actually check
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _emailError = null; // Always pass, let registration handle duplicates
          _isEmailChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _emailError = null;
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
    if (_accountType == 'street_performer') {
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
      // Map account type from selection to role slug
      final String roleSlug;
      switch (_accountType) {
        case 'street_performer':
          roleSlug = 'street_performer';
          break;
        case 'new_yorker':
          roleSlug = 'new_yorker';
          break;
        default:
          roleSlug = 'new_yorker'; // Safe default
      }

      // Prepare social media links for performers
      Map<String, String>? socialMediaLinks;
      if (roleSlug == 'street_performer') {
        socialMediaLinks = {};
        if (_instagramController.text.trim().isNotEmpty) {
          socialMediaLinks['instagram'] = _instagramController.text.trim();
        }
        if (_tiktokController.text.trim().isNotEmpty) {
          socialMediaLinks['tiktok'] = _tiktokController.text.trim();
        }
        if (_youtubeController.text.trim().isNotEmpty) {
          socialMediaLinks['youtube'] = _youtubeController.text.trim();
        }
      }

      // Create real Supabase account
      final response = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _handleController.text.trim(),
        fullName: _fullNameController.text.trim(),
        role: roleSlug,
        bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
        borough: _selectedBorough,
        performanceType: _selectedPerformanceType,
        frequentSpots: _selectedBorough, // Keep for legacy support
        socialMediaLinks: socialMediaLinks,
      );

      if (mounted) {
        if (response?.user != null) {
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
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Welcome to YNFNY! Your account is ready.',
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

          // Initialize user role before navigation
          await _initializeUserRoleAndNavigate();
        } else {
          throw Exception('Account creation failed');
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage;
        final errorString = e.toString().toLowerCase();
        
        if (errorString.contains('email already registered') || 
            errorString.contains('user already registered') ||
            errorString.contains('already been registered') ||
            errorString.contains('email already exists')) {
          errorMessage = 'This email is already in use, please choose a different one.';
        } else if (errorString.contains('email signups are disabled')) {
          errorMessage = 'Email signups are disabled in your Supabase project. Please enable Email/Password authentication in Supabase → Authentication → Settings.';
        } else if (errorString.contains('email not confirmed') || 
                   errorString.contains('confirm your email')) {
          errorMessage = 'Please check your email and click the confirmation link before signing in.';
        } else if (errorString.contains('signup disabled') || 
                   errorString.contains('signups disabled')) {
          errorMessage = 'New registrations are currently disabled. Please try again later.';
        } else if (errorString.contains('weak password') || 
                   errorString.contains('password')) {
          errorMessage = 'Password must be at least 8 characters long.';
        } else if (errorString.contains('invalid email')) {
          errorMessage = 'Please enter a valid email address.';
        } else if (errorString.contains('network') || 
                   errorString.contains('connection') ||
                   errorString.contains('xmlhttprequest error')) {
          errorMessage = 'Network error. Please check your connection and try again.';
        } else if (errorString.contains('rate limit') || 
                   errorString.contains('too many requests')) {
          errorMessage = 'Too many attempts. Please wait a moment and try again.';
        } else {
          // Show actual error for debugging  
          debugPrint('Registration error details: $e');
          errorMessage = 'Registration failed: ${e.toString().replaceFirst('Exception: ', '').replaceFirst('AuthException(message: ', '').replaceFirst(', statusCode: ', ' (Status: ').replaceFirst(')', ')')}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: AppTheme.accentRed,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
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

  Future<void> _initializeUserRoleAndNavigate() async {
    try {
      // Initialize RoleService - it will load the newly created user's role
      final roleService = RoleService.instance;
      await roleService.initialize();
      debugPrint('User role initialized after registration');
      
      // Navigate to discovery feed (main app screen)
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/discovery-feed');
      }
    } catch (e) {
      debugPrint('Role initialization error after registration: $e');
      // Fallback to discovery feed even if role loading fails
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/discovery-feed');
      }
    }
  }
}
