import 'dart:async';
<<<<<<< HEAD
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ynfny/utils/responsive_scale.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import '../../core/constants/user_roles.dart';
import '../../config/supabase_config.dart';
=======

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
  String _accountType = UserRoles.performerLabel; // Default from previous screen
  List<String> _selectedPerformanceTypes = []; // Simplified: just category names
=======
  String _accountType = 'Street Performer'; // Default from previous screen
  String? _selectedPerformanceType;
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
  
  // Username availability state
  bool _isUsernameChecking = false;
  bool? _isUsernameAvailable; // null = not checked yet, true = available, false = taken
  List<String> _usernameSuggestions = [];
  Timer? _usernameDebounceTimer;
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

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
<<<<<<< HEAD
      
      // Auto-check username availability if handle already exists
      if (_handleController.text.isNotEmpty) {
        _onUsernameChanged(_handleController.text);
      }
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
    _usernameDebounceTimer?.cancel();
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    print('DEBUG: RegistrationScreen build() - Current account type: $_accountType');
    print('DEBUG: Checking conditional: _accountType == UserRoles.performerLabel = ${_accountType == UserRoles.performerLabel}');
    print('DEBUG: UserRoles.performerLabel value: ${UserRoles.performerLabel}');
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
                    _accountType == UserRoles.performerLabel
=======
                    _accountType == 'Street Performer'
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
                    onUsernameChanged: _onUsernameChanged,
                    isUsernameChecking: _isUsernameChecking,
                    isUsernameAvailable: _isUsernameAvailable,
                    usernameSuggestions: _usernameSuggestions,
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
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
=======
                  if (_accountType == 'Street Performer') ...[
                    PerformerSpecificFields(
                      selectedPerformanceType: _selectedPerformanceType,
                      onPerformanceTypeChanged: (type) {
                        setState(() {
                          _selectedPerformanceType = type;
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                        });
                      },
                      instagramController: _instagramController,
                      tiktokController: _tiktokController,
                      youtubeController: _youtubeController,
<<<<<<< HEAD
                      selectedBirthDate: _selectedBirthDate,
                      onBirthDateChanged: (date) {
                        setState(() {
                          _selectedBirthDate = date;
                        });
                      },
                        );
                      },
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
      // Trigger username availability check
      _onUsernameChanged(selectedHandle);
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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

<<<<<<< HEAD
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
      final supabaseService = SupabaseService();
      
      // CRITICAL: Wait for Supabase initialization before using client
      await supabaseService.waitForInitialization();
      print('[USERNAME CHECK] Supabase initialized, calling RPC...');
      
      // Check if client is null
      if (supabaseService.client == null) {
        print('[USERNAME CHECK] ERROR: Supabase client is null after initialization');
        throw Exception('Supabase client not initialized');
      }
      
      // Check if username is available
      final response = await supabaseService.client!
          .rpc('check_username_availability', params: {'p_username': cleanUsername});
      
      print('[USERNAME CHECK] RPC response received: $response');
      final isAvailable = response as bool;

      if (mounted) {
        setState(() {
          _isUsernameAvailable = isAvailable;
          _isUsernameChecking = false;
        });
        print('[USERNAME CHECK] ✅ Username ${isAvailable ? "AVAILABLE" : "TAKEN"}');

        // If not available, get suggestions
        if (!isAvailable) {
          _getUsernameSuggestions(cleanUsername);
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

  Future<void> _getUsernameSuggestions(String baseUsername) async {
    try {
      print('[USERNAME SUGGESTIONS] Getting suggestions for: $baseUsername');
      final supabaseService = SupabaseService();
      
      // CRITICAL: Wait for Supabase initialization before using client
      await supabaseService.waitForInitialization();
      print('[USERNAME SUGGESTIONS] Supabase initialized, calling RPC...');
      
      // Check if client is null
      if (supabaseService.client == null) {
        print('[USERNAME SUGGESTIONS] ERROR: Supabase client is null');
        return;
      }
      
      final response = await supabaseService.client!.rpc(
        'get_username_suggestions',
        params: {
          'p_username': baseUsername,
          'p_borough': _selectedBorough,
          'p_performance_types': _selectedPerformanceTypes.isEmpty 
              ? null 
              : _selectedPerformanceTypes,
        },
      );

      if (mounted && response != null) {
        final suggestions = (response as List).cast<String>();
        print('[USERNAME SUGGESTIONS] ✅ Got ${suggestions.length} suggestions: $suggestions');
        setState(() {
          _usernameSuggestions = suggestions;
        });
      }
    } catch (e) {
      print('[USERNAME SUGGESTIONS] ❌ Error getting suggestions: $e');
    }
  }

=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
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
=======
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

>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
    return true;
  }

  Future<void> _handleRegistration() async {
<<<<<<< HEAD
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
=======
    if (!_formKey.currentState!.validate()) return;
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

    setState(() {
      _isLoading = true;
    });

    try {
<<<<<<< HEAD
      print('[SUPABASE] Step 1: Checking connectivity...');
      // Check Supabase connectivity first
      final supabaseService = SupabaseService();
      final isConnected = await supabaseService.checkSupabaseConnection();
      
      if (!isConnected) {
        print('[SUPABASE] ❌ Connectivity check failed');
        throw Exception('Unable to connect to server. Please check your internet connection and try again.');
      }
      print('[SUPABASE] ✅ Connectivity confirmed');
      
      // Real Supabase registration
      await supabaseService.waitForInitialization();
      
      // Determine account type for Supabase
      final accountType = UserRoles.getCanonicalRole(_accountType);
      print('[SUPABASE] Account type: $accountType');
      
      // Prepare user metadata
      final Map<String, dynamic> metadata = {
        'account_type': accountType,
        'full_name': _fullNameController.text.trim(),
        'handle': _handleController.text.trim(),
        'borough': _selectedBorough,
      };
      
      // Add birthday for BOTH roles
      if (_selectedBirthDate != null) {
        metadata['birthday'] = _selectedBirthDate!.toIso8601String().split('T').first;
      }
      
      // Add role-specific metadata
      if (accountType == 'street_performer') {
        metadata['performance_types'] = _selectedPerformanceTypes;
        metadata['instagram'] = _instagramController.text.trim();
        metadata['tiktok'] = _tiktokController.text.trim();
        metadata['youtube'] = _youtubeController.text.trim();
      }
      
      print('[SUPABASE] Step 2: Creating auth account for: ${_emailController.text}');
      
      final response = await supabaseService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: metadata,
      );
      
      if (response.user != null) {
        print('[SUPABASE] ✅ Auth account created successfully (user ID: ${response.user!.id})');
        
        try {
          print('[SUPABASE] Step 3: Preparing profile data...');
          // Update user profile in database (trigger already created base row)
          final profileData = <String, dynamic>{
            'email': _emailController.text.trim(),
            'username': _handleController.text.trim(),
            'full_name': _fullNameController.text.trim(),
            'role': accountType,
            'borough': _selectedBorough,
            'is_active': true,
            'is_verified': false,
            'total_donations_received': 0,
          };
          
          // Add birthday for BOTH roles
          if (_selectedBirthDate != null) {
            profileData['birthday'] = _selectedBirthDate!.toIso8601String().split('T').first;
            print('[SUPABASE] Birthday: ${profileData['birthday']}');
          }
          
          // Add role-specific fields
          if (accountType == 'street_performer') {
            print('[SUPABASE] Performance types: $_selectedPerformanceTypes');
            profileData['performance_types'] = _selectedPerformanceTypes;
            profileData['socials_instagram'] = _instagramController.text.trim().isNotEmpty 
                ? _instagramController.text.trim() 
                : null;
            profileData['socials_tiktok'] = _tiktokController.text.trim().isNotEmpty 
                ? _tiktokController.text.trim() 
                : null;
            profileData['socials_youtube'] = _youtubeController.text.trim().isNotEmpty 
                ? _youtubeController.text.trim() 
                : null;
          }
          
          print('[SUPABASE] Step 4: Updating trigger-created profile in user_profiles table...');
          print('[SUPABASE] Profile data: $profileData');
          
          // Update the profile row that was auto-created by Supabase trigger
          final updateResponse = await supabaseService.client
              .from('user_profiles')
              .update(profileData)
              .eq('id', response.user!.id)
              .select();
          
          // Verify update succeeded
          if (updateResponse == null || updateResponse.isEmpty) {
            throw Exception('Profile update failed: trigger-created profile not found');
          }
          
          print('[SUPABASE] ✅ Profile updated successfully in database');
          print('[SECURITY] ✅ Registration complete with birthday: ${profileData['birthday']}');
        } catch (profileError) {
          // Profile update failed - clean up by deleting the newly created auth user
          print('[SECURITY] ❌ Profile update FAILED: $profileError');
          print('[SECURITY] Rolling back auth account to prevent orphaned records...');
          
          try {
            // Call Edge Function to delete auth user
            final deleteUrl = Uri.parse('${AppSupabase.url}/functions/v1/delete-auth-user');
            
            final deleteResponse = await http.post(
              deleteUrl,
              headers: {
                'Authorization': 'Bearer ${AppSupabase.anonKey}',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({'userId': response.user!.id}),
            );
            
            if (deleteResponse.statusCode == 200) {
              print('[SECURITY] ✅ Orphaned auth account deleted successfully');
            } else {
              print('[SECURITY] ⚠️ Failed to delete auth user: ${deleteResponse.body}');
              print('[SECURITY] ⚠️ Orphaned auth account may remain in system');
            }
          } catch (cleanupError) {
            print('[SECURITY] ❌ Failed to call rollback function: $cleanupError');
            print('[SECURITY] ⚠️ Orphaned auth account may remain in system');
          }
          
          // Determine specific error message
          final errorMessage = profileError.toString();
          if (errorMessage.contains('duplicate key') || 
              errorMessage.contains('unique constraint') ||
              errorMessage.contains('username') ||
              errorMessage.contains('23505')) {
            throw Exception('Username "@${_handleController.text.trim()}" is already taken. Please choose a different handle.');
          } else if (errorMessage.contains('permission') || errorMessage.contains('RLS')) {
            throw Exception('Database permission error. Please contact support.');
          } else if (errorMessage.contains('trigger-created profile not found')) {
            throw Exception('Registration failed: Database trigger issue. Please try again or contact support.');
          } else {
            throw Exception('Failed to update profile: ${profileError.toString()}');
          }
        }
        
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

          // Navigate to discovery page after successful registration
          print('[NAVIGATION] Step 5: Navigating to /discovery-feed page...');
          print('[SECURITY] ✅ Registration and navigation complete');
          Navigator.pushReplacementNamed(context, '/discovery-feed');
          print('[NAVIGATION] ✅ Navigation triggered successfully');
        }
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
        
=======
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
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
                Expanded(
                  child: Text(
                    errorMessage,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
=======
                Text(
                  'Registration failed. Please try again.',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.darkTheme.colorScheme.surface,
            behavior: SnackBarBehavior.floating,
<<<<<<< HEAD
            duration: const Duration(seconds: 5),
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
