import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'package:ynfny/utils/responsive_scale.dart';

import '../../core/app_export.dart';
import '../../services/profile_service.dart';
import '../../services/supabase_service.dart';
import '../../services/video_service.dart';
import '../../services/image_upload_service.dart';
=======
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
import './widgets/about_section_widget.dart';
import './widgets/donation_button_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/video_context_menu_widget.dart';
import './widgets/video_grid_widget.dart';

class PerformerProfile extends StatefulWidget {
  const PerformerProfile({super.key});

  @override
  State<PerformerProfile> createState() => _PerformerProfileState();
}

class _PerformerProfileState extends State<PerformerProfile>
    with TickerProviderStateMixin {
  late TabController _tabController;
<<<<<<< HEAD
  final SupabaseService _supabaseService = SupabaseService();
  final VideoService _videoService = VideoService();
  final ProfileService _profileService = ProfileService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  
  // UI state
  bool isFollowing = false;
  bool isRefreshing = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isUploadingPhoto = false;
  
  // Real data from Supabase
  Map<String, dynamic>? _profileData;
  List<Map<String, dynamic>> _userVideos = [];
  
  // Default placeholder for missing profile images
  static const String _defaultAvatarIcon = 'person';
=======
  bool isFollowing = false;
  bool isRefreshing = false;

  // Mock performer data
  final Map<String, dynamic> performerData = {
    "id": "performer_001",
    "name": "Marcus \"The Beat\" Rodriguez",
    "avatar":
        "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400",
    "bio":
        "Street drummer bringing NYC rhythms to life 🥁 Performing in Times Square, Central Park, and Brooklyn Bridge. Follow for daily beats and street vibes! #NYCStreetMusic #DrumLife",
    "verificationStatus": "verified",
    "followersCount": 12500,
    "followingCount": 89,
    "videoCount": 47,
    "totalDonations": 2850,
    "totalViews": 450000,
    "totalLikes": 28500,
    "joinDate": "2023-03-15T10:30:00Z",
    "performanceTypes": ["Drumming", "Percussion", "Street Performance"],
    "frequentLocations": [
      "Times Square",
      "Central Park",
      "Brooklyn Bridge",
      "Washington Square Park"
    ],
    "schedule": [
      {
        "day": "Monday - Friday",
        "time": "6:00 PM - 9:00 PM",
        "location": "Times Square (Red Steps)"
      },
      {
        "day": "Saturday",
        "time": "2:00 PM - 8:00 PM",
        "location": "Central Park (Bethesda Fountain)"
      },
      {
        "day": "Sunday",
        "time": "12:00 PM - 6:00 PM",
        "location": "Brooklyn Bridge (Manhattan Side)"
      }
    ],
    "socialMedia": {
      "instagram": "@marcusthebeat",
      "tiktok": "@marcusbeats",
      "youtube": "Marcus Rodriguez Music"
    }
  };

  // Mock videos data
  final List<Map<String, dynamic>> videosData = [
    {
      "id": "video_001",
      "title": "Epic Drum Solo in Times Square",
      "thumbnailUrl":
          "https://images.pexels.com/photos/1407322/pexels-photo-1407322.jpeg?auto=compress&cs=tinysrgb&w=400",
      "duration": 45,
      "viewCount": 15200,
      "likeCount": 1250,
      "uploadDate": "2025-01-25T18:30:00Z"
    },
    {
      "id": "video_002",
      "title": "Crowd Goes Wild - Central Park Performance",
      "thumbnailUrl":
          "https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg?auto=compress&cs=tinysrgb&w=400",
      "duration": 38,
      "viewCount": 8900,
      "likeCount": 720,
      "uploadDate": "2025-01-23T16:45:00Z"
    },
    {
      "id": "video_003",
      "title": "Rainy Day Beats Under Brooklyn Bridge",
      "thumbnailUrl":
          "https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg?auto=compress&cs=tinysrgb&w=400",
      "duration": 52,
      "viewCount": 12800,
      "likeCount": 980,
      "uploadDate": "2025-01-22T14:20:00Z"
    },
    {
      "id": "video_004",
      "title": "Collaboration with Street Dancer",
      "thumbnailUrl":
          "https://images.pexels.com/photos/1540406/pexels-photo-1540406.jpeg?auto=compress&cs=tinysrgb&w=400",
      "duration": 60,
      "viewCount": 22100,
      "likeCount": 1850,
      "uploadDate": "2025-01-20T19:15:00Z"
    },
    {
      "id": "video_005",
      "title": "Morning Warm-up Session",
      "thumbnailUrl":
          "https://images.pexels.com/photos/1699161/pexels-photo-1699161.jpeg?auto=compress&cs=tinysrgb&w=400",
      "duration": 28,
      "viewCount": 5600,
      "likeCount": 420,
      "uploadDate": "2025-01-19T09:30:00Z"
    },
    {
      "id": "video_006",
      "title": "Sunset Beats at Washington Square",
      "thumbnailUrl":
          "https://images.pexels.com/photos/1644888/pexels-photo-1644888.jpeg?auto=compress&cs=tinysrgb&w=400",
      "duration": 41,
      "viewCount": 9800,
      "likeCount": 750,
      "uploadDate": "2025-01-18T20:00:00Z"
    }
  ];
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
<<<<<<< HEAD
    _loadProfileData();
  }

  // Load user profile and videos from Supabase using ProfileService
  Future<void> _loadProfileData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });

      // Get current user
      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Fetch user profile data using ProfileService
      final profileData = await _profileService.getUserProfile(currentUser.id);
      if (profileData == null) {
        throw Exception('Failed to load user profile');
      }

      // Fetch user's videos using ProfileService
      final videosData = await _profileService.getUserVideos(currentUser.id);

      if (mounted) {
        setState(() {
          _profileData = profileData;
          _userVideos = videosData;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load profile data. Please try again.';
        });
      }
    }
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  // Handle pull-to-refresh
  Future<void> _handleRefresh() async {
    await _loadProfileData();
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
        await _loadProfileData();
        
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

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryOrange,
          ),
        ),
      );
    }

    // Show error state
    if (_hasError) {
      return Scaffold(
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppTheme.accentRed,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                _errorMessage,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfileData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                ),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show profile data (only if not loading and no error)
=======
  @override
  Widget build(BuildContext context) {
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppTheme.primaryOrange,
            backgroundColor: AppTheme.surfaceDark,
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 0,
                  floating: true,
                  snap: true,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'arrow_back',
                      color: AppTheme.textPrimary,
                      size: 24,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: _handleShare,
                      icon: CustomIconWidget(
                        iconName: 'share',
                        color: AppTheme.textPrimary,
                        size: 24,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: CustomIconWidget(
                        iconName: 'more_vert',
                        color: AppTheme.textPrimary,
                        size: 24,
                      ),
                      color: AppTheme.surfaceDark,
                      onSelected: _handleMenuAction,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'block',
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'block',
                                color: AppTheme.accentRed,
                                size: 20,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                "Block User",
                                style: AppTheme.darkTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.accentRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'report',
                                color: AppTheme.accentRed,
                                size: 20,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                "Report Profile",
                                style: AppTheme.darkTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.accentRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Profile Header
                SliverToBoxAdapter(
                  child: ProfileHeaderWidget(
<<<<<<< HEAD
                    performerData: _profileData ?? {},
                    isFollowing: isFollowing,
                    onFollowTap: _handleFollowTap,
                    currentUserId: _supabaseService.currentUser?.id,
                    onEditTap: _handleEditProfile,
                    onProfileUpdated: _loadProfileData,
                    onAvatarTap: (_supabaseService.currentUser?.id == _profileData?['id']) ? _handleAvatarTap : null,
=======
                    performerData: performerData,
                    isFollowing: isFollowing,
                    onFollowTap: _handleFollowTap,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  ),
                ),

                // Tab Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: "Videos"),
                        Tab(text: "About"),
                      ],
                    ),
                  ),
                ),

                // Tab Content
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Videos Tab
                      VideoGridWidget(
<<<<<<< HEAD
                        videos: _userVideos,
=======
                        videos: videosData,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                        onVideoTap: _handleVideoTap,
                        onVideoLongPress: _handleVideoLongPress,
                      ),
                      // About Tab
                      AboutSectionWidget(
<<<<<<< HEAD
                        performerData: _profileData ?? {},
=======
                        performerData: performerData,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Donation Button
          DonationButtonWidget(
            onDonationTap: _handleDonationComplete,
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
=======
  Future<void> _handleRefresh() async {
    setState(() {
      isRefreshing = true;
    });

    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        isRefreshing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Profile updated",
            style: AppTheme.darkTheme.textTheme.bodyMedium,
          ),
          backgroundColor: AppTheme.surfaceDark,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

  void _handleFollowTap() {
    HapticFeedback.lightImpact();
    setState(() {
      isFollowing = !isFollowing;
<<<<<<< HEAD
      // Note: Follower count updates should be handled via Supabase in a real implementation
      // For now, we'll just update the UI state
    });

    final userName = _profileData?['full_name'] ?? _profileData?['username'] ?? 'User';
    
=======
      if (isFollowing) {
        performerData["followersCount"] =
            (performerData["followersCount"] as int) + 1;
      } else {
        performerData["followersCount"] =
            (performerData["followersCount"] as int) - 1;
      }
    });

>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: isFollowing ? 'person_add' : 'person_remove',
              color: AppTheme.primaryOrange,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              isFollowing
<<<<<<< HEAD
                  ? "Now following $userName"
                  : "Unfollowed $userName",
=======
                  ? "Now following ${performerData["name"]}"
                  : "Unfollowed ${performerData["name"]}",
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              style: AppTheme.darkTheme.textTheme.bodyMedium,
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleVideoTap(Map<String, dynamic> video) {
    HapticFeedback.lightImpact();
    // Navigate to full-screen video player
    AppRoutes.pushNamed(
      context,
      AppRoutes.videoPlayer,
      arguments: video,
    );
  }

  void _handleVideoLongPress(Map<String, dynamic> video) {
    HapticFeedback.mediumImpact();
    VideoContextMenuWidget.show(
      context,
      video,
      onSave: () => _handleVideoSave(video),
      onShare: () => _handleVideoShare(video),
      onReport: () => _handleVideoReport(video),
    );
  }

  void _handleVideoSave(Map<String, dynamic> video) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'bookmark',
              color: AppTheme.primaryOrange,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              "Video saved to collection",
              style: AppTheme.darkTheme.textTheme.bodyMedium,
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleVideoShare(Map<String, dynamic> video) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'share',
              color: AppTheme.primaryOrange,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              "Video link copied to clipboard",
              style: AppTheme.darkTheme.textTheme.bodyMedium,
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleVideoReport(Map<String, dynamic> video) {
    // Report handling is done in VideoContextMenuWidget
  }

<<<<<<< HEAD
  void _handleEditProfile() {
    HapticFeedback.lightImpact();
    
    // Navigate to profile editing screen
    // TODO: Implement profile editing screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'edit',
              color: AppTheme.primaryOrange,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              "Edit Profile feature coming soon!",
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
  void _handleShare() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'share',
              color: AppTheme.primaryOrange,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              "Profile link copied to clipboard",
              style: AppTheme.darkTheme.textTheme.bodyMedium,
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'block':
        _showBlockDialog();
        break;
      case 'report':
        _showReportDialog();
        break;
    }
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
<<<<<<< HEAD
          "Block ${_profileData?['full_name'] ?? _profileData?['username'] ?? 'User'}?",
=======
          "Block ${performerData["name"]}?",
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
          style: AppTheme.darkTheme.textTheme.titleLarge,
        ),
        content: Text(
          "You won't see their content and they won't be able to find your profile.",
          style: AppTheme.darkTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "User blocked",
                    style: AppTheme.darkTheme.textTheme.bodyMedium,
                  ),
                  backgroundColor: AppTheme.surfaceDark,
                ),
              );
            },
            child: Text(
              "Block",
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.accentRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          "Report Profile",
          style: AppTheme.darkTheme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Why are you reporting this profile?",
              style: AppTheme.darkTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            ...[
              "Fake account",
              "Inappropriate content",
              "Spam or scam",
              "Harassment",
              "Other"
            ].map((reason) => InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Report submitted. Thank you for helping keep YNFNY safe.",
                          style: AppTheme.darkTheme.textTheme.bodyMedium,
                        ),
                        backgroundColor: AppTheme.surfaceDark,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    child: Text(
                      reason,
                      style: AppTheme.darkTheme.textTheme.bodyMedium,
                    ),
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDonationComplete() {
    // Donation completion is handled in DonationButtonWidget
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.darkTheme.scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
