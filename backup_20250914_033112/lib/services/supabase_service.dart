import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient _client;
  bool _isInitialized = false;
  final Future<void> _initFuture;

  // Singleton pattern
  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal() : _initFuture = _initializeSupabase();

  // Use hardened configuration constants
  static const String supabaseUrl = SupabaseConfig.supabaseUrl;
  static const String supabaseAnonKey = SupabaseConfig.supabaseAnonKey;

  // Internal initialization logic - now assumes Supabase is already initialized in main.dart
  static Future<void> _initializeSupabase() async {
    if (!SupabaseConfig.isValid) {
      throw Exception(SupabaseConfig.configErrorMessage);
    }

    // Supabase should already be initialized in main.dart
    // Just get the client instance and mark as initialized
    _instance._client = Supabase.instance.client;
    _instance._isInitialized = true;
  }

  // Client getter (async)
  Future<SupabaseClient> get client async {
    if (!_isInitialized) {
      await _initFuture;
    }
    return _client;
  }

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // SECURITY: User context now set by secure backend only
  // Client-side context setting removed to prevent privilege escalation

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Wait for initial session to be restored (event-driven approach)
  Future<Session?> waitForInitialSession({Duration? timeout}) async {
    if (!_isInitialized) {
      await _initFuture;
    }
    
    // Check if session already exists
    final existing = _client.auth.currentSession;
    if (existing != null) return existing;
    
    // Use web-friendly timeout (longer for IndexedDB restoration)
    final effectiveTimeout = timeout ?? (kIsWeb ? const Duration(seconds: 10) : const Duration(seconds: 3));
    
    try {
      // Wait for any auth state change event including initialSession
      final authState = await _client.auth.onAuthStateChange
          .first
          .timeout(effectiveTimeout);
      
      // Return the session from the event or current session
      return authState.session ?? _client.auth.currentSession;
    } catch (e) {
      debugPrint('Auth bootstrap timeout: $e');
      // Fallback to current session (may be null)
      return _client.auth.currentSession;
    }
  }

  // Check if user has valid session (async version for better reliability)
  Future<bool> hasValidSession() async {
    try {
      final session = await waitForInitialSession();
      // Trust Supabase to handle token refresh automatically
      // Just check if session exists - no manual expiry needed
      return session != null;
    } catch (e) {
      debugPrint('Session check error: $e');
      return false;
    }
  }

  // Get user role
  Future<String?> getUserRole() async {
    if (!isAuthenticated) return null;

    try {
      final response = await _client
          .from('user_profiles')
          .select('role')
          .eq('id', currentUser!.id)
          .single();

      return response['role'] as String?;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return null;
    }
  }

  // Check if user is street performer
  Future<bool> isStreetPerformer() async {
    final role = await getUserRole();
    return role == 'street_performer';
  }

  // Check if user is New Yorker
  Future<bool> isNewYorker() async {
    final role = await getUserRole();
    return role == 'new_yorker';
  }

  // Auth state stream (secure - no client-side context manipulation)
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Standard auth methods (secure - backend handles context)
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Standard sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // SECURITY NOTE: Database operations now rely on backend-set context
  // The app.set_current_user() function is only callable by trusted backend

  // Get current user's profile data with null-safety
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Get any user's profile data (for viewing other profiles)
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error getting user profile for $userId: $e');
      return null;
    }
  }

  // Get follower count for a user
  Future<int> getFollowerCount(String userId) async {
    try {
      final response = await _client
          .from('follows')
          .select('id')
          .eq('following_id', userId);

      return response.length;
    } catch (e) {
      debugPrint('Error getting follower count for $userId: $e');
      return 0;
    }
  }

  // Get following count for a user
  Future<int> getFollowingCount(String userId) async {
    try {
      final response = await _client
          .from('follows')
          .select('id')
          .eq('follower_id', userId);

      return response.length;
    } catch (e) {
      debugPrint('Error getting following count for $userId: $e');
      return 0;
    }
  }

  // Get video count for a performer
  Future<int> getVideoCount(String userId) async {
    try {
      final response = await _client
          .from('videos')
          .select('id')
          .eq('performer_id', userId);

      return response.length;
    } catch (e) {
      debugPrint('Error getting video count for $userId: $e');
      return 0;
    }
  }

  // Get user's videos (for performer profile)
  Future<List<Map<String, dynamic>>> getUserVideos(String userId, {int limit = 20}) async {
    try {
      final response = await _client
          .from('videos')
          .select()
          .eq('performer_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting videos for $userId: $e');
      return [];
    }
  }

  // Check if current user is following another user
  Future<bool> isFollowing(String targetUserId) async {
    if (!isAuthenticated) return false;

    try {
      final response = await _client
          .from('follows')
          .select('id')
          .eq('follower_id', currentUser!.id)
          .eq('following_id', targetUserId);

      return response.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking follow status: $e');
      return false;
    }
  }

  // Follow/unfollow a user
  Future<bool> toggleFollow(String targetUserId) async {
    if (!isAuthenticated || currentUser!.id == targetUserId) return false;

    try {
      final isCurrentlyFollowing = await isFollowing(targetUserId);
      
      if (isCurrentlyFollowing) {
        // Unfollow
        await _client
            .from('follows')
            .delete()
            .eq('follower_id', currentUser!.id)
            .eq('following_id', targetUserId);
      } else {
        // Follow
        await _client
            .from('follows')
            .insert({
              'follower_id': currentUser!.id,
              'following_id': targetUserId,
            });
      }
      
      return !isCurrentlyFollowing; // Return new follow state
    } catch (e) {
      debugPrint('Error toggling follow: $e');
      return false;
    }
  }

  // Get comprehensive profile data with all counts (for current user)
  Future<Map<String, dynamic>?> getFullProfileData() async {
    if (!isAuthenticated) return null;

    try {
      final userId = currentUser!.id;
      
      // Fetch profile data and counts in parallel for better performance
      final results = await Future.wait([
        getCurrentUserProfile(),
        getFollowerCount(userId),
        getFollowingCount(userId),
        getVideoCount(userId),
      ]);
      
      final profileData = results[0] as Map<String, dynamic>?;
      if (profileData == null) return null;
      
      // Add computed counts to profile data
      return {
        ...profileData,
        'follower_count': results[1] as int,
        'following_count': results[2] as int,
        'video_count': results[3] as int,
      };
    } catch (e) {
      debugPrint('Error getting full profile data: $e');
      return null;
    }
  }

  // Update user profile data
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    if (!isAuthenticated) return false;

    try {
      // Add updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      await _client
          .from('user_profiles')
          .update(updates)
          .eq('id', currentUser!.id);

      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }
}
