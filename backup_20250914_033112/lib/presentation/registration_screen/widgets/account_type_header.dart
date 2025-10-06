import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class AccountTypeHeader extends StatelessWidget {
  final String accountType;

  const AccountTypeHeader({
    Key? key,
    required this.accountType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity( 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName:
                accountType == 'Street Performer' ? 'music_note' : 'person',
            color: AppTheme.primaryOrange,
            size: 24,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Creating Account As:',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 2.0),
                Text(
                  accountType,
                  style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(
                  context, '/account-type-selection');
            },
            child: Text(
              'Change',
              style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.primaryOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
