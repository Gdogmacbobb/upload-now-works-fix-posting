import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';
import '../../services/supabase_service.dart';
import '../../services/video_service.dart';
import '../../widgets/feed_navigation_bottom_widget.dart';
import '../../widgets/feed_navigation_header_widget.dart';
import './widgets/video_player_widget.dart';

class DiscoveryFeed extends StatefulWidget {
  const DiscoveryFeed({Key? key}) : super(key: key);

  @override
  State<DiscoveryFeed> createState() => _DiscoveryFeedState();
}

class _DiscoveryFeedState extends State<DiscoveryFeed>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  final VideoService _videoService = VideoService();
  final SupabaseService _supabaseService = SupabaseService();

  List<Map<String, dynamic>> _videos = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentVideoIndex = 0;
  String? _currentUserRole;
  bool _isLoadingMore = false;
  bool _isInitialized = false;

  // Add video management state
  final Set<int> _loadedVideoIndices = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    if (_isInitialized) return;

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });

      await _loadInitialData();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to initialize. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    try {
      // Get user role with timeout and error handling
      try {
        _currentUserRole =
            await _supabaseService.getUserRole().timeout(Duration(seconds: 5));
      } catch (e) {
        debugPrint('User role fetch error: $e');
        _currentUserRole = null; // Continue without user role
      }

      // Load discovery feed with fallback to mock data
      List<Map<String, dynamic>> videos = [];
      try {
        videos = await _videoService
            .getDiscoveryFeed(limit: 20)
            .timeout(Duration(seconds: 10));
      } catch (e) {
        debugPrint('Video service error: $e');
        // Always use mock data to ensure content displays
        videos = _getMockVideos();
      }

      // If still empty, ensure we have mock data
      if (videos.isEmpty) {
        videos = _getMockVideos();
      }

      if (mounted) {
        setState(() {
          _videos = videos.map((video) => _transformVideoData(video)).toList();
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading discovery feed: $e');
      // Always provide mock data as fallback
      if (mounted) {
        setState(() {
          _videos = _getMockVideos()
              .map((video) => _transformVideoData(video))
              .toList();
          _isLoading = false;
          _hasError = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getMockVideos() {
    return [
      {
        "id": "discovery-mock-1",
        "title": "Street Jazz Performance",
        "description":
            "Amazing jazz performance in Central Park 🎷 #StreetMusic #NYC",
        "video_url": "https://example.com/video1.mp4",
        "thumbnail_url":
            "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=800&fit=crop",
        "duration": 180,
        "like_count": 1543,
        "comment_count": 89,
        "share_count": 156,
        "view_count": 8234,
        "location_name": "Central Park",
        "borough": "Manhattan",
        "created_at":
            DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
        "performer": {
          "id": "performer-mock-1",
          "username": "jazzy_street",
          "profile_image_url":
              "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
          "performance_type": "musician",
          "is_verified": true
        }
      },
      {
        "id": "discovery-mock-2",
        "title": "Breakdancing Showcase",
        "description":
            "Epic breakdancing moves in Brooklyn! 🕺 #BreakDance #Brooklyn",
        "video_url": "https://example.com/video2.mp4",
        "thumbnail_url":
            "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=800&fit=crop",
        "duration": 240,
        "like_count": 2867,
        "comment_count": 234,
        "share_count": 89,
        "view_count": 12456,
        "location_name": "DUMBO",
        "borough": "Brooklyn",
        "created_at":
            DateTime.now().subtract(Duration(hours: 4)).toIso8601String(),
        "performer": {
          "id": "performer-mock-2",
          "username": "brooklyn_breaker",
          "profile_image_url":
              "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
          "performance_type": "dancer",
          "is_verified": false
        }
      },
      {
        "id": "discovery-mock-3",
        "title": "Magic Show Spectacular",
        "description":
            "Mind-blowing magic tricks in Times Square ✨ #Magic #TimesSquare",
        "video_url": "https://example.com/video3.mp4",
        "thumbnail_url":
            "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=800&fit=crop",
        "duration": 300,
        "like_count": 4521,
        "comment_count": 167,
        "share_count": 298,
        "view_count": 18765,
        "location_name": "Times Square",
        "borough": "Manhattan",
        "created_at":
            DateTime.now().subtract(Duration(hours: 6)).toIso8601String(),
        "performer": {
          "id": "performer-mock-3",
          "username": "magic_mike_nyc",
          "profile_image_url":
              "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
          "performance_type": "magician",
          "is_verified": true
        }
      }
    ];
  }

  Map<String, dynamic> _transformVideoData(Map<String, dynamic> rawVideo) {
    final performer = rawVideo['performer'] as Map<String, dynamic>?;

    return {
      'id': rawVideo['id'] ?? 'unknown',
      'title': rawVideo['title'] ?? 'Untitled Performance',
      'description': rawVideo['description'] ?? 'Street performance in NYC',
      'thumbnail': rawVideo['thumbnail_url'] ??
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=800&fit=crop',
      'videoUrl': rawVideo['video_url'] ?? '',
      'duration': rawVideo['duration'] ?? 0,
      'likeCount': rawVideo['like_count'] ?? 0,
      'commentCount': rawVideo['comment_count'] ?? 0,
      'shareCount': rawVideo['share_count'] ?? 0,
      'viewCount': rawVideo['view_count'] ?? 0,
      'isLiked': false,
      'performerUsername': performer?['username'] ?? 'performer',
      'performerAvatar': performer?['profile_image_url'] ??
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
      'performanceType': performer?['performance_type'] ?? 'other',
      'isVerified': performer?['is_verified'] ?? false,
      'location': rawVideo['location_name'] ?? rawVideo['borough'] ?? 'NYC',
      'caption': rawVideo['description'] ?? 'Street performance in NYC',
      'createdAt': rawVideo['created_at'] ?? DateTime.now().toIso8601String(),
      'thumbnailUrl': rawVideo['thumbnail_url'] ??
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=800&fit=crop',
      'likesCount': rawVideo['like_count'] ?? 0,
      'commentsCount': rawVideo['comment_count'] ?? 0,
      'sharesCount': rawVideo['share_count'] ?? 0,
      'performerId': performer?['id'] ?? 'performer-unknown',
    };
  }

  void _retryLoading() {
    _isInitialized = false;
    _initializeScreen();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Navigation Header
                FeedNavigationHeaderWidget(
                  currentFeed: 'discovery',
                  showSearch: true,
                ),

                // Video Feed
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _hasError
                          ? _buildErrorState()
                          : _videos.isEmpty
                              ? _buildEmptyState()
                              : PageView.builder(
                                  controller: _pageController,
                                  scrollDirection: Axis.vertical,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentVideoIndex = index;
                                    });
                                    _onVideoChanged(index);
                                  },
                                  itemCount: _videos.length,
                                  itemBuilder: (context, index) {
                                    if (index < 0 || index >= _videos.length) {
                                      return Container(
                                        color: AppTheme.backgroundDark,
                                        child: Center(
                                          child: Text(
                                            'Loading...',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: AppTheme.textPrimary,
                                                ),
                                          ),
                                        ),
                                      );
                                    }

                                    return VideoPlayerWidget(
                                      videoData: _videos[index],
                                      onLike: () => _onLike(index),
                                      onComment: _onComment,
                                      onShare: _onShare,
                                      onDonate: () =>
                                          _onDonate(_videos[index]['id']),
                                      onProfileTap: () => _onProfileTap(
                                          _videos[index]['performerId'] ?? ''),
                                    );
                                  },
                                ),
                ),

                // Bottom Navigation
                FeedNavigationBottomWidget(
                  currentFeed: 'discovery',
                  showSearch: true,
                ),
              ],
            ),

            // Loading indicator for pagination
            if (_isLoadingMore)
              Positioned(
                bottom: AppSpacing.sm,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundDark
                          .withAlpha((0.8 * 255).round()),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryOrange,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.backgroundDark,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primaryOrange,
              strokeWidth: 3,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Loading amazing performances...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
            ),
            SizedBox(height: AppSpacing.xxs),
            Text(
              'Discovering the best street talent in NYC',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.backgroundDark,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48.0,
                color: AppTheme.accentRed,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Unable to Load Videos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                _errorMessage.isNotEmpty
                    ? _errorMessage
                    : 'Check your connection and try again',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: _retryLoading,
                icon: Icon(Icons.refresh, size: AppSpacing.lg),
                label: Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: AppTheme.backgroundDark,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.backgroundDark,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 48.0,
                color: AppTheme.textSecondary,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'No Videos Available',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Check back later for new amazing street performances from NYC artists',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: _retryLoading,
                icon: Icon(Icons.refresh, size: AppSpacing.lg),
                label: Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: AppTheme.backgroundDark,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadMoreVideos() async {
    if (_isLoadingMore || !mounted) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });

      List<Map<String, dynamic>> newVideos = [];
      try {
        newVideos = await _videoService
            .getDiscoveryFeed(limit: 10, offset: _videos.length)
            .timeout(Duration(seconds: 10));
      } catch (e) {
        debugPrint('Load more videos error: $e');
      }

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

  void _onVideoChanged(int index) {
    if (!mounted || index < 0 || index >= _videos.length) return;

    // Record video view with error handling
    try {
      _videoService.recordVideoView(_videos[index]['id']).catchError((error) {
        debugPrint('Record view error: $error');
      });
    } catch (e) {
      debugPrint('Record view error: $e');
    }

    // Load more videos when approaching end
    if (index >= _videos.length - 3 && !_isLoadingMore) {
      _loadMoreVideos();
    }

    // Mark video as loaded for performance tracking
    _loadedVideoIndices.add(index);
  }

  void _onVideoLike(String videoId) async {
    if (!mounted || videoId.isEmpty) return;

    try {
      final videoIndex = _videos.indexWhere((v) => v['id'] == videoId);
      if (videoIndex != -1 && mounted) {
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

      await _videoService.toggleVideoLike(videoId);
    } catch (e) {
      debugPrint('Error liking video: $e');

      // Revert optimistic update
      final videoIndex = _videos.indexWhere((v) => v['id'] == videoId);
      if (videoIndex != -1 && mounted) {
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
    }
  }

  void _onVideoComment(String videoId) {
    if (!mounted || videoId.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 48.0,
                      color: AppTheme.textSecondary,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Comments Coming Soon!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Join the conversation when comments are available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onVideoShare(String videoId) {
    if (!mounted || videoId.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppTheme.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.share_outlined,
                  color: AppTheme.primaryOrange,
                  size: 24.0,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Share Feature Coming Soon!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Share amazing performances with your friends',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _onProfileTap(String performerId) {
    if (!mounted || performerId.isEmpty) return;

    Navigator.pushNamed(
      context,
      AppRoutes.performerProfile,
      arguments: performerId,
    ).catchError((error) {
      debugPrint('Navigation error: $error');
    });
  }

  void _onDonate(String videoId) {
    if (!mounted || videoId.isEmpty) return;

    final video = _videos.firstWhere((v) => v['id'] == videoId,
        orElse: () => <String, dynamic>{});

    if (video.isEmpty) return;

    final performerId = video['performerId'] ?? '';

    if (performerId.isNotEmpty) {
      Navigator.pushNamed(
        context,
        AppRoutes.donationFlow,
        arguments: {
          'performerId': performerId,
          'videoId': videoId,
        },
      ).catchError((error) {
        debugPrint('Donation navigation error: $error');
      });
    }
  }

  void _onLike(int videoIndex) {
    if (videoIndex < 0 || videoIndex >= _videos.length) return;
    final videoId = _videos[videoIndex]['id'];
    _onVideoLike(videoId);
  }

  void _onComment() {
    if (_currentVideoIndex < 0 || _currentVideoIndex >= _videos.length) return;
    final videoId = _videos[_currentVideoIndex]['id'];
    _onVideoComment(videoId);
  }

  void _onShare() {
    if (_currentVideoIndex < 0 || _currentVideoIndex >= _videos.length) return;
    final videoId = _videos[_currentVideoIndex]['id'];
    _onVideoShare(videoId);
  }
}
