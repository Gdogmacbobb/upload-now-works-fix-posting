import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

class SupporterStatsWidget extends StatelessWidget {
  final Map<String, dynamic> supporterData;

  const SupporterStatsWidget({
    super.key,
    required this.supporterData,
  });

  @override
  Widget build(BuildContext context) {
    final totalDonated = supporterData["totalDonated"] as double? ?? 0.0;
    final performersSupported =
        supporterData["performersSupported"] as int? ?? 0;
    final favoriteTypes =
        (supporterData["favoritePerformanceTypes"] as List?)?.cast<String>() ??
            [];

    return Container(
      width: double.infinity,
<<<<<<< HEAD
      padding: EdgeInsets.all(16.0),
=======
      padding: EdgeInsets.all(4.w),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
      decoration: AppTheme.performerCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Support Stats",
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
<<<<<<< HEAD
          SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildStatItem(
                  "Following",
                  (supporterData["followingCount"] as int? ?? 0).toString(),
                  CustomIconWidget(
                    iconName: 'person_add',
                    color: AppTheme.primaryOrange,
                    size: 24.0,
                  ),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  "Reposts",
                  (supporterData["repostCount"] as int? ?? 0).toString(),
                  CustomIconWidget(
                    iconName: 'repeat',
                    color: AppTheme.accentRed,
                    size: 24.0,
                  ),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  "Liked",
                  (supporterData["likedCount"] as int? ?? 0).toString(),
                  CustomIconWidget(
                    iconName: 'favorite',
                    color: AppTheme.successGreen,
                    size: 24.0,
=======
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "Total Donated",
                  "\$${totalDonated.toStringAsFixed(2)}",
                  CustomIconWidget(
                    iconName: 'favorite',
                    color: AppTheme.accentRed,
                    size: 6.w,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 8.h,
                color: AppTheme.borderSubtle,
              ),
              Expanded(
                child: _buildStatItem(
                  "Artists Supported",
                  performersSupported.toString(),
                  CustomIconWidget(
                    iconName: 'group',
                    color: AppTheme.primaryOrange,
                    size: 6.w,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  ),
                ),
              ),
            ],
          ),
          if (favoriteTypes.isNotEmpty) ...[
<<<<<<< HEAD
            SizedBox(height: 24.0),
=======
            SizedBox(height: 3.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
            Text(
              "Favorite Performance Types",
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
<<<<<<< HEAD
            SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
=======
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              children: favoriteTypes
                  .take(3)
                  .map((type) => Container(
                        padding: EdgeInsets.symmetric(
<<<<<<< HEAD
                            horizontal: 12.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                AppTheme.primaryOrange.withOpacity(0.3),
=======
                            horizontal: 3.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                AppTheme.primaryOrange.withValues(alpha: 0.3),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                            width: 1,
                          ),
                        ),
                        child: Text(
                          type,
                          style:
                              AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Widget icon) {
    return Column(
      children: [
        icon,
<<<<<<< HEAD
        SizedBox(height: 8.0),
        Text(
          value,
          style: AppTheme.performerStatsStyle(isLight: false).copyWith(
            fontSize: 18.0,
=======
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.performerStatsStyle(isLight: false).copyWith(
            fontSize: 18.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
<<<<<<< HEAD
        SizedBox(height: 4.0),
=======
        SizedBox(height: 0.5.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
