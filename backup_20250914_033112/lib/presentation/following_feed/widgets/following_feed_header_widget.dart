import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class FollowingFeedHeaderWidget extends StatelessWidget {
  final int unreadCount;
  final String lastUpdated;
  final VoidCallback? onRefresh;

  const FollowingFeedHeaderWidget({
    Key? key,
    this.unreadCount = 0,
    this.lastUpdated = '',
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.xs,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark.withOpacity( 0.9),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderSubtle.withOpacity( 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Following Title with Unread Count
          Row(
            children: [
              Text(
                'Following',
                style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (unreadCount > 0) ...[
                SizedBox(width: AppSpacing.xs),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 0.20),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Last Updated Info and Refresh
          Row(
            children: [
              if (lastUpdated.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Last updated',
                      style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      lastUpdated,
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: AppSpacing.sm),
              ],

              // Refresh Button
              GestureDetector(
                onTap: onRefresh,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'refresh',
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
