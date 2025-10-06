import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class FollowingContextMenuWidget extends StatelessWidget {
  final VoidCallback? onUnfollow;
  final VoidCallback? onSave;
  final VoidCallback? onReport;
  final VoidCallback? onShare;
  final VoidCallback? onClose;

  const FollowingContextMenuWidget({
    Key? key,
    this.onUnfollow,
    this.onSave,
    this.onReport,
    this.onShare,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.backgroundDark.withOpacity( 0.8),
        child: Center(
          child: Container(
            width: 320,
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowDark,
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.borderSubtle,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Options',
                        style:
                            AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: onClose,
                        child: CustomIconWidget(
                          iconName: 'close',
                          color: AppTheme.textSecondary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Items
                Column(
                  children: [
                    // Unfollow Option
                    _buildMenuItem(
                      icon: 'person_remove',
                      title: 'Unfollow',
                      subtitle: 'Stop seeing posts from this performer',
                      iconColor: AppTheme.accentRed,
                      onTap: () {
                        onClose?.call();
                        onUnfollow?.call();
                      },
                    ),

                    _buildDivider(),

                    // Save Option
                    _buildMenuItem(
                      icon: 'bookmark_border',
                      title: 'Save Video',
                      subtitle: 'Add to your saved collection',
                      iconColor: AppTheme.textSecondary,
                      onTap: () {
                        onClose?.call();
                        onSave?.call();
                      },
                    ),

                    _buildDivider(),

                    // Share Option
                    _buildMenuItem(
                      icon: 'arrow_outward',
                      title: 'Share',
                      subtitle: 'Share this performance',
                      iconColor: AppTheme.textSecondary,
                      onTap: () {
                        onClose?.call();
                        onShare?.call();
                      },
                    ),

                    _buildDivider(),

                    // Report Option
                    _buildMenuItem(
                      icon: 'flag',
                      title: 'Report',
                      subtitle: 'Report inappropriate content',
                      iconColor: AppTheme.accentRed,
                      onTap: () {
                        onClose?.call();
                        onReport?.call();
                      },
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.xs),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity( 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: iconColor,
                size: 24,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      height: 1,
      color: AppTheme.borderSubtle.withOpacity( 0.3),
    );
  }
}
