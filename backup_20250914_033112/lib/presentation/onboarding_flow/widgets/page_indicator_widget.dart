import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';
import '../../../theme/app_theme.dart';

class PageIndicatorWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicatorWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          width: currentPage == index ? AppSpacing.xl : AppSpacing.xs,
          height: AppSpacing.xxs,
          decoration: BoxDecoration(
            color: currentPage == index
                ? AppTheme.primaryOrange
                : AppTheme.textSecondary.withOpacity( 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
