import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'package:ynfny/utils/responsive_scale.dart';
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

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
      height: 6.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                HapticFeedback.mediumImpact();
                onPressed?.call();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
<<<<<<< HEAD
              ? AppTheme.surfaceDark
              : AppTheme.borderSubtle,
          foregroundColor:
              isEnabled ? Colors.white : AppTheme.textSecondary,
          elevation: isEnabled ? 4.0 : 0.0,
          shadowColor: isEnabled
              ? AppTheme.surfaceDark.withOpacity(0.3)
=======
              ? (accentColor ?? AppTheme.primaryOrange)
              : AppTheme.borderSubtle,
          foregroundColor:
              isEnabled ? AppTheme.backgroundDark : AppTheme.textSecondary,
          elevation: isEnabled ? 4.0 : 0.0,
          shadowColor: isEnabled
              ? (accentColor ?? AppTheme.primaryOrange).withValues(alpha: 0.3)
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 2.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: isEnabled
<<<<<<< HEAD
                    ? Colors.white
=======
                    ? AppTheme.backgroundDark
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                    : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isEnabled) ...[
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'arrow_forward',
<<<<<<< HEAD
                color: Colors.white,
=======
                color: AppTheme.backgroundDark,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                size: 5.w,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
