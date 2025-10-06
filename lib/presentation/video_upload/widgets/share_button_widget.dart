import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

class ShareButtonWidget extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const ShareButtonWidget({
    super.key,
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
<<<<<<< HEAD
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: SizedBox(
        width: double.infinity,
        height: 48.0,
=======
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: SizedBox(
        width: double.infinity,
        height: 6.h,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
        child: ElevatedButton(
          onPressed: isEnabled && !isLoading ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled
                ? AppTheme.darkTheme.colorScheme.primary
                : AppTheme.darkTheme.colorScheme.outline,
            foregroundColor: isEnabled
                ? AppTheme.darkTheme.colorScheme.onPrimary
                : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
            elevation: isEnabled ? 2.0 : 0,
            shadowColor: AppTheme.shadowDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.darkTheme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
<<<<<<< HEAD
                    SizedBox(width: 12.0),
                    Text(
                      'Sharing...',
                      style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                        fontSize: 16.0,
=======
                    SizedBox(width: 3.w),
                    Text(
                      'Sharing...',
                      style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                        fontSize: 16.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'arrow_outward',
                      color: isEnabled
                          ? AppTheme.darkTheme.colorScheme.onPrimary
                          : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
<<<<<<< HEAD
                    SizedBox(width: 8.0),
                    Text(
                      'Drop Content',
                      style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                        fontSize: 16.0,
=======
                    SizedBox(width: 2.w),
                    Text(
                      'Drop Content',
                      style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                        fontSize: 16.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                        fontWeight: FontWeight.w500,
                        color: isEnabled
                            ? AppTheme.darkTheme.colorScheme.onPrimary
                            : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
