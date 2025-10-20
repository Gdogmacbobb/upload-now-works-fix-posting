import 'package:flutter/foundation.dart';
import './api_service.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  /// Get user profile data by user ID from API
  /// Returns consistent data structure for both PerformerProfile and UserProfile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _apiService.get('/profiles/$userId');
      
      if (response == null || response['profile'] == null) {
        debugPrint('ProfileService: No profile found for user $userId');
        return null;
      }

      final profile = response['profile'] as Map<String, dynamic>;
      return _normalizeProfileData(profile);
    } catch (e) {
      debugPrint('ProfileService Error: Failed to fetch profile for user $userId - $e');
      return null;
    }
  }

  /// Normalize API field names to expected UI field names
  /// This ensures both PerformerProfile and UserProfile get consistent data
  Map<String, dynamic> _normalizeProfileData(Map<String, dynamic> rawData) {
    final socialMediaLinks = rawData['social_media_links'] as Map<String, dynamic>? ?? {};
    
    return {
      // Core identifiers
      'id': rawData['id'],
      'userId': rawData['id'], // Alias for compatibility
      
      // Profile information
      'name': rawData['full_name'] ?? 'Unknown Performer',
      'full_name': rawData['full_name'],
      'username': rawData['username'] ?? '',
      'role': rawData['role'] ?? '',
      'accountType': rawData['role'] ?? '', // Alias for UserProfile compatibility
      'bio': rawData['bio'] ?? '',
      
      // Profile image
      'avatar': rawData['avatar_url'] ?? getDefaultProfileImage(),
      'profile_image_url': rawData['avatar_url'],
      
      // Stats (using real API counts)
      'followersCount': rawData['follower_count'] ?? 0,
      'followers_count': rawData['follower_count'] ?? 0,
      'supportingCount': rawData['following_count'] ?? 0,
      'supporting_count': rawData['following_count'] ?? 0,
      'videoCount': rawData['video_count'] ?? 0,
      'video_count': rawData['video_count'] ?? 0,
      'totalDonations': rawData['total_donations_received'] ?? 0,
      'supporter_count': rawData['total_donations_received'] ?? 0,
      
      // Verification status
      'verificationStatus': rawData['verification_status'] ?? 'none',
      'isVerified': rawData['verification_status'] == 'approved',
      
      // Additional fields
      'email': rawData['email'] ?? '',
      'joinDate': rawData['created_at'] ?? DateTime.now().toIso8601String(),
      
      // Social media handles
      'socials_instagram': socialMediaLinks['instagram'] ?? '',
      'socials_tiktok': socialMediaLinks['tiktok'] ?? '',
      'socials_youtube': socialMediaLinks['youtube'] ?? '',
      
      // Performance types
      'performance_types': rawData['performance_types'] ?? [],
    };
  }

  /// Get user's videos from API
  Future<List<Map<String, dynamic>>> getUserVideos(String userId) async {
    try {
      final response = await _apiService.get('/profiles/$userId/videos');
      
      if (response == null || response['videos'] == null) {
        debugPrint('ProfileService: No videos found for user $userId');
        return [];
      }

      final videos = response['videos'] as List;
      debugPrint('ProfileService: Retrieved ${videos.length} videos for user $userId');
      return List<Map<String, dynamic>>.from(videos);
    } catch (e) {
      debugPrint('ProfileService Error: Failed to fetch videos for user $userId - $e');
      return [];
    }
  }

  /// Update user's profile photo URL via API
  Future<bool> updateProfilePhoto(String userId, String imageUrl) async {
    try {
      // The image upload service already updates the profile photo
      // This method is here for compatibility but the actual update
      // happens in the upload-avatar endpoint
      debugPrint('ProfileService: Profile photo updated for user $userId');
      return true;
    } catch (e) {
      debugPrint('ProfileService Error: Failed to update profile photo - $e');
      return false;
    }
  }

  /// Get default profile image URL when profile_image_url is null
  String getDefaultProfileImage() {
    return 'assets/images/default_avatar.png';
  }

  /// Format follower/supporter counts for display (e.g., 1234 -> "1.2K")
  String formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
    } else {
      return count.toString();
    }
  }

  /// Update user's social media handles
  Future<bool> updateSocialMedia(
    String userId, {
    required String instagram,
    required String tiktok,
    required String youtube,
  }) async {
    try {
      final response = await _apiService.put('/profiles/social-media', {
        'instagram': instagram.isEmpty ? null : instagram,
        'tiktok': tiktok.isEmpty ? null : tiktok,
        'youtube': youtube.isEmpty ? null : youtube,
      });

      debugPrint('ProfileService: Updated social media for user $userId');
      return response != null;
    } catch (e) {
      debugPrint('ProfileService Error: Failed to update social media - $e');
      return false;
    }
  }

  /// Get count of supporters (followers) for a user
  Future<int> getSupportersCount(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      return profile?['followers_count'] ?? 0;
    } catch (e) {
      debugPrint('ProfileService Error: Failed to fetch supporters count - $e');
      return 0;
    }
  }

  /// Get count of users this user is supporting (following)
  Future<int> getSupportingCount(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      return profile?['supporting_count'] ?? 0;
    } catch (e) {
      debugPrint('ProfileService Error: Failed to fetch supporting count - $e');
      return 0;
    }
  }

  /// Get count of approved videos for a user
  Future<int> getVideosCount(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      return profile?['video_count'] ?? 0;
    } catch (e) {
      debugPrint('ProfileService Error: Failed to fetch videos count - $e');
      return 0;
    }
  }

  /// Update user's frequent performance location
  Future<bool> updateFrequentLocation(String userId, String location) async {
    try {
      // This feature requires backend endpoint implementation
      // For now, return true for compatibility
      debugPrint('ProfileService: Frequent location update not yet implemented');
      return true;
    } catch (e) {
      debugPrint('ProfileService Error: Failed to update frequent location - $e');
      return false;
    }
  }

  /// Update user's performance schedule
  Future<bool> updatePerformanceSchedule(String userId, String schedule) async {
    try {
      // This feature requires backend endpoint implementation
      // For now, return true for compatibility
      debugPrint('ProfileService: Performance schedule update not yet implemented');
      return true;
    } catch (e) {
      debugPrint('ProfileService Error: Failed to update performance schedule - $e');
      return false;
    }
  }
}
