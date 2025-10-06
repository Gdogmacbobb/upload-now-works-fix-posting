import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:ynfny/utils/responsive_scale.dart';
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

class ExplanationTextWidget extends StatelessWidget {
  const ExplanationTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
<<<<<<< HEAD
        color: AppTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderSubtle.withOpacity(0.3),
=======
        color: AppTheme.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderSubtle.withValues(alpha: 0.3),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
<<<<<<< HEAD
                iconName: 'info',
=======
                iconName: 'help_outline',
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                color: AppTheme.primaryOrange,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Account Information',
                style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            'Choose the account type that best describes you.',
<<<<<<< HEAD
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.normal,
=======
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              height: 1.4,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
<<<<<<< HEAD
              color: AppTheme.backgroundDark.withOpacity(0.3),
=======
              color: AppTheme.backgroundDark.withValues(alpha: 0.3),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'swap_horiz',
                  color: AppTheme.successGreen,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'You can switch account types after registration in your profile settings.',
<<<<<<< HEAD
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
=======
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 10.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
