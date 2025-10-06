import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class FeedNavigationHeaderWidget extends StatelessWidget {
  final String currentFeed; // 'following', 'discovery', or 'for_you'
  final bool showSearch;
  final int unreadCount;
  final VoidCallback? onRefresh;

  const FeedNavigationHeaderWidget({
    Key? key,
    required this.currentFeed,
    this.showSearch = false, // Default to false to prevent search button
    this.unreadCount = 0,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 1.20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(153),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Following Button
            _buildNavigationButton(
              context,
              'Following',
              currentFeed == 'following',
              () => _navigateToFeed(context, 'following'),
            ),

            SizedBox(width: AppSpacing.xl),

            // Discovery Button
            _buildNavigationButton(
              context,
              'Discovery',
              currentFeed == 'discovery',
              () => _navigateToFeed(context, 'discovery'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String title,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color:
                    isActive ? AppTheme.primaryOrange : AppTheme.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
      ),
    );
  }

  void _navigateToFeed(BuildContext context, String feedType) {
    switch (feedType) {
      case 'following':
        if (currentFeed != 'following') {
          Navigator.pushReplacementNamed(context, AppRoutes.followingFeed);
        }
        break;
      case 'discovery':
      case 'for_you':
        if (currentFeed != 'discovery' && currentFeed != 'for_you') {
          Navigator.pushReplacementNamed(context, AppRoutes.discoveryFeed);
        }
        break;
    }
  }
}
