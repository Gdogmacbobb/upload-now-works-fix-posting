import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class FollowingEmptyStateWidget extends StatelessWidget {
  final VoidCallback? onDiscoverTap;

  const FollowingEmptyStateWidget({
    Key? key,
    this.onDiscoverTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.backgroundDark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty State Illustration
          Container(
            width: 240,
            height: 120,
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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity( 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'music_note',
                    color: AppTheme.primaryOrange,
                    size: 40,
                  ),
                ),

                SizedBox(height: AppSpacing.xs),

                // Street Performer Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withOpacity( 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'person',
                        color: AppTheme.textSecondary,
                        size: AppSpacing.md,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withOpacity( 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'person',
                        color: AppTheme.textSecondary,
                        size: AppSpacing.md,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withOpacity( 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'person',
                        color: AppTheme.textSecondary,
                        size: AppSpacing.md,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Empty State Title
          Text(
            'No Following Yet',
            style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.xs),

          // Empty State Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Start following street performers to see their latest performances in your personalized feed.',
              style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Discover Performers CTA Button
          GestureDetector(
            onTap: onDiscoverTap,
            child: Container(
              width: 280,
              height: AppSpacing.lg,
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withOpacity( 0.3),
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
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.sm),
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

          SizedBox(height: AppSpacing.sm),

          // Secondary Action - Browse Categories
          GestureDetector(
            onTap: onDiscoverTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
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
                    size: AppSpacing.md,
                  ),
                  SizedBox(width: AppSpacing.xs),
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

          SizedBox(height: AppSpacing.lg),

          // NYC Street Culture Hint
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            margin: EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark.withOpacity( 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.borderSubtle.withOpacity( 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info_outline',
                  color: AppTheme.primaryOrange,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.sm),
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
