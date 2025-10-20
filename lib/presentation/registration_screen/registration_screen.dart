import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ynfny/utils/responsive_scale.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../core/constants/user_roles.dart';
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
  String _accountType = UserRoles.performerLabel; // Default from previous screen
  List<String> _selectedPerformanceTypes = []; // Simplified: just category names
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
  
  // Username availability state
  bool _isUsernameChecking = false;
  bool? _isUsernameAvailable; // null = not checked yet, true = available, false = taken
  List<String> _usernameSuggestions = [];
  Timer? _usernameDebounceTimer;

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
      
      // Auto-check username availability if handle already exists
      if (_handleController.text.isNotEmpty) {
        _onUsernameChanged(_handleController.text);
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
    _usernameDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: RegistrationScreen build() - Current account type: $_accountType');
    print('DEBUG: Checking conditional: _accountType == UserRoles.performerLabel = ${_accountType == UserRoles.performerLabel}');
    print('DEBUG: UserRoles.performerLabel value: ${UserRoles.performerLabel}');
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
                    _accountType == UserRoles.performerLabel
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
                    onUsernameChanged: _onUsernameChanged,
                    isUsernameChecking: _isUsernameChecking,
                    isUsernameAvailable: _isUsernameAvailable,
                    usernameSuggestions: _usernameSuggestions,
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
                  if (_accountType == UserRoles.performerLabel) ...[
                    Builder(
                      builder: (context) {
                        return PerformerSpecificFields(
                      selectedPerformanceTypes: _selectedPerformanceTypes,
                      onCategoryToggled: (category, isSelected) {
                        setState(() {
                          if (isSelected) {
                            if (!_selectedPerformanceTypes.contains(category)) {
                              _selectedPerformanceTypes.add(category);
                            }
                          } else {
                            _selectedPerformanceTypes.remove(category);
                          }
                        });
                      },
                      instagramController: _instagramController,
                      tiktokController: _tiktokController,
                      youtubeController: _youtubeController,
                      selectedBirthDate: _selectedBirthDate,
                      onBirthDateChanged: (date) {
                        setState(() {
                          _selectedBirthDate = date;
                        });
                      },
                        );
                      },
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
      // Trigger username availability check
      _onUsernameChanged(selectedHandle);
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

  void _onUsernameChanged(String username) {
    _usernameDebounceTimer?.cancel();
    _usernameDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _checkUsernameAvailability(username);
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    // Remove @ symbol if present
    final cleanUsername = username.replaceAll('@', '').trim();
    
    if (cleanUsername.isEmpty || cleanUsername.length < 3) {
      setState(() {
        _isUsernameAvailable = null;
        _isUsernameChecking = false;
        _usernameSuggestions = [];
      });
      return;
    }

    setState(() {
      _isUsernameChecking = true;
      _isUsernameAvailable = null;
      _usernameSuggestions = [];
    });

    try {
      print('[USERNAME CHECK] Starting availability check for: $cleanUsername');
      final apiService = ApiService();
      
      // Check if username is available
      final isAvailable = await apiService.checkUsernameAvailability(cleanUsername);
      
      print('[USERNAME CHECK] API response received: $isAvailable');

      if (mounted) {
        setState(() {
          _isUsernameAvailable = isAvailable;
          _isUsernameChecking = false;
        });
        print('[USERNAME CHECK] ✅ Username ${isAvailable ? "AVAILABLE" : "TAKEN"}');

        // If not available, generate simple suggestions locally
        if (!isAvailable) {
          _generateUsernameSuggestions(cleanUsername);
        }
      }
    } catch (e) {
      print('[USERNAME CHECK] ❌ Error checking availability: $e');
      if (mounted) {
        setState(() {
          _isUsernameAvailable = null;
          _isUsernameChecking = false;
        });
        
        // Show user-visible error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to verify username availability. Please try again.'),
            backgroundColor: AppTheme.accentRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _generateUsernameSuggestions(String baseUsername) {
    // Generate simple local username suggestions
    final suggestions = <String>[];
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    
    suggestions.add('${baseUsername}_nyc');
    suggestions.add('${baseUsername}$random');
    suggestions.add('$baseUsername${_selectedBorough?.toLowerCase() ?? 'ny'}');
    
    if (_selectedPerformanceTypes.isNotEmpty) {
      suggestions.add('${baseUsername}_${_selectedPerformanceTypes.first.toLowerCase()}');
    }
    
    print('[USERNAME SUGGESTIONS] ✅ Generated ${suggestions.length} suggestions: $suggestions');
    setState(() {
      _usernameSuggestions = suggestions;
    });
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
    // Log why form might be disabled
    if (_isLoading) {
      debugPrint('[REGISTRATION] Form disabled: Loading in progress');
      return false;
    }
    if (_isEmailChecking) {
      debugPrint('[REGISTRATION] Form disabled: Email checking in progress');
      return false;
    }
    if (_isUsernameChecking) {
      debugPrint('[REGISTRATION] Form disabled: Username checking in progress');
      return false;
    }

    // Basic validation
    if (_fullNameController.text.trim().length < 2) {
      debugPrint('[REGISTRATION] Form disabled: Full name too short (${_fullNameController.text.trim().length} chars)');
      return false;
    }
    if (_emailError != null || _emailController.text.isEmpty) {
      debugPrint('[REGISTRATION] Form disabled: Email error or empty (error: $_emailError)');
      return false;
    }
    if (_passwordController.text.length < 8) {
      debugPrint('[REGISTRATION] Form disabled: Password too short (${_passwordController.text.length} chars)');
      return false;
    }
    if (_confirmPasswordController.text != _passwordController.text) {
      debugPrint('[REGISTRATION] Form disabled: Passwords do not match');
      return false;
    }
    if (_handleController.text.isEmpty) {
      debugPrint('[REGISTRATION] Form disabled: Handle is empty');
      return false;
    }
    // Ensure username is available
    if (_isUsernameAvailable != true) {
      debugPrint('[REGISTRATION] Form disabled: Username availability not confirmed (status: $_isUsernameAvailable)');
      return false;
    }
    if (!_isTermsAccepted) {
      debugPrint('[REGISTRATION] Form disabled: Terms not accepted');
      return false;
    }

    // Birthday validation for BOTH roles
    if (_selectedBirthDate == null) {
      debugPrint('[REGISTRATION] Form disabled: Birth date not selected');
      return false;
    }
    
    // Age validation for BOTH roles
    final now = DateTime.now();
    int age = now.year - _selectedBirthDate!.year;
    if (now.month < _selectedBirthDate!.month ||
        (now.month == _selectedBirthDate!.month &&
            now.day < _selectedBirthDate!.day)) {
      age--;
    }
    if (age < 18) {
      debugPrint('[REGISTRATION] Form disabled: User under 18 years old');
      return false;
    }
    
    // Account type specific validation
    if (_accountType == UserRoles.performerLabel) {
      if (_selectedPerformanceTypes.isEmpty) {
        debugPrint('[REGISTRATION] Form disabled: No performance types selected');
        return false;
      }
      if (!_isLocationVerified && _selectedBorough == null) {
        debugPrint('[REGISTRATION] Form disabled: Borough not selected');
        return false;
      }
      // At least one social media handle required
      if (_instagramController.text.trim().isEmpty &&
          _tiktokController.text.trim().isEmpty &&
          _youtubeController.text.trim().isEmpty) {
        debugPrint('[REGISTRATION] Form disabled: No social media handles provided');
        return false;
      }
    } else {
      if (_selectedBorough == null) {
        debugPrint('[REGISTRATION] Form disabled: Borough not selected');
        return false;
      }
    }

    debugPrint('[REGISTRATION] ✅ Form validation passed - Create Account button ENABLED');
    return true;
  }

  Future<void> _handleRegistration() async {
    print('🚀 CREATE ACCOUNT BUTTON PRESSED');
    debugPrint('[REGISTRATION] Starting registration flow');
    debugPrint('[REGISTRATION] Form validation check...');
    
    if (!_formKey.currentState!.validate()) {
      debugPrint('[REGISTRATION] ❌ Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields correctly'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }
    
    debugPrint('[REGISTRATION] ✅ Form validation passed');

    setState(() {
      _isLoading = true;
    });

    try {
      print('[API] Step 1: Starting registration...');
      final apiService = ApiService();
      
      // Determine account type
      final accountType = UserRoles.getCanonicalRole(_accountType);
      print('[API] Account type: $accountType');
      
      // Call API service to register
      print('[API] Step 2: Registering user: ${_emailController.text}');
      
      final response = await apiService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _handleController.text.trim(),
        fullName: _fullNameController.text.trim(),
        role: accountType,
        performanceTypes: accountType == 'street_performer' ? _selectedPerformanceTypes : null,
      );
      
      print('[API] ✅ Registration successful (user ID: ${response['user']['id']})');
      
      if (mounted) {
        // Show success message
        print('[UI] Showing success message to user');
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
                    accountType == 'street_performer'
                        ? 'Account created! Welcome to YNFNY.'
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

        // Navigate based on user role
        final userRole = response['user']['role'];
        print('[NAVIGATION] Navigating based on role: $userRole');
        
        if (userRole == 'street_performer') {
          Navigator.pushReplacementNamed(context, '/discovery-feed');
        } else {
          Navigator.pushReplacementNamed(context, '/discovery-feed');
        }
        print('[NAVIGATION] ✅ Navigation triggered successfully');
      }
    } catch (e) {
      print('[ERROR] ❌ Registration failed: $e');
      
      if (mounted) {
        // Extract specific error message
        String errorMessage;
        final errorStr = e.toString();
        
        if (errorStr.contains('already registered')) {
          errorMessage = 'Email already registered. Please use a different email.';
        } else if (errorStr.contains('Exception:')) {
          // Extract message after "Exception: "
          errorMessage = errorStr.replaceFirst('Exception:', '').trim();
        } else if (errorStr.contains('AuthException')) {
          errorMessage = 'Authentication error. Please check your email and password.';
        } else {
          errorMessage = 'Registration failed. Please try again.';
        }
        
        print('[ERROR] Showing error message to user: $errorMessage');
        
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
            duration: const Duration(seconds: 5),
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
