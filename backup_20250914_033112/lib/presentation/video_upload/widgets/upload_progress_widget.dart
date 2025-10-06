import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class UploadProgressWidget extends StatelessWidget {
  final bool isUploading;
  final double progress;
  final String statusText;
  final String? estimatedTime;
  final VoidCallback? onCancel;

  const UploadProgressWidget({
    super.key,
    required this.isUploading,
    required this.progress,
    required this.statusText,
    this.estimatedTime,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (!isUploading) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uploading Video',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (onCancel != null)
                GestureDetector(
                  onTap: onCancel,
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),

          // Progress bar
          Container(
            width: double.infinity,
            height: AppSpacing.xxs,
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          SizedBox(height: 1.20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statusText,
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.darkTheme.colorScheme.primary,
                ),
              ),
            ],
          ),

          if (estimatedTime != null) ...[
            SizedBox(height: AppSpacing.xxs),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                  size: 14,
                ),
                SizedBox(width: AppSpacing.xxs),
                Text(
                  'Estimated time: $estimatedTime',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
