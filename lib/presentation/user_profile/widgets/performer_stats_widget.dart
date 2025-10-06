import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

class PerformerStatsWidget extends StatelessWidget {
  final Map<String, dynamic> performerData;

  const PerformerStatsWidget({
    super.key,
    required this.performerData,
  });

  @override
  Widget build(BuildContext context) {
    final totalEarnings = performerData["totalEarnings"] as double? ?? 0.0;
    final followerCount = performerData["followerCount"] as int? ?? 0;
    final videoCount = performerData["videoCount"] as int? ?? 0;
    final monthlyEarnings = performerData["monthlyEarnings"] as double? ?? 0.0;

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
            "Performance Stats",
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
<<<<<<< HEAD
          SizedBox(height: 24.0),
=======
          SizedBox(height: 3.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "Total Earnings",
                  "\$${totalEarnings.toStringAsFixed(2)}",
                  CustomIconWidget(
                    iconName: 'attach_money',
                    color: AppTheme.successGreen,
<<<<<<< HEAD
                    size: 24.0,
=======
                    size: 6.w,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  ),
                ),
              ),
              Container(
                width: 1,
<<<<<<< HEAD
                height: 64.0,
=======
                height: 8.h,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                color: AppTheme.borderSubtle,
              ),
              Expanded(
                child: _buildStatItem(
                  "Followers",
                  _formatNumber(followerCount),
                  CustomIconWidget(
                    iconName: 'people',
                    color: AppTheme.primaryOrange,
<<<<<<< HEAD
                    size: 24.0,
=======
                    size: 6.w,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  ),
                ),
              ),
            ],
          ),
<<<<<<< HEAD
          SizedBox(height: 16.0),
=======
          SizedBox(height: 2.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "Videos",
                  _formatNumber(videoCount),
                  CustomIconWidget(
                    iconName: 'video_library',
                    color: AppTheme.accentRed,
<<<<<<< HEAD
                    size: 24.0,
=======
                    size: 6.w,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  ),
                ),
              ),
              Container(
                width: 1,
<<<<<<< HEAD
                height: 64.0,
=======
                height: 8.h,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                color: AppTheme.borderSubtle,
              ),
              Expanded(
                child: _buildStatItem(
                  "This Month",
                  "\$${monthlyEarnings.toStringAsFixed(2)}",
                  CustomIconWidget(
                    iconName: 'trending_up',
                    color: AppTheme.successGreen,
<<<<<<< HEAD
                    size: 24.0,
=======
                    size: 6.w,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  ),
                ),
              ),
            ],
          ),
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return "${(number / 1000000).toStringAsFixed(1)}M";
    } else if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(1)}K";
    }
    return number.toString();
  }
}
