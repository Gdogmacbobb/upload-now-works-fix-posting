import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ynfny/core/app_export.dart';

class ContinueButtonWidget extends StatelessWidget {
  final bool isEnabled;
  final Color? accentColor;
  final VoidCallback? onPressed;

  const ContinueButtonWidget({
    super.key,
    required this.isEnabled,
    this.accentColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSpacing.lg,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                HapticFeedback.mediumImpact();
                onPressed?.call();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? (accentColor ?? AppTheme.primaryOrange)
              : AppTheme.borderSubtle,
          foregroundColor:
              isEnabled ? AppTheme.backgroundDark : AppTheme.textSecondary,
          elevation: isEnabled ? 4.0 : 0.0,
          shadowColor: isEnabled
              ? (accentColor ?? AppTheme.primaryOrange).withOpacity( 0.3)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: isEnabled
                    ? AppTheme.backgroundDark
                    : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isEnabled) ...[
              SizedBox(width: AppSpacing.xs),
              CustomIconWidget(
                iconName: 'arrow_forward',
                color: AppTheme.backgroundDark,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
