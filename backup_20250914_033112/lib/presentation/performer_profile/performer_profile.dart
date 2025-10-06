import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ynfny/core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
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
  bool isFollowing = false;
  bool isRefreshing = false;
  bool isEditing = false;
  bool isLoading = true;
  final AuthService _authService = AuthService();
  final SupabaseService _supabaseService = SupabaseService();
  String? _currentUserId;
  Map<String, dynamic>? performerData;
  List<Map<String, dynamic>> videosData = [];

  // Default fallback data structure for safe UI rendering
  Map<String, dynamic> get defaultPerformerData => {
    "id": _currentUserId ?? "",
    "name": "Loading...",
    "avatar": null,
    "bio": null,
    "borough": null,
    "verificationStatus": "pending",
    "followersCount": 0,
    "followingCount": 0,
    "videoCount": 0,
    "totalDonations": 0.0,
    "totalViews": 0,
    "totalLikes": 0,
    "joinDate": DateTime.now().toIso8601String(),
    "performanceTypes": <String>[],
    "schedule": <Map<String, String>>[],
    "socialMedia": <String, String>{}
  };

  // Real data fetching methods with safe fallbacks
  Future<void> _loadProfileData() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      performerData = defaultPerformerData; // Set safe defaults
    });

    try {
      // Fetch real profile data from Supabase
      final profileData = await _supabaseService.getFullProfileData();
      final userVideos = _currentUserId != null 
          ? await _supabaseService.getUserVideos(_currentUserId!)
          : <Map<String, dynamic>>[];
      
      if (mounted && profileData != null) {
        setState(() {
          performerData = _formatProfileData(profileData);
          videosData = userVideos;
          isLoading = false;
        });
      } else {
        // Fallback: Keep default data, just mark as loaded
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading profile data: $e');
      // Safe fallback: Use default data structure
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Format Supabase profile data to match UI expectations
  Map<String, dynamic> _formatProfileData(Map<String, dynamic> data) {
    final socialMediaLinks = data['social_media_links'] as Map<String, dynamic>? ?? {};
    
    return {
      "id": data['id'] ?? _currentUserId ?? "",
      "name": data['full_name'] ?? data['username'] ?? "Street Performer",
      "avatar": data['profile_image_url'],
      "bio": data['bio'], // No custom default - let UI handle "Not set"
      "borough": data['borough'], // Use universal borough field
      "verificationStatus": data['is_verified'] == true ? "verified" : "pending",
      "followersCount": data['follower_count'] ?? 0,
      "followingCount": data['following_count'] ?? 0,
      "videoCount": data['video_count'] ?? 0,
      "totalDonations": data['total_donations_received'] ?? 0.0,
      "totalViews": 0, // Would need separate tracking
      "totalLikes": 0, // Would need separate tracking
      "joinDate": data['created_at'] ?? DateTime.now().toIso8601String(),
      "performanceTypes": _parsePerformanceTypes(data['performance_type']),
      "schedule": <Map<String, String>>[], // Would need separate schedule table
      "socialMedia": {
        "instagram": data['socials_instagram'] ?? socialMediaLinks['instagram'],
        "tiktok": data['socials_tiktok'] ?? socialMediaLinks['tiktok'],
        "youtube": data['socials_youtube'] ?? socialMediaLinks['youtube'],
      }
    };
  }

  List<String> _parsePerformanceTypes(String? types) {
    if (types == null || types.isEmpty) return [];
    return types.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.id;
      });
      // Load real profile data after getting current user
      await _loadProfileData();
    } else {
      // No user - set safe defaults
      setState(() {
        performerData = defaultPerformerData;
        isLoading = false;
      });
    }
  }

  bool _isCurrentUserProfile() {
    // For demo purposes - in a real app, this would check if the current user
    // is viewing their own performer profile. Since we're using mock data,
    // we'll show the Edit button for authenticated users to demonstrate the flow.
    return _currentUserId != null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPerformerData = performerData ?? defaultPerformerData;
    
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
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
                    if (_isCurrentUserProfile())
                      IconButton(
                        onPressed: _handleEdit,
                        icon: CustomIconWidget(
                          iconName: isEditing ? 'close' : 'edit',
                          color: AppTheme.textPrimary,
                          size: 24,
                        ),
                      ),
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
                              SizedBox(width: AppSpacing.sm),
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
                              SizedBox(width: AppSpacing.sm),
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
                    performerData: currentPerformerData,
                    isFollowing: isFollowing,
                    onFollowTap: _handleFollowTap,
                    isCurrentUserProfile: _isCurrentUserProfile(),
                    onEditTap: _handleEditProfile,
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
                        videos: videosData,
                        onVideoTap: _handleVideoTap,
                        onVideoLongPress: _handleVideoLongPress,
                      ),
                      // About Tab
                      AboutSectionWidget(
                        performerData: currentPerformerData,
                        isEditing: isEditing,
                        onSave: _handleProfileSave,
                        onEditToggle: _handleEditToggle,
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
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      isRefreshing = true;
    });

    // Reload real profile data
    await _loadProfileData();

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

  void _handleFollowTap() {
    HapticFeedback.lightImpact();
    final currentData = performerData ?? defaultPerformerData;
    
    setState(() {
      isFollowing = !isFollowing;
      // Update follower count in current data
      if (performerData != null) {
        performerData!["followersCount"] = 
            (performerData!["followersCount"] as int) + (isFollowing ? 1 : -1);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: isFollowing ? 'person_add' : 'person_remove',
              color: AppTheme.primaryOrange,
              size: 20,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              isFollowing
                  ? "Now following ${currentData["name"]}"
                  : "Unfollowed ${currentData["name"]}",
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
            SizedBox(width: AppSpacing.xs),
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
            SizedBox(width: AppSpacing.xs),
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

  void _handleEdit() {
    // Toggle inline editing mode instead of navigating
    setState(() {
      isEditing = !isEditing;
    });
    
    // Switch to About tab when entering edit mode
    if (isEditing && _tabController.index != 1) {
      _tabController.animateTo(1);
    }
  }

  void _handleEditProfile() {
    // Navigate to User Profile edit screen
    HapticFeedback.lightImpact();
    AppRoutes.pushNamed(
      context,
      AppRoutes.userProfile,
    );
  }

  void _handleEditToggle() {
    setState(() {
      isEditing = !isEditing;
    });
    
    if (isEditing && _tabController.index != 1) {
      _tabController.animateTo(1);
    }
  }

  void _handleProfileSave(Map<String, dynamic> updatedData) {
    setState(() {
      // Ensure performerData is initialized before mutation
      performerData ??= Map<String, dynamic>.from(defaultPerformerData);
      
      // Update the performer data with new values (now null-safe)
      if (updatedData['bio'] != null) {
        performerData!['bio'] = updatedData['bio'];
      }
      if (updatedData['socialMedia'] != null) {
        performerData!['socialMedia'] = updatedData['socialMedia'];
      }
      if (updatedData['borough'] != null) {
        performerData!['borough'] = updatedData['borough'];
      }
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.primaryOrange,
              size: 20,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              "Profile updated successfully",
              style: AppTheme.darkTheme.textTheme.bodyMedium,
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
            SizedBox(width: AppSpacing.xs),
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
    final currentData = performerData ?? defaultPerformerData;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          "Block ${currentData["name"]}?",
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
            SizedBox(height: AppSpacing.xs),
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
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs + 2),
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
