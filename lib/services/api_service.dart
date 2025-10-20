import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Dio? _dio;
  String? _authToken;
  Map<String, dynamic>? _currentUser;
  bool _isInitialized = false;

  String get baseUrl {
    if (kIsWeb) {
      return '';
    }
    return 'http://localhost:5000';
  }

  Future<void> init() async {
    if (_isInitialized) return;
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        debugPrint('[API] Error: ${error.message}');
        if (error.response?.statusCode == 401) {
          _clearAuth();
        }
        return handler.next(error);
      },
    ));

    await _loadToken();
    _isInitialized = true;
  }

  void _ensureInitialized() {
    if (!_isInitialized || _dio == null) {
      throw StateError('ApiService not initialized. Call init() first.');
    }
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      try {
        _currentUser = jsonDecode(userJson) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('[API] Failed to decode stored user: $e');
        _currentUser = null;
      }
    }
  }

  Future<void> _saveToken(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('current_user', jsonEncode(user));
    _authToken = token;
    _currentUser = user;
  }

  Future<void> _clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('current_user');
    _authToken = null;
    _currentUser = null;
  }

  bool get isAuthenticated => _authToken != null;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get currentUserId => _currentUser?['id'];
  String? getToken() => _authToken;

  // Generic HTTP methods
  Future<Map<String, dynamic>?> get(String path, {Map<String, dynamic>? queryParams}) async {
    _ensureInitialized();
    try {
      final response = await _dio!.get(
        '/api$path',
        queryParameters: queryParams,
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('[API] GET error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> post(String path, Map<String, dynamic> data) async {
    _ensureInitialized();
    try {
      final response = await _dio!.post('/api$path', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('[API] POST error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> put(String path, Map<String, dynamic> data) async {
    _ensureInitialized();
    try {
      final response = await _dio!.put('/api$path', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('[API] PUT error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> delete(String path) async {
    _ensureInitialized();
    try {
      final response = await _dio!.delete('/api$path');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('[API] DELETE error: $e');
      return null;
    }
  }

  // Authentication
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required String role,
    List<String>? performanceTypes,
  }) async {
    _ensureInitialized();
    try {
      final response = await _dio!.post('/api/auth/register', data: {
        'email': email,
        'password': password,
        'username': username,
        'full_name': fullName,
        'role': role,
        if (performanceTypes != null) 'performance_types': performanceTypes,
      });

      final token = response.data['token'];
      final user = response.data['user'];
      await _saveToken(token, user);

      return response.data;
    } catch (e) {
      debugPrint('[API] Register error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _ensureInitialized();
    try {
      final response = await _dio!.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['token'];
      final user = response.data['user'];
      await _saveToken(token, user);

      return response.data;
    } catch (e) {
      debugPrint('[API] Login error: $e');
      rethrow;
    }
  }

  Future<bool> checkUsernameAvailability(String username) async {
    _ensureInitialized();
    try {
      final response = await _dio!.get('/api/auth/check-username/$username');
      return response.data['available'] ?? false;
    } catch (e) {
      debugPrint('[API] Check username error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _clearAuth();
  }

  // Profile
  Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final response = await _dio!.get('/api/profiles/me');
      return response.data['profile'];
    } catch (e) {
      debugPrint('[API] Get profile error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfileByUsername(String username) async {
    try {
      final response = await _dio!.get('/api/profiles/username/$username');
      return response.data['profile'];
    } catch (e) {
      debugPrint('[API] Get profile by username error: $e');
      return null;
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
    List<String>? performanceTypes,
  }) async {
    try {
      await _dio!.put('/api/profiles/me', data: {
        if (fullName != null) 'full_name': fullName,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (performanceTypes != null) 'performance_types': performanceTypes,
      });
      return true;
    } catch (e) {
      debugPrint('[API] Update profile error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> searchProfiles(String query) async {
    try {
      final response = await _dio!.get('/api/profiles/search', queryParameters: {'q': query});
      return List<Map<String, dynamic>>.from(response.data['profiles']);
    } catch (e) {
      debugPrint('[API] Search profiles error: $e');
      return [];
    }
  }

  // Social
  Future<bool> followUser(String userId) async {
    try {
      await _dio!.post('/api/social/follow/$userId');
      return true;
    } catch (e) {
      debugPrint('[API] Follow user error: $e');
      return false;
    }
  }

  Future<bool> unfollowUser(String userId) async {
    try {
      await _dio!.delete('/api/social/follow/$userId');
      return true;
    } catch (e) {
      debugPrint('[API] Unfollow user error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getFollowers(String userId, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio!.get('/api/social/followers/$userId', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      return List<Map<String, dynamic>>.from(response.data['followers']);
    } catch (e) {
      debugPrint('[API] Get followers error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFollowing(String userId, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio!.get('/api/social/following/$userId', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      return List<Map<String, dynamic>>.from(response.data['following']);
    } catch (e) {
      debugPrint('[API] Get following error: $e');
      return [];
    }
  }

  Future<bool> interactWithVideo(String videoId, String type) async {
    try {
      await _dio!.post('/api/social/interact/$videoId', data: {'type': type});
      return true;
    } catch (e) {
      debugPrint('[API] Interact with video error: $e');
      return false;
    }
  }

  Future<bool> removeInteraction(String videoId, String type) async {
    try {
      await _dio!.delete('/api/social/interact/$videoId/$type');
      return true;
    } catch (e) {
      debugPrint('[API] Remove interaction error: $e');
      return false;
    }
  }

  // Videos
  Future<String?> getVideoUploadUrl(String fileName, String contentType) async {
    try {
      final response = await _dio!.post('/api/videos/upload-url', data: {
        'file_name': fileName,
        'content_type': contentType,
      });
      return response.data['upload_url'];
    } catch (e) {
      debugPrint('[API] Get upload URL error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createVideo({
    required String title,
    required String description,
    required String videoUrl,
    required String thumbnailUrl,
    required int duration,
    required double latitude,
    required double longitude,
    required String locationName,
    required String borough,
    int? thumbnailFrameTime,
  }) async {
    try {
      final response = await _dio!.post('/api/videos', data: {
        'title': title,
        'description': description,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'duration': duration,
        'location_latitude': latitude,
        'location_longitude': longitude,
        'location_name': locationName,
        'borough': borough,
        if (thumbnailFrameTime != null) 'thumbnail_frame_time': thumbnailFrameTime,
      });
      return response.data['video'];
    } catch (e) {
      debugPrint('[API] Create video error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getVideos({int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio!.get('/api/videos', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      return List<Map<String, dynamic>>.from(response.data['videos']);
    } catch (e) {
      debugPrint('[API] Get videos error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getVideo(String videoId) async {
    try {
      final response = await _dio!.get('/api/videos/$videoId');
      return response.data['video'];
    } catch (e) {
      debugPrint('[API] Get video error: $e');
      return null;
    }
  }

  // Stripe Payments
  Future<String?> createPaymentIntent(double amount, String performerId) async {
    try {
      final response = await _dio!.post('/api/stripe/create-payment-intent', data: {
        'amount': amount,
        'performer_id': performerId,
      });
      return response.data['client_secret'];
    } catch (e) {
      debugPrint('[API] Create payment intent error: $e');
      return null;
    }
  }
}
