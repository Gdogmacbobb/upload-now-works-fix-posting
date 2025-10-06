import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ynfny/core/app_export.dart';

class RetryConnectionWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;

  const RetryConnectionWidget({
    Key? key,
    required this.onRetry,
    this.message = 'Connection timeout. Please check your network.',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Warning icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryOrange,
                width: 2,
              ),
            ),
            child: CustomIconWidget(
              iconName: 'wifi_off',
              color: AppTheme.primaryOrange,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          // Error message
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Primary message
          Text(
            'YOU NOT OUTSIDE',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.accentRed,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure you\'re connected to the internet and try again.',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Retry button
          SizedBox(
            width: 240,
            height: 48,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: AppTheme.backgroundDark,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'refresh',
                    color: AppTheme.backgroundDark,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Try Again',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
