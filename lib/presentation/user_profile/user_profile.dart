import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:ynfny/utils/responsive_scale.dart';

import '../../core/app_export.dart';
import '../../core/constants/user_roles.dart';
import '../../services/profile_service.dart';
import '../../services/image_upload_service.dart';
import '../../services/supabase_service.dart';
=======
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
import './widgets/activity_item_widget.dart';
import './widgets/performer_stats_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_section_widget.dart';
import './widgets/supporter_stats_widget.dart';
<<<<<<< HEAD
import './edit_profile_page.dart';
import './edit_social_media_page.dart';

class UserProfile extends StatefulWidget {
  final String userId;
  
  const UserProfile({
    Key? key, 
    required this.userId,
  }) : super(key: key);
=======

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
<<<<<<< HEAD
  // Real user data from Supabase
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> recentActivities = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isUploadingPhoto = false;
  
  final ProfileService _profileService = ProfileService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final SupabaseService _supabaseService = SupabaseService();
  
  // No form controllers needed for view-only profile

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });

      // Load user profile data using ProfileService
      final profileData = await _profileService.getUserProfile(widget.userId);
      
      if (profileData == null) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Profile not found';
        });
        return;
      }

      if (mounted) {
        setState(() {
          userData = profileData;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load profile data. Please try again.';
        });
      }
    }
  }

  Future<void> _handleAvatarTap() async {
    // Show bottom sheet with photo options
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change Profile Picture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppTheme.primaryOrange),
              title: Text('Choose from Library', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _uploadProfilePhoto();
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.grey),
              title: Text('Cancel', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadProfilePhoto() async {
    try {
      setState(() => _isUploadingPhoto = true);

      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Pick and upload photo
      final imageUrl = await _imageUploadService.pickAndUploadProfilePhoto(currentUser.id);
      
      if (imageUrl == null) {
        setState(() => _isUploadingPhoto = false);
        return;
      }

      // Update database with new photo URL
      final success = await _profileService.updateProfilePhoto(currentUser.id, imageUrl);
      
      if (success) {
        // Reload profile to show new photo
        await _loadUserProfile();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile photo updated successfully!'),
              backgroundColor: AppTheme.primaryOrange,
            ),
          );
        }
      } else {
        throw Exception('Failed to update profile photo');
      }
    } catch (e) {
      debugPrint('Error uploading profile photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  // Logout functionality
  Future<void> _handleLogout() async {
    try {
      await _supabaseService.signOut();
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.loginScreen,
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log out. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // No save functionality needed for view-only profile

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundDark,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Profile",
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryOrange,
          ),
        ),
      );
    }

    // Show error state
    if (_hasError || userData == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundDark,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Profile",
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage.isNotEmpty ? _errorMessage : 'No profile data available',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }
=======
  // Mock user data
  final Map<String, dynamic> userData = {
    "id": 1,
    "name": "Marcus Rodriguez",
    "email": "marcus.street@ynfny.com",
    "avatar":
        "https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=400",
    "accountType": "performer", // or "new_yorker"
    "joinDate": "2024-01-15",
    "isVerified": true,
    "totalEarnings": 2847.50,
    "followerCount": 1234,
    "videoCount": 67,
    "monthlyEarnings": 485.20,
    "totalDonated": 156.75,
    "performersSupported": 12,
    "favoritePerformanceTypes": ["Music", "Dance", "Street Art"],
  };

  // Mock recent activities
  final List<Map<String, dynamic>> recentActivities = [
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

  @override
  Widget build(BuildContext context) {
    final isPerformer =
        (userData["accountType"] as String? ?? "new_yorker") == "performer";

>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
<<<<<<< HEAD
          "My Profile",
=======
          "Profile",
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
<<<<<<< HEAD
=======
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: CustomIconWidget(
              iconName: 'logout',
              color: AppTheme.textSecondary,
              size: 6.w,
            ),
          ),
        ],
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            // Profile Header Container - Template Design
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Avatar with orange border - Tappable only for own profile
                  GestureDetector(
                    onTap: _supabaseService.currentUser?.id == widget.userId ? _handleAvatarTap : null,
                    child: Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFF8C00),
                              width: 2,
                            ),
                          ),
                          child: _buildAvatar(
                            userData!['profile_image_url'] as String?,
                            userData!['full_name'] as String?,
                          ),
                        ),
                        // Loading indicator overlay
                        if (_isUploadingPhoto)
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.6),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFF8C00),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Name and Role Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        Text(
                          userData!['full_name'] as String? ?? 'Unknown User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Username handle
                        Text(
                          "@${userData!['username'] as String? ?? 'unknown'}",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // Role Pill - SOLID orange background
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8C00),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _formatRole(userData!['role'] as String?),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 2.h),
            
            // Performance Stats Section
            if (UserRoles.isPerformer(userData!["role"] as String?)) ...[
              PerformerStatsWidget(
                performerData: {
                  "followerCount": userData!["followers_count"] as int? ?? 0,
                  "videoCount": userData!["video_count"] as int? ?? 0,
                  "totalEarnings": 0.0, // This would need to be calculated from tips table
                  "monthlyEarnings": 0.0, // This would need to be calculated
                },
              ),
              SizedBox(height: 2.h),
            ] else ...[
              SupporterStatsWidget(
                supporterData: {
                  "performersSupported": userData!["supporter_count"] as int? ?? 0,
                  "totalDonated": 0.0, // This would need to be calculated from donations
                  "followingCount": userData!["followers_count"] as int? ?? 0,
                  "repostCount": 0, // This would need to be calculated
                  "favoritePerformanceTypes": <String>[], // This would need to be calculated
                },
              ),
              SizedBox(height: 2.h),
            ],
=======
            // Profile Header
            ProfileHeaderWidget(
              userData: userData,
              onAvatarTap: _showAvatarOptions,
            ),

            SizedBox(height: 3.h),

            // Stats Section (Role-specific)
            if (isPerformer)
              PerformerStatsWidget(performerData: userData)
            else
              SupporterStatsWidget(supporterData: userData),

            SizedBox(height: 3.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

            // Account Section
            ProfileSectionWidget(
              title: "Account",
              items: _getAccountItems(),
              onItemTap: _handleSectionTap,
            ),

            // Activity Section
            ProfileSectionWidget(
              title: "Activity",
              items: _getActivityItems(),
              onItemTap: _handleSectionTap,
            ),

<<<<<<< HEAD
=======
            // Recent Activity List
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
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
                  SizedBox(height: 2.h),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentActivities.length,
                    itemBuilder: (context, index) {
                      return ActivityItemWidget(
                        activity: recentActivities[index],
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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

<<<<<<< HEAD
            // Logout Button - Only show when viewing own profile
            if (_supabaseService.currentUser?.id == widget.userId) ...[
              SizedBox(height: 3.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ElevatedButton(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(double.infinity, 48),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],

            SizedBox(height: 4.h),
=======
            SizedBox(height: 10.h), // Bottom padding for navigation
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAccountItems() {
<<<<<<< HEAD
    // Account section items for all users
    List<Map<String, dynamic>> items = [
=======
    return [
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
      {
        "icon": "edit",
        "title": "Edit Profile",
        "subtitle": "Update your profile information",
        "route": "/edit-profile",
      },
      {
<<<<<<< HEAD
        "icon": "link",
        "title": "Social Media",
        "subtitle": "Add your social media handles",
        "route": "/social-media",
      },
    ];
    
    // Add performance location/schedule for performers (only if columns exist)
    if (userData != null && UserRoles.isPerformer(userData!['role'] as String?)) {
      // Check if the database has these columns by seeing if they were returned (even as null)
      // The ProfileService returns the keys even if values are null when columns exist
      if (userData!.containsKey('frequent_location')) {
        final location = userData!['frequent_location'] as String?;
        items.add({
          "icon": "location_on",
          "title": "Frequent Performance Location",
          "subtitle": location?.isNotEmpty == true ? location : "Not set yet",
          "route": "/performance-location",
        });
      }
      
      if (userData!.containsKey('performance_schedule')) {
        final schedule = userData!['performance_schedule'] as String?;
        items.add({
          "icon": "event",
          "title": "Performance Schedule",
          "subtitle": schedule?.isNotEmpty == true ? schedule : "Not set yet",
          "route": "/performance-schedule",
        });
      }
    }
    
    items.addAll([
      {
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
        "icon": "notifications",
        "title": "Notification Preferences",
        "subtitle": "Manage your notification settings",
        "route": "/notification-settings",
        "showBadge": true,
      },
      {
        "icon": "payment",
        "title": "Payment Methods",
        "subtitle": "Manage cards and payout settings",
        "route": "/payment-methods",
      },
      {
        "icon": "privacy_tip",
        "title": "Privacy Settings",
        "subtitle": "Control your privacy and data",
        "route": "/privacy-settings",
      },
<<<<<<< HEAD
    ]);
    
    return items;
=======
    ];
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
  }

  List<Map<String, dynamic>> _getActivityItems() {
    return [
      {
        "icon": "favorite",
        "title": "Likes Received",
        "subtitle": "See who liked your content",
        "route": "/likes-received",
      },
      {
        "icon": "chat_bubble",
        "title": "Comments",
        "subtitle": "View and manage comments",
        "route": "/comments",
      },
      {
        "icon": "people",
        "title": "Followers",
        "subtitle": "Manage your followers",
        "route": "/followers",
      },
      {
        "icon": "history",
        "title": "Transaction History",
        "subtitle": "View donation history",
        "route": "/transaction-history",
      },
    ];
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
        case "/edit-profile":
          _navigateToEditProfile();
          break;
<<<<<<< HEAD
        case "/social-media":
          _navigateToSocialMedia();
          break;
        case "/performance-location":
          _showLocationInput();
          break;
        case "/performance-schedule":
          _showScheduleInput();
          break;
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
        case "/notification-settings":
          _showNotificationSettings();
          break;
        case "/payment-methods":
          _showPaymentMethods();
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

<<<<<<< HEAD

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userId: widget.userId),
      ),
    );
    
    // If profile was updated, refresh the data
    if (result == true) {
      await _loadUserProfile();
    }
  }

  Future<void> _navigateToSocialMedia() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSocialMediaPage(userId: widget.userId),
      ),
    );
    
    // If social media was updated, refresh the data
    if (result == true) {
      await _loadUserProfile();
    }
=======
  void _navigateToEditProfile() {
    // Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Edit Profile feature coming soon",
          style: AppTheme.darkTheme.textTheme.bodyMedium,
        ),
        backgroundColor: AppTheme.surfaceDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              "Change Profile Photo",
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: AppTheme.primaryOrange,
                size: 6.w,
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
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: AppTheme.primaryOrange,
                size: 6.w,
              ),
              title: Text(
                "Choose from Gallery",
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon("Gallery");
              },
            ),
            SizedBox(height: 2.h),
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
          "Manage your payment methods and payout settings. This feature integrates with Stripe for secure transactions.",
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
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          "Logout",
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "Are you sure you want to logout? Your data will be retained for when you return.",
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
              AppRoutes.pushReplacementNamed(
                context,
                AppRoutes.loginScreen,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
            ),
            child: Text(
              "Logout",
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
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

<<<<<<< HEAD
  void _showLocationInput() {
    final TextEditingController locationController = TextEditingController(
      text: userData?['frequent_location'] as String? ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          "Frequent Performance Location",
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: locationController,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: "e.g., Times Square, NYC",
            hintStyle: TextStyle(color: AppTheme.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryOrange),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryOrange, width: 2),
            ),
          ),
          maxLines: 2,
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
            onPressed: () async {
              final location = locationController.text.trim();
              final success = await _profileService.updateFrequentLocation(
                widget.userId,
                location,
              );
              
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  await _loadUserProfile();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Location updated successfully!'),
                      backgroundColor: AppTheme.primaryOrange,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('This feature is not available yet'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
            ),
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleInput() {
    final TextEditingController scheduleController = TextEditingController(
      text: userData?['performance_schedule'] as String? ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          "Performance Schedule",
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: scheduleController,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: "e.g., Weekends 2-5 PM",
            hintStyle: TextStyle(color: AppTheme.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryOrange),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryOrange, width: 2),
            ),
          ),
          maxLines: 3,
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
            onPressed: () async {
              final schedule = scheduleController.text.trim();
              final success = await _profileService.updatePerformanceSchedule(
                widget.userId,
                schedule,
              );
              
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  await _loadUserProfile();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Schedule updated successfully!'),
                      backgroundColor: AppTheme.primaryOrange,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('This feature is not available yet'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
            ),
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD

  // Format role display names
  String _formatRole(String? role) {
    if (role == null || role.isEmpty) return 'Street Performer';
    
    switch (role.toLowerCase()) {
      case 'street_performer':
      case 'performer':
        return 'Street Performer';
      case 'new_yorker':
      case 'newyorker':
        return 'New Yorker';
      case 'admin':
        return 'Admin';
      default:
        return role
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  // Build avatar with initials fallback
  Widget _buildAvatar(String? imageUrl, String? fullName) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialsAvatar(fullName);
          },
        ),
      );
    } else {
      return _buildInitialsAvatar(fullName);
    }
  }

  // Build initials avatar with grey background
  Widget _buildInitialsAvatar(String? fullName) {
    String initials = 'UN';
    if (fullName != null && fullName.isNotEmpty) {
      final nameParts = fullName.trim().split(' ');
      if (nameParts.length >= 2) {
        initials = '${nameParts[0][0]}${nameParts[1][0]}';
      } else if (nameParts.length == 1 && nameParts[0].isNotEmpty) {
        initials = nameParts[0][0] * 2;
      }
    }
    
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
}
