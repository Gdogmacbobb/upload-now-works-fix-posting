import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/role_service.dart';
import '../../services/image_upload_service.dart';
import '../../services/supabase_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../widgets/role_gate_widget.dart';
import './widgets/activity_item_widget.dart';
import './widgets/performer_stats_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_section_widget.dart';
import './widgets/supporter_stats_widget.dart';
import './widgets/inline_profile_editor_widget.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final AuthService _authService = AuthService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoggingOut = false;
  bool _isUploadingProfilePicture = false;
  bool _isLoading = true;
  Map<String, dynamic>? userData;

  // Default fallback data structure for safe UI rendering
  Map<String, dynamic> get defaultUserData => {
    "id": _authService.currentUser?.id ?? "",
    "name": "Loading...",
    "email": _authService.currentUser?.email ?? "",
    "avatar": null,
    "bio": null, // Bio field for both account types
    "borough": null, // Borough field for location
    "accountType": "new_yorker", // Safe default
    "joinDate": DateTime.now().toIso8601String(),
    "isVerified": false,
    "totalEarnings": 0.0,
    "followerCount": 0,
    "followingCount": 0,
    "videoCount": 0,
    "monthlyEarnings": 0.0,
    "totalDonated": 0.0,
    "performersSupported": 0,
    "favoritePerformanceTypes": <String>[],
    "socialMedia": <String, String>{}, // Social media links
  };

  // Real data fetching with safe fallbacks
  Future<void> _loadUserData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      userData = defaultUserData; // Set safe defaults
    });

    try {
      // Fetch real profile data from Supabase
      final profileData = await _supabaseService.getFullProfileData();
      
      if (mounted && profileData != null) {
        setState(() {
          userData = _formatUserData(profileData);
          _isLoading = false;
        });
      } else {
        // Fallback: Keep default data, just mark as loaded
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      // Safe fallback: Use default data structure
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Format Supabase profile data to match UI expectations
  Map<String, dynamic> _formatUserData(Map<String, dynamic> data) {
    final role = data['role'] as String?;
    final isPerformer = role == 'street_performer';
    final socialMediaLinks = data['social_media_links'] as Map<String, dynamic>? ?? {};
    
    return {
      "id": data['id'] ?? _authService.currentUser?.id ?? "",
      "name": data['full_name'] ?? data['username'] ?? "User",
      "email": _authService.currentUser?.email ?? "",
      "avatar": data['profile_image_url'],
      "bio": data['bio'], // Bio from registration
      "borough": data['borough'], // Borough from registration
      "accountType": isPerformer ? "performer" : "new_yorker",
      "joinDate": data['created_at'] ?? DateTime.now().toIso8601String(),
      "isVerified": data['is_verified'] == true,
      "totalEarnings": data['total_donations_received'] ?? 0.0,
      "followerCount": data['follower_count'] ?? 0,
      "followingCount": data['following_count'] ?? 0,
      "videoCount": data['video_count'] ?? 0,
      "monthlyEarnings": 0.0, // Would need separate tracking
      "totalDonated": 0.0, // Would need separate tracking for New Yorkers
      "performersSupported": 0, // Would need separate tracking
      "favoritePerformanceTypes": <String>[], // Would need separate preferences table
      "socialMedia": {
        "instagram": data['socials_instagram'] ?? socialMediaLinks['instagram'],
        "tiktok": data['socials_tiktok'] ?? socialMediaLinks['tiktok'],
        "youtube": data['socials_youtube'] ?? socialMediaLinks['youtube'],
      }
    };
  }

  // Mock recent activities (role-specific)
  List<Map<String, dynamic>> _getRecentActivities(bool isPerformer) {
    if (isPerformer) {
      return [
        {
          "id": 1,
          "type": "donation_received",
          "userName": "Sarah Chen",
          "amount": 15.0,
          "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
        },
        {
          "id": 2,
          "type": "like",
          "userName": "Mike Johnson",
          "timestamp": DateTime.now().subtract(const Duration(hours: 4)),
        },
        {
          "id": 3,
          "type": "follow",
          "userName": "Emma Davis",
          "timestamp": DateTime.now().subtract(const Duration(hours: 6)),
        },
        {
          "id": 4,
          "type": "comment",
          "userName": "Alex Thompson",
          "timestamp": DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          "id": 5,
          "type": "donation_received",
          "userName": "Lisa Park",
          "amount": 25.0,
          "timestamp": DateTime.now().subtract(const Duration(days: 2)),
        },
      ];
    } else {
      return [
        {
          "id": 1,
          "type": "donation_made",
          "userName": "Marcus Rodriguez",
          "amount": 10.0,
          "timestamp": DateTime.now().subtract(const Duration(hours: 3)),
        },
        {
          "id": 2,
          "type": "follow",
          "userName": "Jazz Quartet NYC",
          "timestamp": DateTime.now().subtract(const Duration(hours: 8)),
        },
        {
          "id": 3,
          "type": "like",
          "userName": "Street Artist Emma",
          "timestamp": DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          "id": 4,
          "type": "donation_made",
          "userName": "Guitar Player Joe",
          "amount": 5.0,
          "timestamp": DateTime.now().subtract(const Duration(days: 3)),
        },
        {
          "id": 5,
          "type": "saved",
          "userName": "Amazing Dance Performance",
          "timestamp": DateTime.now().subtract(const Duration(days: 5)),
        },
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load real profile data on initialization
  }

  @override
  Widget build(BuildContext context) {
    final currentUserData = userData ?? defaultUserData;

    return RoleGate.authenticated(
      child: Builder(
        builder: (context) {
          final roleService = RoleService.instance;
          final isPerformer = roleService.hasPermission(PerformerFeature.uploadVideo);

          return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          "Profile",
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: CustomIconWidget(
              iconName: 'logout',
              color: AppTheme.textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            ProfileHeaderWidget(
              userData: currentUserData,
              onAvatarTap: _showAvatarOptions,
              isCurrentUserProfile: true, // Always true for user profile page
              onEditTap: _handleEditProfile,
            ),

            SizedBox(height: AppSpacing.sm),

            // Stats Section (Role-specific)
            if (isPerformer)
              PerformerStatsWidget(
                performerData: currentUserData,
                isCurrentUserProfile: true,
                onEditTap: _handleEditProfile,
              )
            else
              SupporterStatsWidget(
                supporterData: currentUserData,
                isCurrentUserProfile: true,
                onEditTap: _handleEditProfile,
              ),

            SizedBox(height: AppSpacing.sm),

            // Inline Profile Editor
            InlineProfileEditorWidget(
              userData: currentUserData,
              onSave: _updateUserProfile,
              isPerformer: isPerformer,
            ),

            SizedBox(height: AppSpacing.sm),

            // Bio Section
            _buildBioSection(currentUserData),

            // Borough Section
            _buildBoroughSection(currentUserData),

            // Social Media Section
            _buildSocialMediaSection(currentUserData),

            SizedBox(height: AppSpacing.sm),

            // Account Section
            ProfileSectionWidget(
              title: "Account",
              items: _getAccountItems(isPerformer),
              onItemTap: _handleSectionTap,
            ),

            // Activity Section
            ProfileSectionWidget(
              title: isPerformer ? "Performance Activity" : "Support Activity",
              items: _getActivityItems(isPerformer),
              onItemTap: _handleSectionTap,
            ),

            // Recent Activity List
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: AppTheme.performerCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recent Activity",
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _getRecentActivities(isPerformer).length,
                    itemBuilder: (context, index) {
                      final activity = _getRecentActivities(isPerformer)[index];
                      return ActivityItemWidget(activity: activity);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.sm),

            // Support Section
            ProfileSectionWidget(
              title: "Support",
              items: _getSupportItems(),
              onItemTap: _handleSectionTap,
            ),

            // Settings Section
            ProfileSectionWidget(
              title: "Settings",
              items: _getSettingsItems(),
              onItemTap: _handleSectionTap,
            ),

            SizedBox(height: AppSpacing.sm),

            // Prominent Logout Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              child: ElevatedButton(
                onPressed: _isLoggingOut ? null : () => _performLogout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRed,
                  disabledBackgroundColor: AppTheme.accentRed.withOpacity(0.6),
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoggingOut
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            "Signing out...",
                            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'logout',
                            color: AppTheme.textPrimary,
                            size: 24,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            "Sign Out",
                            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            SizedBox(height: AppSpacing.xxl), // Bottom padding for navigation
          ],
        ),
        ),
      ),
    );
        },
      ),
    );
  }

  // Bio Section Widget
  Widget _buildBioSection(Map<String, dynamic> userData) {
    final bio = userData["bio"] as String?;
    final displayBio = (bio == null || bio.trim().isEmpty) ? "Not set" : bio;
    final isEmptyBio = bio == null || bio.trim().isEmpty;
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: AppTheme.performerCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bio",
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            displayBio,
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: isEmptyBio ? AppTheme.textSecondary : AppTheme.textPrimary,
              fontStyle: isEmptyBio ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Borough Section Widget
  Widget _buildBoroughSection(Map<String, dynamic> userData) {
    final borough = userData["borough"] as String?;
    final displayBorough = (borough == null || borough.trim().isEmpty) ? "Not set" : borough;
    final isEmptyBorough = borough == null || borough.trim().isEmpty;
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: AppTheme.performerCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Location",
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: isEmptyBorough ? AppTheme.textSecondary : AppTheme.primaryOrange,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  displayBorough,
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: isEmptyBorough ? AppTheme.textSecondary : AppTheme.textPrimary,
                    fontStyle: isEmptyBorough ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Social Media Section Widget
  Widget _buildSocialMediaSection(Map<String, dynamic> userData) {
    final socialMedia = userData["socialMedia"] as Map<String, dynamic>? ?? {};
    final platforms = ['instagram', 'tiktok', 'youtube'];
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: AppTheme.performerCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Social Media",
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Column(
            children: platforms.map((platform) {
              final value = socialMedia[platform] as String?;
              final displayValue = (value == null || value.trim().isEmpty) ? "Not set" : value;
              final isEmpty = value == null || value.trim().isEmpty;
              
              return Container(
                margin: EdgeInsets.only(bottom: platform == platforms.last ? 0 : AppSpacing.xxs),
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.borderSubtle.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: _getSocialMediaIcon(platform),
                      color: isEmpty ? AppTheme.textSecondary : AppTheme.primaryOrange,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            platform.toUpperCase(),
                            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            displayValue,
                            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                              color: isEmpty ? AppTheme.textSecondary : AppTheme.primaryOrange,
                              fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isEmpty)
                      CustomIconWidget(
                        iconName: 'open_in_new',
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getSocialMediaIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return 'camera_alt';
      case 'tiktok':
        return 'music_note';
      case 'youtube':
        return 'play_circle_filled';
      default:
        return 'link';
    }
  }

  List<Map<String, dynamic>> _getAccountItems(bool isPerformer) {
    List<Map<String, dynamic>> baseItems = [
      {
        "icon": "notifications",
        "title": "Notification Preferences",
        "subtitle": "Manage your notification settings",
        "route": "/notification-settings",
        "showBadge": true,
      },
      {
        "icon": "privacy_tip",
        "title": "Privacy Settings",
        "subtitle": "Control your privacy and data",
        "route": "/privacy-settings",
      },
    ];
    
    // Add role-specific payment options
    if (isPerformer) {
      baseItems.insert(1, {
        "icon": "payment",
        "title": "Payout Settings",
        "subtitle": "Manage earnings and payout methods",
        "route": "/payout-settings",
      });
    } else {
      baseItems.insert(1, {
        "icon": "payment",
        "title": "Payment Methods",
        "subtitle": "Manage donation payment methods",
        "route": "/payment-methods",
      });
    }
    
    return baseItems;
  }

  List<Map<String, dynamic>> _getActivityItems(bool isPerformer) {
    if (isPerformer) {
      return [
        {
          "icon": "favorite",
          "title": "Likes Received",
          "subtitle": "See who liked your performances",
          "route": "/likes-received",
        },
        {
          "icon": "chat_bubble",
          "title": "Comments",
          "subtitle": "View and manage comments on your videos",
          "route": "/comments",
        },
        {
          "icon": "people",
          "title": "Followers",
          "subtitle": "Manage your followers and fans",
          "route": "/followers",
        },
        {
          "icon": "attach_money",
          "title": "Earnings History",
          "subtitle": "View your donation and tip earnings",
          "route": "/earnings-history",
        },
        {
          "icon": "video_library",
          "title": "My Performances",
          "subtitle": "Manage your uploaded videos",
          "route": "/my-videos",
        },
      ];
    } else {
      return [
        {
          "icon": "favorite",
          "title": "Liked Performances",
          "subtitle": "Videos you've liked",
          "route": "/liked-videos",
        },
        {
          "icon": "people",
          "title": "Following",
          "subtitle": "Street performers you follow",
          "route": "/following",
        },
        {
          "icon": "attach_money",
          "title": "Donation History",
          "subtitle": "Your donation and tip history",
          "route": "/donation-history",
        },
        {
          "icon": "bookmark",
          "title": "Saved Performances",
          "subtitle": "Performances you've bookmarked",
          "route": "/saved-videos",
        },
      ];
    }
  }

  List<Map<String, dynamic>> _getSupportItems() {
    return [
      {
        "icon": "help",
        "title": "Help Center",
        "subtitle": "Get help and support",
        "route": "/help-center",
      },
      {
        "icon": "contact_support",
        "title": "Contact Us",
        "subtitle": "Reach out to our team",
        "route": "/contact-support",
      },
      {
        "icon": "gavel",
        "title": "Community Guidelines",
        "subtitle": "Read our community rules",
        "route": "/community-guidelines",
      },
    ];
  }

  List<Map<String, dynamic>> _getSettingsItems() {
    return [
      {
        "icon": "settings",
        "title": "App Preferences",
        "subtitle": "Customize your app experience",
        "route": "/app-preferences",
      },
      {
        "icon": "data_usage",
        "title": "Data Usage",
        "subtitle": "Manage data and storage",
        "route": "/data-usage",
      },
      {
        "icon": "delete_forever",
        "title": "Delete Account",
        "subtitle": "Permanently delete your account",
        "route": "/delete-account",
      },
    ];
  }

  void _handleSectionTap(String route) {
    if (route.isNotEmpty) {
      // Handle navigation to different sections
      switch (route) {
        case "/notification-settings":
          _showNotificationSettings();
          break;
        case "/payment-methods":
          _showPaymentMethods();
          break;
        case "/payout-settings":
          _showPayoutSettings();
          break;
        case "/delete-account":
          _showDeleteAccountDialog();
          break;
        default:
          _showComingSoon(route);
          break;
      }
    }
  }


  Future<void> _updateUserProfile(Map<String, dynamic> updatedData) async {
    // Update user profile data with null-safety
    setState(() {
      userData ??= Map<String, dynamic>.from(defaultUserData);
      userData!.addAll(updatedData);
    });
    
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
            SizedBox(width: AppSpacing.sm),
            Text(
              "Profile updated successfully",
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // TODO: In real implementation, sync with Supabase
    // await _authService.updateUserProfile(updatedData);
  }

  Future<void> _handleProfilePictureUpload() async {
    if (_isUploadingProfilePicture) return;
    
    setState(() => _isUploadingProfilePicture = true);
    
    try {
      // Pick image from gallery
      FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // Get bytes for web compatibility
      );
      
      if (pickerResult == null || pickerResult.files.isEmpty) {
        setState(() => _isUploadingProfilePicture = false);
        return; // User cancelled selection
      }
      
      final file = pickerResult.files.first;
      final Uint8List? bytes = file.bytes;
      final String fileName = file.name;
      
      if (bytes == null) {
        throw Exception('Failed to read image file');
      }
      
      // Upload the selected image
      final result = await _imageUploadService.uploadProfilePicture(bytes, fileName);
      
      if (result.success && result.imageUrl != null) {
        // Update the user data with new profile picture (null-safe)
        setState(() {
          userData ??= Map<String, dynamic>.from(defaultUserData);
          userData!['avatar'] = result.imageUrl;
        });
        
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
                SizedBox(width: AppSpacing.sm),
                Text(
                  "Profile picture updated successfully",
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.surfaceDark,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: AppTheme.accentRed,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  result.error ?? "Failed to upload profile picture",
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.accentRed.withOpacity(0.1),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Profile picture upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "An error occurred while uploading. Please try again.",
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          backgroundColor: AppTheme.accentRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isUploadingProfilePicture = false);
    }
  }

  void _handleEditProfile() {
    // Since we're already on the user profile page, scroll to the edit section
    // or simply show a message about editing inline
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'edit',
              color: AppTheme.primaryOrange,
              size: 20,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              "Use the editor below to update your profile",
              style: AppTheme.darkTheme.textTheme.bodyMedium,
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 2,
              decoration: BoxDecoration(
                color: AppTheme.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              "Change Profile Photo",
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            RoleGate.requiresFeature(
              feature: PerformerFeature.recordVideo, // Camera access for performers
              fallback: SizedBox.shrink(), // Hide camera option for New Yorkers
              child: ListTile(
                leading: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: AppTheme.primaryOrange,
                  size: 24,
                ),
                title: Text(
                  "Take Photo",
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoon("Camera");
                },
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: AppTheme.primaryOrange,
                size: 24,
              ),
              title: Text(
                "Choose from Gallery",
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _handleProfilePictureUpload();
              },
            ),
            SizedBox(height: AppSpacing.xs),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          "Notification Settings",
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text(
                "Push Notifications",
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: Text(
                "Receive notifications on your device",
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: Text(
                "Email Updates",
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: Text(
                "Get updates via email",
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(color: AppTheme.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethods() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          "Payment Methods",
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "Manage your payment methods for donations and tips. This feature integrates with Stripe for secure transactions.",
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(color: AppTheme.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  void _showPayoutSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          "Payout Settings",
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "Manage your earnings and payout methods as a Street Performer. Set up secure payouts for your donations and tips.",
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(color: AppTheme.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: !_isLoggingOut,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          "Sign Out",
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "Are you sure you want to sign out? Your data will be retained for when you return.",
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoggingOut ? null : () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: _isLoggingOut ? AppTheme.textSecondary.withOpacity(0.5) : AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isLoggingOut ? null : () {
              Navigator.pop(context);
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
              disabledBackgroundColor: AppTheme.accentRed.withOpacity(0.6),
            ),
            child: _isLoggingOut
                ? SizedBox(
                    width: AppSpacing.md,
                    height: AppSpacing.md,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.textPrimary,
                      ),
                    ),
                  )
                : Text(
                    "Sign Out",
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Sign out from Supabase to end the session
      await _authService.signOut();
      
      // Navigate to login screen after successful logout
      if (mounted) {
        AppRoutes.pushReplacementNamed(
          context,
          AppRoutes.loginScreen,
        );
      }
    } catch (error) {
      // Handle logout error
      setState(() {
        _isLoggingOut = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Sign out failed. Please try again.",
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            backgroundColor: AppTheme.accentRed,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: "Retry",
              textColor: AppTheme.textPrimary,
              onPressed: () => _performLogout(),
            ),
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          "Delete Account",
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.accentRed,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "This action cannot be undone. All your data, videos, and earnings will be permanently deleted.",
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon("Account Deletion");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
            ),
            child: Text(
              "Delete",
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$feature feature coming soon",
          style: AppTheme.darkTheme.textTheme.bodyMedium,
        ),
        backgroundColor: AppTheme.surfaceDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

}

