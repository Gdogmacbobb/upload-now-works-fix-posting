import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class ExplanationTextWidget extends StatelessWidget {
  const ExplanationTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity( 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderSubtle.withOpacity( 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'help_outline',
                color: AppTheme.primaryOrange,
                size: 20,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Account Information',
                style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.20),
          Text(
            'Choose the account type that best describes you.',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSpacing.xxs),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark.withOpacity( 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'swap_horiz',
                  color: AppTheme.successGreen,
                  size: AppSpacing.md,
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'You can switch account types after registration in your profile settings.',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
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
