import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../services/profile_service.dart';
import '../../utils/responsive_scale.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  
  const EditProfilePage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _bioController = TextEditingController();
  final ProfileService _profileService = ProfileService();
  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String _originalBio = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() => _isLoading = true);
      
      final profileData = await _profileService.getUserProfile(widget.userId);
      
      if (profileData != null && mounted) {
        final bio = profileData['bio'] as String? ?? '';
        setState(() {
          _originalBio = bio;
          _bioController.text = bio;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    try {
      setState(() => _isSaving = true);
      
      // Use API service to update profile
      final success = await _apiService.updateProfile(
        bio: _bioController.text.trim(),
      );

      if (!success) {
        throw Exception('Profile update failed');
      }

      // Navigate back after saving
      if (mounted) {
        Navigator.pop(context, true); // return "true" so we know to refresh
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to update profile. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.darkTheme.textTheme.bodyMedium,
        ),
        backgroundColor: AppTheme.accentRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool get _hasChanges => _bioController.text.trim() != _originalBio;

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Edit Profile",
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryOrange,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      "Save",
                      style: TextStyle(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryOrange,
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bio Section
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.borderSubtle,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bio",
                          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        TextField(
                          controller: _bioController,
                          maxLines: 5,
                          maxLength: 500,
                          onChanged: (_) => setState(() {}), // Trigger rebuild to show/hide Save button
                          decoration: InputDecoration(
                            hintText: "Tell people about yourself...",
                            hintStyle: TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.backgroundDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppTheme.borderSubtle),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppTheme.borderSubtle),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppTheme.primaryOrange),
                            ),
                          ),
                          style: TextStyle(color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Coming Soon sections
                  _buildComingSoonSection("Profile Picture", "Update your avatar"),
                  SizedBox(height: 3.h),
                  _buildComingSoonSection("Personal Information", "Update name, email, and other details"),
                  SizedBox(height: 3.h),
                  _buildComingSoonSection("Performance Details", "Update your performance types and locations"),
                ],
              ),
            ),
    );
  }

  Widget _buildComingSoonSection(String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderSubtle.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            subtitle,
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.borderSubtle.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                "Coming Soon",
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}