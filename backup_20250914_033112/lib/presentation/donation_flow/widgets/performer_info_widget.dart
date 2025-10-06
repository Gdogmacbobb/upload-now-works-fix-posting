import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class PerformerInfoWidget extends StatelessWidget {
  final Map<String, dynamic> performerData;

  const PerformerInfoWidget({
    Key? key,
    required this.performerData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Row(
        children: [
          // Performer Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryOrange,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl: performerData['avatar'] as String,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),

          // Performer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  performerData['name'] as String,
                  style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.20),
                Text(
                  performerData['performanceType'] as String,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.20),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: AppTheme.primaryOrange,
                      size: 12,
                    ),
                    SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Text(
                        performerData['location'] as String,
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Recent Performance Thumbnail
          Container(
            width: 80,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.borderSubtle,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  CustomImageWidget(
                    imageUrl: performerData['recentPerformance'] as String,
                    width: 80,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: 80,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.videoOverlay.withOpacity( 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Center(
                    child: CustomIconWidget(
                      iconName: 'play_arrow',
                      color: AppTheme.textPrimary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
