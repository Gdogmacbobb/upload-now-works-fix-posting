import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:ynfny/utils/responsive_scale.dart';
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

class FollowingEmptyStateWidget extends StatelessWidget {
  final VoidCallback? onDiscoverTap;

  const FollowingEmptyStateWidget({
    Key? key,
    this.onDiscoverTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 100.h,
      color: AppTheme.backgroundDark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty State Illustration
          Container(
            width: 60.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.borderSubtle,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Music Note Icon
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
<<<<<<< HEAD
                    color: AppTheme.primaryOrange.withOpacity(0.2),
=======
                    color: AppTheme.primaryOrange.withValues(alpha: 0.2),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'music_note',
                    color: AppTheme.primaryOrange,
                    size: 10.w,
                  ),
                ),

                SizedBox(height: 2.h),

                // Street Performer Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
<<<<<<< HEAD
                        color: AppTheme.textSecondary.withOpacity(0.3),
=======
                        color: AppTheme.textSecondary.withValues(alpha: 0.3),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'person',
                        color: AppTheme.textSecondary,
                        size: 4.w,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
<<<<<<< HEAD
                        color: AppTheme.textSecondary.withOpacity(0.3),
=======
                        color: AppTheme.textSecondary.withValues(alpha: 0.3),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'person',
                        color: AppTheme.textSecondary,
                        size: 4.w,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
<<<<<<< HEAD
                        color: AppTheme.textSecondary.withOpacity(0.3),
=======
                        color: AppTheme.textSecondary.withValues(alpha: 0.3),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'person',
                        color: AppTheme.textSecondary,
                        size: 4.w,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Empty State Title
          Text(
            'No Following Yet',
            style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          // Empty State Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              'Start following street performers to see their latest performances in your personalized feed.',
              style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 4.h),

          // Discover Performers CTA Button
          GestureDetector(
            onTap: onDiscoverTap,
            child: Container(
              width: 70.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
<<<<<<< HEAD
                    color: AppTheme.primaryOrange.withOpacity(0.3),
=======
                    color: AppTheme.primaryOrange.withValues(alpha: 0.3),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'explore',
                    color: AppTheme.backgroundDark,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Discover Performers',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.backgroundDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Secondary Action - Browse Categories
          GestureDetector(
            onTap: onDiscoverTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.borderSubtle,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'category',
                    color: AppTheme.textSecondary,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Browse by Category',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 6.h),

          // NYC Street Culture Hint
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            margin: EdgeInsets.symmetric(horizontal: 8.w),
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
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info_outline',
                  color: AppTheme.primaryOrange,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Follow performers to support NYC street culture and never miss their latest performances.',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.4,
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
