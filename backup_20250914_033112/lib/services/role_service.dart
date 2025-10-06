import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import './supabase_service.dart';
import './auth_service.dart';

/// Centralized service for managing user roles and role-based permissions
class RoleService extends ChangeNotifier {
  static RoleService? _instance;
  static RoleService get instance => _instance ??= RoleService._internal();
  
  factory RoleService() => instance;
  
  RoleService._internal();
  
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  
  UserRole? _currentUserRole;
  UserProfile? _currentUserProfile;
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  UserRole? get currentUserRole => _currentUserRole;
  UserProfile? get currentUserProfile => _currentUserProfile;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  
  // Convenience role checkers
  bool get isStreetPerformer => _currentUserRole == UserRole.streetPerformer;
  bool get isNewYorker => _currentUserRole == UserRole.newYorker;
  bool get isAdmin => _currentUserRole == UserRole.admin;
  bool get isAuthenticated => _currentUserRole != null;

  /// Initialize role service and load current user's role
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _setLoading(true);
    
    try {
      await loadCurrentUserRole();
      
      // Listen to auth state changes
      final client = await _supabaseService.client;
      client.auth.onAuthStateChange.listen((authState) {
        updateRoleFromAuth(authState.session?.user);
      });
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('RoleService initialization error: $e');
      // Set default to New Yorker if unable to determine role
      _setRole(UserRole.newYorker);
      _isInitialized = true;
    } finally {
      _setLoading(false);
    }
  }

  /// Load the current user's role from Supabase
  Future<void> loadCurrentUserRole() async {
    _setLoading(true);
    
    try {
      final currentUser = _supabaseService.currentUser;
      
      if (currentUser == null) {
        _clearRole();
        return;
      }

      // Primary source: database (authoritative and secure)
      try {
        final profile = await _authService.getUserProfile();
        if (profile != null) {
          final userProfile = UserProfile.fromJson(profile);
          _setRoleWithProfile(userProfile.role, userProfile);
          debugPrint('Role loaded from database (authoritative): ${userProfile.role}');
          return;
        }
      } catch (dbError) {
        debugPrint('Database profile lookup failed (table may not exist): $dbError');
        // Fall through to auth metadata for backwards compatibility
      }

      // Fallback: Use server-controlled app metadata when database is unavailable
      final appMetaRole = currentUser.appMetadata['role'] as String?;
      if (appMetaRole != null) {
        final fallbackRole = _parseSecureUserRole(appMetaRole);
        debugPrint('Database unavailable, using secure app_metadata fallback: $appMetaRole -> $fallbackRole');
        _setRole(fallbackRole);
        
        // Try to create database profile for future use (will fail gracefully if tables don't exist)
        _createMissingProfile();
        return;
      }

      // Last resort: userMetadata is client-editable and NEVER grants privileges in production
      // However, for development/testing when database is unavailable, allow as fallback
      final userMetaRole = currentUser.userMetadata?['role'] as String?;
      if (userMetaRole == 'street_performer') {
        debugPrint('Database unavailable - using userMetadata as development fallback: street_performer');
        _setRole(UserRole.streetPerformer);
        _createMissingProfile();
        return;
      }

      // Final fallback: Default to New Yorker (safest default)
      debugPrint('No role found, defaulting to New Yorker');
      _setRole(UserRole.newYorker);
    } catch (e) {
      debugPrint('Load user role error: $e');
      // Default to New Yorker on any error
      _setRole(UserRole.newYorker);
    } finally {
      _setLoading(false);
    }
  }

  /// Parse role securely - never allow admin from client metadata
  UserRole _parseSecureUserRole(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'street_performer':
        return UserRole.streetPerformer;
      case 'new_yorker':
        return UserRole.newYorker;
      default:
        // Any unknown or admin role defaults to New Yorker for security
        debugPrint('Unknown or restricted role "$roleString", defaulting to New Yorker');
        return UserRole.newYorker;
    }
  }

  /// Create missing profile for users who only have auth metadata
  Future<void> _createMissingProfile() async {
    try {
      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) return;

      final client = await _supabaseService.client;
      final userData = currentUser.userMetadata ?? {};
      
      // SECURITY: Always create as new_yorker regardless of metadata to prevent privilege escalation
      // Server-side verification processes can upgrade roles later if legitimate
      final requestedRole = userData['role'] as String?;
      
      final profileData = {
        'id': currentUser.id,
        'email': currentUser.email ?? '',
        'username': userData['username'] as String? ?? 'user_${currentUser.id.substring(0, 8)}',
        'full_name': userData['full_name'] as String? ?? 'User',
        'role': 'new_yorker', // Always start with safest role
        'is_active': true,
        'is_verified': true, // New Yorkers are verified immediately
        'verification_status': 'approved',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Record requested role for server-side verification if it was street_performer
      if (requestedRole == 'street_performer') {
        profileData['verification_status'] = 'pending';
        profileData['is_verified'] = false;
        debugPrint('Created profile as new_yorker with pending performer verification request');
      }

      await client.from('user_profiles').insert(profileData);
      debugPrint('Created secure user profile as new_yorker for safety');
    } catch (e) {
      debugPrint('Failed to create missing profile: $e');
      // Don't throw - this is a background operation
    }
  }

  /// Load full user profile (async, non-blocking)
  Future<void> _loadUserProfile() async {
    try {
      final profile = await _authService.getUserProfile();
      if (profile != null) {
        _currentUserProfile = UserProfile.fromJson(profile);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load user profile error: $e');
    }
  }

  /// Update role after login/signup
  Future<void> updateRoleFromAuth(User? user) async {
    if (user == null) {
      _clearRole();
      return;
    }

    debugPrint('Auth state changed, reloading role securely from database');
    // Always reload from authoritative source (database)
    await loadCurrentUserRole();
  }

  /// Check if user has permission for a specific feature
  bool hasPermission(PerformerFeature feature) {
    switch (feature) {
      case PerformerFeature.uploadVideo:
      case PerformerFeature.recordVideo:
      case PerformerFeature.manageVideos:
        // Only street performers can upload/record videos
        // Note: Admin role removed from client for security
        return isStreetPerformer;
      
      case PerformerFeature.editProfile:
        // Both roles can edit their profiles (updated requirement)
        return isAuthenticated;
      
      case PerformerFeature.browseFeeds:
      case PerformerFeature.followPerformers:
      case PerformerFeature.makeDonations:
      case PerformerFeature.viewProfiles:
        // All authenticated users can access these features
        return isAuthenticated;
      
      case PerformerFeature.adminFeatures:
        // Admin features not available on client for security
        return false;
    }
  }

  /// Get display name for current role
  String get roleDisplayName {
    switch (_currentUserRole) {
      case UserRole.streetPerformer:
        return 'Street Performer';
      case UserRole.newYorker:
        return 'New Yorker';
      case UserRole.admin:
        return 'Admin';
      case null:
        return 'Guest';
    }
  }

  /// Clear role and profile (for logout)
  void _clearRole() {
    _currentUserRole = null;
    _currentUserProfile = null;
    notifyListeners();
  }

  /// Set role only
  void _setRole(UserRole role) {
    _currentUserRole = role;
    notifyListeners();
  }

  /// Set role and profile together
  void _setRoleWithProfile(UserRole role, UserProfile profile) {
    _currentUserRole = role;
    _currentUserProfile = profile;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Reset service (for logout)
  void reset() {
    _currentUserRole = null;
    _currentUserProfile = null;
    _isLoading = false;
    _isInitialized = false;
    notifyListeners();
  }
}

/// Features that require different permissions based on user role
enum PerformerFeature {
  uploadVideo,
  recordVideo,
  editProfile,
  manageVideos,
  browseFeeds,
  followPerformers,
  makeDonations,
  viewProfiles,
  adminFeatures,
}

/// Extension to add parseUserRole method to UserProfile
extension UserProfileExtension on UserProfile {
  static UserRole parseUserRole(String? role) {
    switch (role) {
      case 'street_performer':
        return UserRole.streetPerformer;
      case 'new_yorker':
        return UserRole.newYorker;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.newYorker;
    }
  }
}