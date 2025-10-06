import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class PrivacySettingsWidget extends StatelessWidget {
  final bool isPublic;
  final Function(bool) onPrivacyChanged;

  const PrivacySettingsWidget({
    super.key,
    required this.isPublic,
    required this.onPrivacyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy Settings',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.20),
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.darkTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildPrivacyOption(
                  title: 'Public',
                  subtitle: 'Anyone can see your performance',
                  icon: 'public',
                  isSelected: isPublic,
                  onTap: () => onPrivacyChanged(true),
                ),
                SizedBox(height: AppSpacing.xs),
                _buildPrivacyOption(
                  title: 'Followers Only',
                  subtitle: 'Only your followers can see this video',
                  icon: 'group',
                  isSelected: !isPublic,
                  onTap: () => onPrivacyChanged(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption({
    required String title,
    required String subtitle,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.darkTheme.colorScheme.primary.withOpacity( 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.darkTheme.colorScheme.primary
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.darkTheme.colorScheme.primary
                        .withOpacity( 0.2)
                    : AppTheme.darkTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: isSelected
                    ? AppTheme.darkTheme.colorScheme.primary
                    : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppTheme.darkTheme.colorScheme.primary
                          : AppTheme.darkTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.20),
                  Text(
                    subtitle,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.darkTheme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
