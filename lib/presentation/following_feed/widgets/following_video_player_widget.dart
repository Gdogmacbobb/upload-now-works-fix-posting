import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class FollowingVideoPlayerWidget extends StatefulWidget {
  final Map<String, dynamic> videoData;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onDonate;
  final VoidCallback? onProfileTap;

  const FollowingVideoPlayerWidget({
    Key? key,
    required this.videoData,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onDonate,
    this.onProfileTap,
  }) : super(key: key);

  @override
  State<FollowingVideoPlayerWidget> createState() =>
      _FollowingVideoPlayerWidgetState();
}

class _FollowingVideoPlayerWidgetState
    extends State<FollowingVideoPlayerWidget> {
  bool _isLiked = false;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.videoData['isLiked'] ?? false;
  }

  @override
  void didUpdateWidget(FollowingVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update liked state if video data changes
    if (oldWidget.videoData['id'] != widget.videoData['id']) {
      _isLiked = widget.videoData['isLiked'] ?? false;
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    widget.onLike?.call();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _getImageUrl() {
    final thumbnailUrl =
        widget.videoData['thumbnailUrl'] ?? widget.videoData['thumbnail'] ?? '';

    if (thumbnailUrl.isEmpty) {
      return 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=800&fit=crop';
    }

    return thumbnailUrl;
  }

  String _getPerformerAvatar() {
    final avatarUrl = widget.videoData['performerAvatar'] ?? '';

    if (avatarUrl.isEmpty) {
      return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face';
    }

    return avatarUrl;
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery-based positioning for pixel-perfect TikTok layout
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // TikTok-style positioning constants (in pixels)
    const headerTopOffset = 40.0;  // Header 40px below notch
    const avatarTopOffset = 80.0;  // Avatar positioned under header
    const captionBottomOffset = 130.0;  // Caption 130px above bottom nav
    const fabBottomOffset = 95.0;  // $ button 95px above bottom nav

    return Container(
      width: screenWidth,
      height: screenHeight,
      color: AppTheme.backgroundDark,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Background (full screen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _togglePlayPause,
              onDoubleTap: _toggleLike,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(_getImageUrl()),
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) {
                      debugPrint('Image loading error: $error');
                    },
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.backgroundDark.withAlpha((0.3 * 255).round()),
                        AppTheme.backgroundDark.withAlpha((0.7 * 255).round()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Play/Pause Overlay
          if (!_isPlaying)
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark.withAlpha((0.7 * 255).round()),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: AppTheme.textPrimary,
                  size: 50,
                ),
              ),
            ),

          // Top Overlay - Following Indicator (positioned with MediaQuery)
          Positioned(
            top: topInset + headerTopOffset,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withAlpha((0.5 * 255).round()),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Following',
                    style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile Avatar (positioned at top-right under header, TikTok-style)
          Positioned(
            right: 12,
            top: topInset + avatarTopOffset,
            child: GestureDetector(
              onTap: widget.onProfileTap,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryOrange,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    _getPerformerAvatar(),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 48,
                        height: 48,
                        color: AppTheme.surfaceDark,
                        child: Icon(
                          Icons.person,
                          color: AppTheme.textSecondary,
                          size: 24,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 48,
                        height: 48,
                        color: AppTheme.surfaceDark,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryOrange,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Right Side Action Buttons (vertically centered, TikTok-style)
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Like Button
                  GestureDetector(
                    onTap: _toggleLike,
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _isLiked
                                ? AppTheme.accentRed
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            color: _isLiked
                                ? AppTheme.textPrimary
                                : AppTheme.textPrimary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCount(widget.videoData['likesCount'] ??
                              widget.videoData['likeCount'] ??
                              0),
                          style: AppTheme.videoOverlayStyle(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Comment Button
                  GestureDetector(
                    onTap: widget.onComment,
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: AppTheme.textPrimary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCount(widget.videoData['commentsCount'] ??
                              widget.videoData['commentCount'] ??
                              0),
                          style: AppTheme.videoOverlayStyle(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Share Button
                  GestureDetector(
                    onTap: widget.onShare,
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.share,
                            color: AppTheme.textPrimary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCount(widget.videoData['sharesCount'] ??
                              widget.videoData['shareCount'] ??
                              0),
                          style: AppTheme.videoOverlayStyle(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Donate Button (floating $ button, positioned above bottom nav)
          Positioned(
            right: 12,
            bottom: bottomInset + fabBottomOffset,
            child: GestureDetector(
              onTap: widget.onDonate,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.attach_money,
                  color: AppTheme.backgroundDark,
                  size: 28,
                ),
              ),
            ),
          ),

          // Bottom Overlay - Performer Info (positioned above bottom nav, TikTok-style)
          Positioned(
            bottom: bottomInset + captionBottomOffset,
            left: 16,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Performer Name and Verification
                Row(
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: widget.onProfileTap,
                        child: Text(
                          '@${widget.videoData['performerUsername'] ?? 'performer'}',
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (widget.videoData['isVerified'] == true)
                      Icon(
                        Icons.verified,
                        color: AppTheme.primaryOrange,
                        size: 16,
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // Performance Type Tag
                if (widget.videoData['performanceType'] != null &&
                    widget.videoData['performanceType'].toString().isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          AppTheme.primaryOrange.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryOrange
                            .withAlpha((0.5 * 255).round()),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _formatPerformanceType(
                          widget.videoData['performanceType'].toString()),
                      style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const SizedBox(height: 6),

                // Performance Description
                if ((widget.videoData['description'] ??
                        widget.videoData['caption'] ??
                        '')
                    .isNotEmpty)
                  Text(
                    widget.videoData['description'] ??
                        widget.videoData['caption'] ??
                        '',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 6),

                // Location
                if ((widget.videoData['location'] ?? '').isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.videoData['location'] ?? '',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPerformanceType(String type) {
    switch (type.toLowerCase()) {
      case 'singer':
        return '🎤 Singer';
      case 'dancer':
        return '💃 Dancer';
      case 'magician':
        return '🎩 Magician';
      case 'musician':
        return '🎵 Musician';
      case 'artist':
        return '🎨 Artist';
      default:
        return '🎭 Performer';
    }
  }
}
