import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './api_service.dart';

class ImageUploadService {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery (web-compatible)
  Future<Uint8List?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        debugPrint('ImageUploadService: User cancelled image selection');
        return null;
      }

      final Uint8List imageBytes = await image.readAsBytes();
      debugPrint('ImageUploadService: Image selected, size: ${imageBytes.length} bytes');
      return imageBytes;
    } catch (e) {
      debugPrint('ImageUploadService Error: Failed to pick image - $e');
      return null;
    }
  }

  /// Upload image bytes to API and return public URL
  Future<String?> uploadProfilePhoto({
    required Uint8List imageBytes,
    required String userId,
  }) async {
    try {
      debugPrint('ImageUploadService: Uploading profile photo for user $userId');

      final token = _apiService.getToken();
      if (token == null) {
        debugPrint('ImageUploadService Error: No auth token available');
        return null;
      }

      final uri = Uri.parse('${_apiService.baseUrl}/api/profiles/upload-avatar');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'profile_$userId\_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final avatarUrl = data['avatar_url'] as String;
        debugPrint('ImageUploadService: Upload successful, URL: $avatarUrl');
        return avatarUrl;
      } else {
        debugPrint('ImageUploadService Error: Upload failed with status ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('ImageUploadService Error: Failed to upload image - $e');
      return null;
    }
  }

  /// Complete flow: pick image and upload to API
  Future<String?> pickAndUploadProfilePhoto(String userId) async {
    final imageBytes = await pickImageFromGallery();
    if (imageBytes == null) return null;

    return await uploadProfilePhoto(
      imageBytes: imageBytes,
      userId: userId,
    );
  }
}
