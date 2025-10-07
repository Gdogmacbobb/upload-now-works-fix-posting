import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

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
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      padding: EdgeInsets.all(16.0),
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
                  fontSize: 14.0,
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
          SizedBox(height: 16.0),

          // Progress bar
          Container(
            width: double.infinity,
            height: 8.0,
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

          SizedBox(height: 12.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statusText,
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 12.0,
                  color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.darkTheme.colorScheme.primary,
                ),
              ),
            ],
          ),

          if (estimatedTime != null) ...[
            SizedBox(height: 8.0),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                  size: 14,
                ),
                SizedBox(width: 4.0),
                Text(
                  'Estimated time: $estimatedTime',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    fontSize: 11.0,
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
