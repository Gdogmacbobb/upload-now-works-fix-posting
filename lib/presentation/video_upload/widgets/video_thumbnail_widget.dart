import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class VideoThumbnailWidget extends StatelessWidget {
  final String? videoPath;
  final String duration;
  final VoidCallback onRetake;

  const VideoThumbnailWidget({
    super.key,
    this.videoPath,
    required this.duration,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200.0,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Video thumbnail placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: AppTheme.darkTheme.colorScheme.surface,
              child: videoPath != null
                  ? CustomImageWidget(
                      imageUrl:
                          "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: CustomIconWidget(
                        iconName: 'videocam',
                        color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                        size: 48,
                      ),
                    ),
            ),
          ),

          // Duration indicator
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: AppTheme.videoOverlay,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                duration,
                style: AppTheme.videoOverlayStyle().copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Retake button
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: onRetake,
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppTheme.videoOverlay,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomIconWidget(
                  iconName: 'refresh',
                  color: AppTheme.darkTheme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          ),

          // Play button overlay
          Center(
            child: Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: AppTheme.videoOverlay,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'play_arrow',
                color: AppTheme.darkTheme.colorScheme.primary,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
