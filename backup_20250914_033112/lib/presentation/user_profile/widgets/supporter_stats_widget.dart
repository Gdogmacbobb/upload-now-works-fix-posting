import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class SupporterStatsWidget extends StatelessWidget {
  final Map<String, dynamic> supporterData;
  final bool isCurrentUserProfile;
  final VoidCallback? onEditTap;

  const SupporterStatsWidget({
    super.key,
    required this.supporterData,
    required this.isCurrentUserProfile,
    this.onEditTap,
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
      padding: EdgeInsets.all(AppSpacing.md),
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
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "Total Donated",
                  "\$${totalDonated.toStringAsFixed(2)}",
                  CustomIconWidget(
                    iconName: 'favorite',
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
                        "Artists Supported",
                        performersSupported.toString(),
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
          if (favoriteTypes.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            Text(
              "Favorite Performance Types",
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.xxs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xxs,
              children: favoriteTypes
                  .take(3)
                  .map((type) => Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withOpacity( 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                AppTheme.primaryOrange.withOpacity( 0.3),
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
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
