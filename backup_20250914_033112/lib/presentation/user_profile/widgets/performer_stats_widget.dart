import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class PerformerStatsWidget extends StatelessWidget {
  final Map<String, dynamic> performerData;
  final bool isCurrentUserProfile;
  final VoidCallback? onEditTap;

  const PerformerStatsWidget({
    super.key,
    required this.performerData,
    required this.isCurrentUserProfile,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalEarnings = performerData["totalEarnings"] as double? ?? 0.0;
    final followerCount = performerData["followerCount"] as int? ?? 0;
    final followingCount = performerData["followingCount"] as int? ?? 0;
    final videoCount = performerData["videoCount"] as int? ?? 0;
    final monthlyEarnings = performerData["monthlyEarnings"] as double? ?? 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
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
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "Total Earnings",
                  "\$${totalEarnings.toStringAsFixed(2)}",
                  CustomIconWidget(
                    iconName: 'attach_money',
                    color: AppTheme.successGreen,
                    size: 24,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: AppSpacing.xl,
                color: AppTheme.borderSubtle,
              ),
              Expanded(
                child: _buildStatItem(
                  "Followers",
                  _formatNumber(followerCount),
                  CustomIconWidget(
                    iconName: 'people',
                    color: AppTheme.primaryOrange,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "Videos",
                  _formatNumber(videoCount),
                  CustomIconWidget(
                    iconName: 'video_library',
                    color: AppTheme.accentRed,
                    size: 24,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: AppSpacing.xl,
                color: AppTheme.borderSubtle,
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        "Following",
                        _formatNumber(followingCount),
                        CustomIconWidget(
                          iconName: 'group',
                          color: AppTheme.primaryOrange,
                          size: 24,
                        ),
                      ),
                    ),
                    if (isCurrentUserProfile && onEditTap != null) ...[
                      SizedBox(width: AppSpacing.xs),
                      GestureDetector(
                        onTap: onEditTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryOrange,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            "Edit",
                            style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.primaryOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "This Month",
                  "\$${monthlyEarnings.toStringAsFixed(2)}",
                  CustomIconWidget(
                    iconName: 'trending_up',
                    color: AppTheme.successGreen,
                    size: 24,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: AppSpacing.xl,
                color: Colors.transparent, // Invisible divider for balance
              ),
              Expanded(child: SizedBox()), // Empty space for layout balance
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
        SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: AppTheme.performerStatsStyle(isLight: false).copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2),
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
