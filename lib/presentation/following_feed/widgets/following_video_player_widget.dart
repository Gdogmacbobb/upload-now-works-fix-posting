import 'package:flutter/material.dart';
import 'package:ynfny/utils/responsive_scale.dart';

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
                        AppTheme.backgroundDark.withOpacity(0.3),
                        AppTheme.backgroundDark.withOpacity(0.7),
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
                  color: AppTheme.backgroundDark.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'play_arrow',
                  color: AppTheme.textPrimary,
                  size: 10.w,
                ),
              ),
            ),

          // Top Overlay - Following Indicator
          Positioned(
            top: 8.h,
            left: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryOrange.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'people',
                    color: AppTheme.primaryOrange,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
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

          // Profile Avatar (positioned at top-right, TikTok-style)
          Positioned(
            right: 3.w,
            top: 10.h,
            child: GestureDetector(
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
                  child: CustomImageWidget(
                    imageUrl: widget.videoData['performerAvatar'] ?? '',
                    width: 12.w,
                    height: 12.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Right Side Action Buttons (vertically centered)
          Positioned(
            right: 3.w,
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
                ],
              ),
            ),
          ),

          // Donate Button (separate, positioned above bottom nav)
          Positioned(
            right: 3.w,
            bottom: 11.h,
            child: GestureDetector(
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
          ),

          // Bottom Overlay - Performer Info (raised for TikTok-style spacing)
          Positioned(
            bottom: 12.h,
            left: 4.w,
            right: 20.w,
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
                    widget.videoData['performanceType'].isNotEmpty)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryOrange.withOpacity(0.5),
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

                SizedBox(height: 1.h),

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

                SizedBox(height: 1.h),

                // Location and Timestamp
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: AppTheme.textSecondary,
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      widget.videoData['location'] ?? '',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    CustomIconWidget(
                      iconName: 'access_time',
                      color: AppTheme.textSecondary,
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
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
