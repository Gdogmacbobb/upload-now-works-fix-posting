import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

/// Result class for image upload operations
class ImageUploadResult {
  final bool success;
  final String? imageUrl;
  final String? error;

  ImageUploadResult({required this.success, this.imageUrl, this.error});

  factory ImageUploadResult.success(String imageUrl) =>
      ImageUploadResult(success: true, imageUrl: imageUrl);

  factory ImageUploadResult.error(String error) =>
      ImageUploadResult(success: false, error: error);
}

/// Service for handling image uploads, particularly profile pictures
/// Enforces role-based access control and web compatibility
class ImageUploadService {
  static ImageUploadService? _instance;
  static ImageUploadService get instance => _instance ??= ImageUploadService._internal();
  
  factory ImageUploadService() => instance;
  
  ImageUploadService._internal();
  
  final SupabaseService _supabaseService = SupabaseService();
  
  /// Get current authenticated user ID
  Future<String?> _getCurrentUserId() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;
      return user?.id;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }
  
  /// Upload profile picture with secure authentication and per-user storage
  Future<ImageUploadResult> uploadProfilePicture(Uint8List bytes, String fileName) async {
    try {
      // Get authenticated user ID - enforce ownership
      final currentUserId = await _getCurrentUserId();
      if (currentUserId == null) {
        return ImageUploadResult.error('User not authenticated');
      }

      final client = await _supabaseService.client;
      
      // Validate file type
      if (!isValidImageType(fileName)) {
        return ImageUploadResult.error('Invalid image type. Allowed types: jpg, jpeg, png, gif, webp');
      }
      
      // Validate file size
      if (!isValidImageSize(bytes)) {
        return ImageUploadResult.error('Image file too large. Maximum size: 5MB');
      }
      
      // Create secure per-user path and unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = fileName.split('.').last.toLowerCase();
      final uniqueFileName = 'profile_$timestamp.$fileExtension';
      final storagePath = '$currentUserId/$uniqueFileName';
      
      // Upload to user's private folder in Supabase Storage
      final String filePath = await client.storage
          .from('profile-pictures')
          .uploadBinary(
            storagePath,
            bytes,
          );
      
      // Get public URL
      final String publicUrl = client.storage
          .from('profile-pictures')
          .getPublicUrl(storagePath);
      
      // Update user profile in database (enforces user can only update their own profile)
      final updateResult = await _updateUserProfilePicture(currentUserId, publicUrl, storagePath);
      if (!updateResult.success) {
        // Rollback: delete uploaded file if database update fails
        await _deleteStorageFile(storagePath);
        return ImageUploadResult.error(updateResult.error ?? 'Failed to update profile');
      }
      
      debugPrint('Profile picture uploaded successfully: $publicUrl');
      return ImageUploadResult.success(publicUrl);
      
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      return ImageUploadResult.error('Upload failed: ${e.toString()}');
    }
  }
  
  /// Delete profile picture with authenticated ownership verification
  Future<ImageUploadResult> deleteProfilePicture() async {
    try {
      // Get authenticated user ID - enforce ownership
      final currentUserId = await _getCurrentUserId();
      if (currentUserId == null) {
        return ImageUploadResult.error('User not authenticated');
      }

      final client = await _supabaseService.client;
      
      // Get current profile picture path from database
      final response = await client
          .from('user_profiles')
          .select('profile_image_url, profile_image_path')
          .eq('id', currentUserId)
          .single();
      
      final currentImageUrl = response['profile_image_url'] as String?;
      final storagePath = response['profile_image_path'] as String?;
      
      if (currentImageUrl == null || storagePath == null) {
        return ImageUploadResult.error('No profile picture to delete');
      }
      
      // Delete from storage
      final deleteResult = await _deleteStorageFile(storagePath);
      if (!deleteResult) {
        return ImageUploadResult.error('Failed to delete image file');
      }
      
      // Clear profile picture URL in database
      final updateResult = await _updateUserProfilePicture(currentUserId, null, null);
      if (!updateResult.success) {
        return ImageUploadResult.error(updateResult.error ?? 'Failed to update profile');
      }
      
      debugPrint('Profile picture deleted successfully');
      return ImageUploadResult.success(currentImageUrl);
      
    } catch (e) {
      debugPrint('Error deleting profile picture: $e');
      return ImageUploadResult.error('Delete failed: ${e.toString()}');
    }
  }
  
  /// Internal method to update user profile with proper error handling
  Future<ImageUploadResult> _updateUserProfilePicture(String userId, String? imageUrl, String? storagePath) async {
    try {
      final client = await _supabaseService.client;
      
      await client
          .from('user_profiles')
          .update({
            'profile_image_url': imageUrl,
            'profile_image_path': storagePath,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', userId);
      
      debugPrint('User profile updated with profile picture: $imageUrl');
      return ImageUploadResult.success(imageUrl ?? 'Profile cleared');
      
    } catch (e) {
      debugPrint('Error updating user profile picture: $e');
      return ImageUploadResult.error('Database update failed: ${e.toString()}');
    }
  }
  
  /// Internal method to delete file from storage
  Future<bool> _deleteStorageFile(String storagePath) async {
    try {
      final client = await _supabaseService.client;
      
      await client.storage
          .from('profile-pictures')
          .remove([storagePath]);
      
      debugPrint('Storage file deleted successfully: $storagePath');
      return true;
      
    } catch (e) {
      debugPrint('Error deleting storage file: $e');
      return false;
    }
  }
  
  /// Get appropriate content type for image file
  String _getContentType(String fileExtension) {
    switch (fileExtension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }
  
  /// Validate image file size (max 5MB)
  bool isValidImageSize(Uint8List bytes, {int maxSizeInMB = 5}) {
    final int maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return bytes.length <= maxSizeInBytes;
  }
  
  /// Validate image file type
  bool isValidImageType(String fileName) {
    final String extension = fileName.split('.').last.toLowerCase();
    const List<String> validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    return validExtensions.contains(extension);
  }
}