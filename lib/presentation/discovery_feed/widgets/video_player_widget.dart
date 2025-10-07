import 'package:flutter/material.dart';
import 'package:ynfny/utils/responsive_scale.dart';

import '../../../core/app_export.dart';

class VideoPlayerWidget extends StatefulWidget {
  final Map<String, dynamic> videoData;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onDonate;
  final VoidCallback? onProfileTap;

  const VideoPlayerWidget({
    Key? key,
    required this.videoData,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onDonate,
    this.onProfileTap,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool _isLiked = false;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.videoData['isLiked'] ?? false;
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
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
      // Return a default image URL if no thumbnail is available
      return 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=800&fit=crop';
    }

    return thumbnailUrl;
  }

  String _getPerformerAvatar() {
    final avatarUrl = widget.videoData['performerAvatar'] ?? '';

    if (avatarUrl.isEmpty) {
      // Return a default avatar URL
      return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face';
    }

    return avatarUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 100.h,
      color: AppTheme.backgroundDark,
      child: Stack(
        children: [
          // Video Background
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
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark.withAlpha((0.7 * 255).round()),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'play_arrow',
                  color: AppTheme.textPrimary,
                  size: 10.w,
                ),
              ),
            ),

          // Top Overlay - Discovery Indicator
          Positioned(
            top: 8.h,
            left: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryOrange.withAlpha((0.5 * 255).round()),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'explore',
                    color: AppTheme.primaryOrange,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Discover',
                    style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Side Actions
          Positioned(
            right: 3.w,
            bottom: 20.h,
            child: Column(
              children: [
                // Profile Avatar
                GestureDetector(
                  onTap: widget.onProfileTap,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
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
                        width: 12.w,
                        height: 12.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 12.w,
                            height: 12.w,
                            color: AppTheme.surfaceDark,
                            child: Icon(
                              Icons.person,
                              color: AppTheme.textSecondary,
                              size: 6.w,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 12.w,
                            height: 12.w,
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

                SizedBox(height: 3.h),

                // Like Button
                GestureDetector(
                  onTap: _toggleLike,
                  child: Column(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: _isLiked
                              ? AppTheme.accentRed
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: _isLiked ? 'favorite' : 'favorite_border',
                          color: _isLiked
                              ? AppTheme.textPrimary
                              : AppTheme.textPrimary,
                          size: 6.w,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        _formatCount(widget.videoData['likesCount'] ??
                            widget.videoData['likeCount'] ??
                            0),
                        style: AppTheme.videoOverlayStyle(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                // Comment Button
                GestureDetector(
                  onTap: widget.onComment,
                  child: Column(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: 'chat_bubble_outline',
                          color: AppTheme.textPrimary,
                          size: 6.w,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        _formatCount(widget.videoData['commentsCount'] ??
                            widget.videoData['commentCount'] ??
                            0),
                        style: AppTheme.videoOverlayStyle(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                // Share Button
                GestureDetector(
                  onTap: widget.onShare,
                  child: Column(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: 'share',
                          color: AppTheme.textPrimary,
                          size: 6.w,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        _formatCount(widget.videoData['sharesCount'] ??
                            widget.videoData['shareCount'] ??
                            0),
                        style: AppTheme.videoOverlayStyle(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                // Donate Button
                GestureDetector(
                  onTap: widget.onDonate,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'attach_money',
                      color: AppTheme.backgroundDark,
                      size: 6.w,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Overlay - Performer Info
          Positioned(
            bottom: 8.h,
            left: 4.w,
            right: 20.w,
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
                    SizedBox(width: 2.w),
                    if (widget.videoData['isVerified'] == true)
                      CustomIconWidget(
                        iconName: 'verified',
                        color: AppTheme.primaryOrange,
                        size: 4.w,
                      ),
                  ],
                ),

                SizedBox(height: 1.h),

                // Performance Type Tag
                if (widget.videoData['performanceType'] != null &&
                    widget.videoData['performanceType'].toString().isNotEmpty)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
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

                SizedBox(height: 1.h),

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

                SizedBox(height: 1.h),

                // Location
                if ((widget.videoData['location'] ?? '').isNotEmpty)
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: AppTheme.textSecondary,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
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
