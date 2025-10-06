import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class VideoGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> videos;
  final Function(Map<String, dynamic>) onVideoTap;
  final Function(Map<String, dynamic>) onVideoLongPress;

  const VideoGridWidget({
    super.key,
    required this.videos,
    required this.onVideoTap,
    required this.onVideoLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'video_library',
              color: AppTheme.textSecondary,
              size: 48,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              "No videos yet",
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.xxs),
            Text(
              "Videos will appear here once uploaded",
              style: AppTheme.darkTheme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(AppSpacing.xs),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.xxs,
        mainAxisSpacing: AppSpacing.xxs,
        childAspectRatio: 0.75,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return _buildVideoThumbnail(context, video);
      },
    );
  }

  Widget _buildVideoThumbnail(
      BuildContext context, Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () => onVideoTap(video),
      onLongPress: () => onVideoLongPress(video),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppTheme.surfaceDark,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImageWidget(
                imageUrl: video["thumbnailUrl"] as String? ?? "",
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Play Icon Overlay
            Center(
              child: Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppTheme.videoOverlay,
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'play_arrow',
                  color: AppTheme.textPrimary,
                  size: 20,
                ),
              ),
            ),
            // View Count Overlay
            Positioned(
              bottom: AppSpacing.xxs,
              left: AppSpacing.xxs,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.videoOverlay,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'visibility',
                      color: AppTheme.textPrimary,
                      size: 12,
                    ),
                    SizedBox(width: AppSpacing.xxs),
                    Text(
                      _formatViewCount(video["viewCount"] as int? ?? 0),
                      style: AppTheme.videoOverlayStyle().copyWith(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Duration Overlay
            Positioned(
              bottom: AppSpacing.xxs,
              right: AppSpacing.xxs,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.videoOverlay,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(video["duration"] as int? ?? 0),
                  style: AppTheme.videoOverlayStyle().copyWith(
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            // Like Count (if available)
            if (video["likeCount"] != null)
              Positioned(
                top: AppSpacing.xxs,
                right: AppSpacing.xxs,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.videoOverlay,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'favorite',
                        color: AppTheme.accentRed,
                        size: 12,
                      ),
                      SizedBox(width: AppSpacing.xxs),
                      Text(
                        _formatViewCount(video["likeCount"] as int),
                        style: AppTheme.videoOverlayStyle().copyWith(
                          fontSize: 10,
                        ),
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

  String _formatViewCount(int count) {
    if (count >= 1000000) {
      return "${(count / 1000000).toStringAsFixed(1)}M";
    } else if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}K";
    }
    return count.toString();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }
}
