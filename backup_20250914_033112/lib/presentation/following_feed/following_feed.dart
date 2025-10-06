import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ynfny/core/app_export.dart';
import '../../services/supabase_service.dart';
import '../../services/video_service.dart';
import '../../widgets/feed_navigation_bottom_widget.dart';
import '../../widgets/feed_navigation_header_widget.dart';
import './widgets/following_context_menu_widget.dart';
import './widgets/following_empty_state_widget.dart';
import './widgets/following_video_player_widget.dart';

class FollowingFeed extends StatefulWidget {
  const FollowingFeed({Key? key}) : super(key: key);

  @override
  State<FollowingFeed> createState() => _FollowingFeedState();
}

class _FollowingFeedState extends State<FollowingFeed>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final VideoService _videoService = VideoService();
  final SupabaseService _supabaseService = SupabaseService();

  List<Map<String, dynamic>> _videos = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _currentVideoIndex = 0;
  String? _currentUserRole;
  bool _isLoadingMore = false;
  bool _showContextMenu = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Get user role
      _currentUserRole = await _supabaseService.getUserRole();

      // Load following feed
      final videos = await _videoService.getFollowingFeed(limit: 20);

      if (mounted) {
        setState(() {
          _videos = videos.map((video) => _transformVideoData(video)).toList();
          _isLoading = false;
          _hasError = false;
          _unreadCount = 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading following feed: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Map<String, dynamic> _transformVideoData(Map<String, dynamic> rawVideo) {
    final performer = rawVideo['performer'] as Map<String, dynamic>?;

    return {
      'id': rawVideo['id'],
      'title': rawVideo['title'] ?? 'Untitled Performance',
      'description': rawVideo['description'] ?? '',
      'thumbnail': rawVideo['thumbnail_url'] ?? '',
      'videoUrl': rawVideo['video_url'] ?? '',
      'duration': rawVideo['duration'] ?? 0,
      'likeCount': rawVideo['like_count'] ?? 0,
      'commentCount': rawVideo['comment_count'] ?? 0,
      'shareCount': rawVideo['share_count'] ?? 0,
      'viewCount': rawVideo['view_count'] ?? 0,
      'isLiked': false, // Will be updated based on user interactions
      'performerUsername': performer?['username'] ?? 'performer',
      'performerAvatar': performer?['profile_image_url'] ?? '',
      'performanceType': performer?['performance_type'] ?? 'other',
      'isVerified': performer?['is_verified'] ?? false,
      'location': rawVideo['location_name'] ?? rawVideo['borough'] ?? 'NYC',
      'caption': rawVideo['description'] ?? '',
      'createdAt': rawVideo['created_at'],
      'thumbnailUrl': rawVideo['thumbnail_url'] ?? '',
      'likesCount': rawVideo['like_count'] ?? 0,
      'commentsCount': rawVideo['comment_count'] ?? 0,
      'sharesCount': rawVideo['share_count'] ?? 0,
      'performerId': performer?['id'] ?? '', // Add performer ID for navigation
      'isFollowing': true, // Following feed specific
      'timestamp': _formatTimestamp(rawVideo['created_at']),
    };
  }

  String _formatTimestamp(String? createdAt) {
    if (createdAt == null) return 'Just now';

    final dateTime = DateTime.tryParse(createdAt);
    if (dateTime == null) return 'Just now';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Future<void> _loadMoreVideos() async {
    if (_isLoadingMore) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });

      final newVideos = await _videoService.getFollowingFeed(
          limit: 10, offset: _videos.length);

      if (mounted && newVideos.isNotEmpty) {
        setState(() {
          _videos.addAll(
              newVideos.map((video) => _transformVideoData(video)).toList());
        });
      }
    } catch (e) {
      debugPrint('Error loading more videos: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _refreshFeed() async {
    HapticFeedback.mediumImpact();
    await _loadInitialData();
    HapticFeedback.lightImpact();
  }

  void _onVideoChanged(int index) {
    setState(() {
      _currentVideoIndex = index;
    });

    // Record video view
    if (index < _videos.length) {
      _videoService.recordVideoView(_videos[index]['id']);
    }

    // Load more videos when approaching end
    if (index >= _videos.length - 3 && !_isLoadingMore) {
      _loadMoreVideos();
    }
  }

  void _onVideoLike(String videoId) async {
    try {
      await _videoService.toggleVideoLike(videoId);

      // Update local state
      final videoIndex = _videos.indexWhere((v) => v['id'] == videoId);
      if (videoIndex != -1) {
        setState(() {
          final currentVideo = _videos[videoIndex];
          final isCurrentlyLiked = currentVideo['isLiked'] ?? false;
          final currentLikes = currentVideo['likeCount'] ?? 0;

          _videos[videoIndex]['isLiked'] = !isCurrentlyLiked;
          _videos[videoIndex]['likeCount'] =
              isCurrentlyLiked ? currentLikes - 1 : currentLikes + 1;
          _videos[videoIndex]['likesCount'] = _videos[videoIndex]['likeCount'];
        });
      }
      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error liking video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to like video. Please try again.'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }

  void _onVideoComment(String videoId) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
            height: 70,
            decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(children: [
              Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                      color: AppTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(2))),
              Expanded(
                  child: Center(
                      child: Text('Comments feature coming soon!',
                          style: Theme.of(context).textTheme.bodyLarge))),
            ])));
  }

  void _onVideoShare(String videoId) {
    HapticFeedback.selectionClick();
    debugPrint('Sharing video: $videoId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share feature coming soon!'),
        backgroundColor: AppTheme.primaryOrange,
      ),
    );
  }

  void _onProfileTap(String performerId) {
    if (performerId.isNotEmpty) {
      Navigator.pushNamed(
        context,
        AppRoutes.performerProfile,
        arguments: performerId,
      );
    }
  }

  void _onDonate(String videoId) {
    final video = _videos.firstWhere((v) => v['id'] == videoId);
    final performerId = video['performerId'] ?? '';

    if (performerId.isNotEmpty) {
      Navigator.pushNamed(
        context,
        AppRoutes.donationFlow,
        arguments: {
          'performerId': performerId,
          'videoId': videoId,
        },
      );
    }
  }

  void _onLike(int videoIndex) {
    final videoId = _videos[videoIndex]['id'];
    _onVideoLike(videoId);
  }

  void _onComment() {
    final videoId = _videos[_currentVideoIndex]['id'];
    _onVideoComment(videoId);
  }

  void _onShare() {
    final videoId = _videos[_currentVideoIndex]['id'];
    _onVideoShare(videoId);
  }

  void _showContextMenuAction() {
    setState(() {
      _showContextMenu = true;
    });
    HapticFeedback.mediumImpact();
  }

  void _hideContextMenu() {
    setState(() {
      _showContextMenu = false;
    });
  }

  void _onUnfollow() {
    setState(() {
      _videos.removeAt(_currentVideoIndex);
      if (_currentVideoIndex >= _videos.length && _videos.isNotEmpty) {
        _currentVideoIndex = _videos.length - 1;
        _pageController.animateToPage(
          _currentVideoIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _onSave() {
    HapticFeedback.lightImpact();
  }

  void _onReport() {
    HapticFeedback.mediumImpact();
  }

  void _navigateToDiscovery() {
    Navigator.pushReplacementNamed(context, AppRoutes.discoveryFeed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Stack(children: [
          // Main content
          _isLoading
              ? _buildLoadingState()
              : _hasError
                  ? _buildErrorState()
                  : _videos.isEmpty
                      ? FollowingEmptyStateWidget(
                          onDiscoverTap: _navigateToDiscovery,
                        )
                      : Column(
                          children: [
                            // Navigation Header - Same styling as Discovery Feed
                            FeedNavigationHeaderWidget(
                              currentFeed: 'following',
                              showSearch: false,
                              unreadCount: _unreadCount,
                              onRefresh: _refreshFeed,
                            ),

                            // Video Feed
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: _refreshFeed,
                                color: AppTheme.primaryOrange,
                                backgroundColor: AppTheme.surfaceDark,
                                child: PageView.builder(
                                  controller: _pageController,
                                  scrollDirection: Axis.vertical,
                                  onPageChanged: _onVideoChanged,
                                  itemCount: _videos.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onLongPress: _showContextMenuAction,
                                      child: FollowingVideoPlayerWidget(
                                        videoData: _videos[index],
                                        onLike: () => _onLike(index),
                                        onComment: _onComment,
                                        onShare: _onShare,
                                        onDonate: () =>
                                            _onDonate(_videos[index]['id']),
                                        onProfileTap: () => _onProfileTap(
                                            _videos[index]['performerId'] ??
                                                ''),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Bottom Navigation Header - Added from Discovery Feed
                            FeedNavigationBottomWidget(
                              currentFeed: 'following',
                              showSearch: false,
                              unreadCount: _unreadCount,
                              onRefresh: _refreshFeed,
                            ),
                          ],
                        ),

          // Bottom navigation for performers
          if (_currentUserRole == 'street_performer') _buildBottomNavigation(),

          // Loading indicator for pagination
          if (_isLoadingMore)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark.withOpacity( 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryOrange,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),

          // Context Menu Overlay
          if (_showContextMenu)
            FollowingContextMenuWidget(
              onUnfollow: _onUnfollow,
              onSave: _onSave,
              onReport: _onReport,
              onShare: () => _onShare(),
              onClose: _hideContextMenu,
            ),
        ]));
  }

  Widget _buildBottomNavigation() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
                color: AppTheme.surfaceDark.withOpacity( 0.9),
                border: Border(
                    top: BorderSide(color: AppTheme.borderSubtle, width: 0.5))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.home, 'Home', true, onTap: () {
                    Navigator.pushNamed(context, AppRoutes.userProfile);
                  }),
                  _buildNavItem(Icons.add_circle_outline, 'Upload', false,
                      onTap: () {
                    Navigator.pushNamed(context, '/video-recording');
                  }),
                  _buildNavItem(Icons.person_outline, 'Profile', false,
                      onTap: () {
                    Navigator.pushNamed(context, '/user-profile');
                  }),
                ])));
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive,
      {VoidCallback? onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              size: 24,
              color:
                  isActive ? AppTheme.primaryOrange : AppTheme.textSecondary),
          SizedBox(height: 4),
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isActive
                      ? AppTheme.primaryOrange
                      : AppTheme.textSecondary)),
        ]));
  }

  Widget _buildLoadingState() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CircularProgressIndicator(color: AppTheme.primaryOrange),
      SizedBox(height: 16),
      Text('Loading your following feed...',
          style: Theme.of(context).textTheme.bodyLarge),
    ]));
  }

  Widget _buildErrorState() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.error_outline, size: 48, color: AppTheme.accentRed),
      SizedBox(height: 16),
      Text('Unable to load following feed',
          style: Theme.of(context).textTheme.headlineSmall),
      SizedBox(height: 8),
      Text('Check your connection and try again',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppTheme.textSecondary)),
      SizedBox(height: 24),
      ElevatedButton(onPressed: _loadInitialData, child: Text('Retry')),
    ]));
  }
}
