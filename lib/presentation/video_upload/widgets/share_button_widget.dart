import 'package:flutter/material.dart';

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
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: SizedBox(
        width: double.infinity,
        height: 48.0,
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
                    SizedBox(width: 12.0),
                    Text(
                      'Sharing...',
                      style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                        fontSize: 16.0,
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
                    SizedBox(width: 8.0),
                    Text(
                      'Drop Content',
                      style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                        fontSize: 16.0,
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
