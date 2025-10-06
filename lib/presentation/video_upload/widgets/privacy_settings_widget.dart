import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

class PrivacySettingsWidget extends StatelessWidget {
  final bool isPublic;
  final Function(bool) onPrivacyChanged;

  const PrivacySettingsWidget({
    super.key,
    required this.isPublic,
    required this.onPrivacyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
<<<<<<< HEAD
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
=======
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy Settings',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
<<<<<<< HEAD
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.0),
          Container(
            padding: EdgeInsets.all(16.0),
=======
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.5.h),
          Container(
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
              children: [
                _buildPrivacyOption(
                  title: 'Public',
                  subtitle: 'Anyone can see your performance',
                  icon: 'public',
                  isSelected: isPublic,
                  onTap: () => onPrivacyChanged(true),
                ),
<<<<<<< HEAD
                SizedBox(height: 16.0),
=======
                SizedBox(height: 2.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                _buildPrivacyOption(
                  title: 'Followers Only',
                  subtitle: 'Only your followers can see this video',
                  icon: 'group',
                  isSelected: !isPublic,
                  onTap: () => onPrivacyChanged(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption({
    required String title,
    required String subtitle,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
<<<<<<< HEAD
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.darkTheme.colorScheme.primary.withOpacity(0.1)
=======
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.darkTheme.colorScheme.primary.withValues(alpha: 0.1)
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.darkTheme.colorScheme.primary
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
<<<<<<< HEAD
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.darkTheme.colorScheme.primary
                        .withOpacity(0.2)
=======
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.darkTheme.colorScheme.primary
                        .withValues(alpha: 0.2)
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                    : AppTheme.darkTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: isSelected
                    ? AppTheme.darkTheme.colorScheme.primary
                    : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
<<<<<<< HEAD
            SizedBox(width: 12.0),
=======
            SizedBox(width: 3.w),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
<<<<<<< HEAD
                      fontSize: 14.0,
=======
                      fontSize: 14.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppTheme.darkTheme.colorScheme.primary
                          : AppTheme.darkTheme.colorScheme.onSurface,
                    ),
                  ),
<<<<<<< HEAD
                  SizedBox(height: 4.0),
                  Text(
                    subtitle,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.0,
=======
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                      color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.darkTheme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
