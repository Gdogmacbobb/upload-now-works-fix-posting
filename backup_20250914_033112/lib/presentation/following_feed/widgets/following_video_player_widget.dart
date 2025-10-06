import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
                    image: NetworkImage(widget.videoData['thumbnailUrl'] ??
                        widget.videoData['thumbnail'] ??
                        ''),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.backgroundDark.withOpacity( 0.3),
                        AppTheme.backgroundDark.withOpacity( 0.7),
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
                  color: AppTheme.backgroundDark.withOpacity( 0.7),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'play_arrow',
                  color: AppTheme.textPrimary,
                  size: 40,
                ),
              ),
            ),

          // Top Overlay - Following Indicator
          Positioned(
            top: AppSpacing.xl,
            left: AppSpacing.md,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity( 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryOrange.withOpacity( 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'people',
                    color: AppTheme.primaryOrange,
                    size: AppSpacing.md,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Following',
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
            right: AppSpacing.sm,
            bottom: 80,
            child: Column(
              children: [
                // Profile Avatar
                GestureDetector(
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
                      child: CustomImageWidget(
                        imageUrl: widget.videoData['performerAvatar'] ?? '',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.sm),

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
                        child: CustomIconWidget(
                          iconName: _isLiked ? 'favorite' : 'favorite_border',
                          color: _isLiked
                              ? AppTheme.textPrimary
                              : AppTheme.textPrimary,
                          size: AppSpacing.lg,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        _formatCount(widget.videoData['likesCount'] ??
                            widget.videoData['likeCount'] ??
                            0),
                        style: AppTheme.videoOverlayStyle(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.sm),

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
                        child: CustomIconWidget(
                          iconName: 'chat_bubble_outline',
                          color: AppTheme.textPrimary,
                          size: AppSpacing.lg,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        _formatCount(widget.videoData['commentsCount'] ??
                            widget.videoData['commentCount'] ??
                            0),
                        style: AppTheme.videoOverlayStyle(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.sm),

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
                        child: CustomIconWidget(
                          iconName: 'share',
                          color: AppTheme.textPrimary,
                          size: AppSpacing.lg,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        _formatCount(widget.videoData['sharesCount'] ??
                            widget.videoData['shareCount'] ??
                            0),
                        style: AppTheme.videoOverlayStyle(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.sm),

                // Donate Button
                GestureDetector(
                  onTap: widget.onDonate,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'attach_money',
                      color: AppTheme.backgroundDark,
                      size: AppSpacing.lg,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Overlay - Performer Info
          Positioned(
            bottom: AppSpacing.xl,
            left: AppSpacing.md,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Performer Name and Verification
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onProfileTap,
                      child: Text(
                        '@${widget.videoData['performerUsername'] ?? ''}',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    if (widget.videoData['isVerified'] == true)
                      CustomIconWidget(
                        iconName: 'verified',
                        color: AppTheme.primaryOrange,
                        size: AppSpacing.md,
                      ),
                  ],
                ),

                SizedBox(height: AppSpacing.xxs),

                // Performance Type Tag
                if (widget.videoData['performanceType'] != null &&
                    widget.videoData['performanceType'].isNotEmpty)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 0.20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity( 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryOrange.withOpacity( 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _formatPerformanceType(
                          widget.videoData['performanceType']),
                      style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                SizedBox(height: AppSpacing.xxs),

                // Performance Description
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

                SizedBox(height: AppSpacing.xxs),

                // Location and Timestamp
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: AppTheme.textSecondary,
                      size: AppSpacing.md,
                    ),
                    SizedBox(width: AppSpacing.xxs),
                    Text(
                      widget.videoData['location'] ?? '',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    CustomIconWidget(
                      iconName: 'access_time',
                      color: AppTheme.textSecondary,
                      size: AppSpacing.md,
                    ),
                    SizedBox(width: AppSpacing.xxs),
                    Text(
                      widget.videoData['timestamp'] ?? 'Just now',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
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
