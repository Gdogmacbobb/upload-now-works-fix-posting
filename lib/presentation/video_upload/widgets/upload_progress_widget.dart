import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

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
<<<<<<< HEAD
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      padding: EdgeInsets.all(16.0),
=======
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
                  fontSize: 14.0,
=======
                  fontSize: 14.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
          SizedBox(height: 16.0),
=======
          SizedBox(height: 2.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

          // Progress bar
          Container(
            width: double.infinity,
<<<<<<< HEAD
            height: 8.0,
=======
            height: 1.h,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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

<<<<<<< HEAD
          SizedBox(height: 12.0),
=======
          SizedBox(height: 1.5.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statusText,
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
<<<<<<< HEAD
                  fontSize: 12.0,
=======
                  fontSize: 12.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
<<<<<<< HEAD
                  fontSize: 12.0,
=======
                  fontSize: 12.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  fontWeight: FontWeight.w500,
                  color: AppTheme.darkTheme.colorScheme.primary,
                ),
              ),
            ],
          ),

          if (estimatedTime != null) ...[
<<<<<<< HEAD
            SizedBox(height: 8.0),
=======
            SizedBox(height: 1.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                  size: 14,
                ),
<<<<<<< HEAD
                SizedBox(width: 4.0),
                Text(
                  'Estimated time: $estimatedTime',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    fontSize: 11.0,
=======
                SizedBox(width: 1.w),
                Text(
                  'Estimated time: $estimatedTime',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    fontSize: 11.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
