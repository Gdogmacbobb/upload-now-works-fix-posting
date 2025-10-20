import 'package:flutter/foundation.dart';
import './api_service.dart';

class VideoService {
  final ApiService _apiService = ApiService();

  // Upload video with location verification
  Future<Map<String, dynamic>?> uploadVideo({
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
    List<String>? hashtags,
  }) async {
    try {
      // Verify NYC location (approximate boundaries)
      if (!_isInNYC(latitude, longitude)) {
        throw Exception(
            'Videos can only be uploaded from within NYC boundaries');
      }

      final response = await _apiService.post('/videos', {
        'title': title,
        'description': description,
        'videoUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        'duration': duration,
        'locationLatitude': latitude,
        'locationLongitude': longitude,
        'locationName': locationName,
        'borough': borough,
        'thumbnailFrameTime': thumbnailFrameTime ?? 0,
        'hashtags': hashtags ?? [],
      });

      return response?['video'] as Map<String, dynamic>?;
    } catch (error) {
      debugPrint('Upload video error: $error');
      rethrow;
    }
  }

  // Get discovery feed (approved videos for all users)
  Future<List<Map<String, dynamic>>> getDiscoveryFeed({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        '/videos/discovery',
        queryParams: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      final videos = response?['videos'] as List<dynamic>?;
      if (videos == null) return [];

      return videos.map((v) => _mapVideoResponse(v)).toList();
    } catch (error) {
      debugPrint('Get discovery feed error: $error');
      return [];
    }
  }

  // Get following feed (videos from followed performers)
  Future<List<Map<String, dynamic>>> getFollowingFeed({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        '/videos/following',
        queryParams: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      final videos = response?['videos'] as List<dynamic>?;
      if (videos == null) return [];

      return videos.map((v) => _mapVideoResponse(v)).toList();
    } catch (error) {
      debugPrint('Get following feed error: $error');
      return [];
    }
  }

  // Get performer's videos
  Future<List<Map<String, dynamic>>> getPerformerVideos(
    String performerId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        '/videos/performer/$performerId',
        queryParams: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      final videos = response?['videos'] as List<dynamic>?;
      if (videos == null) return [];

      return videos.map((v) => v as Map<String, dynamic>).toList();
    } catch (error) {
      debugPrint('Get performer videos error: $error');
      return [];
    }
  }

  // Like/unlike video
  Future<void> toggleVideoLike(String videoId) async {
    try {
      await _apiService.post('/videos/$videoId/like', {});
    } catch (error) {
      debugPrint('Toggle video like error: $error');
      rethrow;
    }
  }

  // Check if video is liked
  Future<bool> isVideoLiked(String videoId) async {
    try {
      final response = await _apiService.get('/videos/$videoId/liked');
      return response?['liked'] as bool? ?? false;
    } catch (error) {
      debugPrint('Check video liked error: $error');
      return false;
    }
  }

  // Record video view
  Future<void> recordVideoView(String videoId) async {
    try {
      await _apiService.post('/videos/$videoId/view', {});
    } catch (error) {
      debugPrint('Record video view error: $error');
    }
  }

  // Add comment to video
  Future<Map<String, dynamic>?> addComment(
      String videoId, String content) async {
    try {
      final response = await _apiService.post(
        '/videos/$videoId/comments',
        {'content': content},
      );

      return response?['comment'] as Map<String, dynamic>?;
    } catch (error) {
      debugPrint('Add comment error: $error');
      rethrow;
    }
  }

  // Get video comments
  Future<List<Map<String, dynamic>>> getVideoComments(
    String videoId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        '/videos/$videoId/comments',
        queryParams: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      final comments = response?['comments'] as List<dynamic>?;
      if (comments == null) return [];

      return comments.map((c) => c as Map<String, dynamic>).toList();
    } catch (error) {
      debugPrint('Get video comments error: $error');
      return [];
    }
  }

  // Repost video (for New Yorkers)
  Future<void> repostVideo(String videoId, {String? repostText}) async {
    try {
      await _apiService.post('/videos/$videoId/repost', {
        if (repostText != null) 'repostText': repostText,
      });
    } catch (error) {
      debugPrint('Repost video error: $error');
      rethrow;
    }
  }

  // Get user's reposts
  Future<List<Map<String, dynamic>>> getUserReposts(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        '/videos/reposts/$userId',
        queryParams: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      final reposts = response?['reposts'] as List<dynamic>?;
      if (reposts == null) return [];

      return reposts.map((r) => r as Map<String, dynamic>).toList();
    } catch (error) {
      debugPrint('Get user reposts error: $error');
      return [];
    }
  }

  // Get upload URL for video
  Future<String> getUploadUrl() async {
    try {
      final response = await _apiService.post('/videos/upload-url', {});
      if (response == null || response['uploadURL'] == null) {
        throw Exception('Failed to get upload URL');
      }
      return response['uploadURL'] as String;
    } catch (error) {
      debugPrint('Get upload URL error: $error');
      rethrow;
    }
  }

  // Helper: Map video response to include nested performer data
  Map<String, dynamic> _mapVideoResponse(dynamic video) {
    final videoMap = video as Map<String, dynamic>;
    
    // Handle performer data - API returns it nested
    final performer = videoMap['performer'];
    if (performer != null) {
      videoMap['performer'] = {
        'id': performer['id'],
        'username': performer['username'],
        'full_name': performer['fullName'],
        'profile_image_url': performer['profileImageUrl'],
        'performance_types': performer['performanceTypes'],
        'is_verified': performer['isVerified'],
      };
    }

    // Map API response fields to match Supabase naming
    return {
      'id': videoMap['id'],
      'title': videoMap['title'],
      'description': videoMap['description'],
      'video_url': videoMap['videoUrl'],
      'thumbnail_url': videoMap['thumbnailUrl'],
      'thumbnail_frame_time': videoMap['thumbnailFrameTime'],
      'duration': videoMap['duration'],
      'like_count': videoMap['likeCount'],
      'comment_count': videoMap['commentCount'],
      'share_count': videoMap['shareCount'],
      'view_count': videoMap['viewCount'],
      'repost_count': videoMap['repostCount'],
      'location_name': videoMap['locationName'],
      'location_latitude': videoMap['locationLatitude'],
      'location_longitude': videoMap['locationLongitude'],
      'borough': videoMap['borough'],
      'hashtags': videoMap['hashtags'],
      'created_at': videoMap['createdAt'],
      'performer': videoMap['performer'],
    };
  }

  // Helper: Check if coordinates are within NYC boundaries (approximate)
  bool _isInNYC(double latitude, double longitude) {
    // NYC approximate boundaries
    const double minLat = 40.4774;
    const double maxLat = 40.9176;
    const double minLng = -74.2591;
    const double maxLng = -73.7004;

    return latitude >= minLat &&
        latitude <= maxLat &&
        longitude >= minLng &&
        longitude <= maxLng;
  }
}
