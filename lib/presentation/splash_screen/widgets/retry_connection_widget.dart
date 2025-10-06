import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
<<<<<<< HEAD
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

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
<<<<<<< HEAD
      padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
=======
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Warning icon
          Container(
<<<<<<< HEAD
            width: 60.0,
            height: 60.0,
=======
            width: 15.w,
            height: 15.w,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
              size: 32.0,
            ),
          ),
          SizedBox(height: 24.0),
=======
              size: 8.w,
            ),
          ),
          SizedBox(height: 3.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
          // Error message
          Text(
            message,
            style: GoogleFonts.inter(
<<<<<<< HEAD
              fontSize: 16.0,
=======
              fontSize: 16.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
<<<<<<< HEAD
          SizedBox(height: 8.0),
=======
          SizedBox(height: 1.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
          // Primary message
          Text(
            'YOU NOT FROM NEW YORK',
            style: GoogleFonts.inter(
<<<<<<< HEAD
              fontSize: 18.0,
=======
              fontSize: 18.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              fontWeight: FontWeight.w600,
              color: AppTheme.accentRed,
            ),
            textAlign: TextAlign.center,
          ),
<<<<<<< HEAD
          SizedBox(height: 16.0),
          Text(
            'Make sure you\'re connected to the internet and try again.',
            style: GoogleFonts.inter(
              fontSize: 14.0,
=======
          SizedBox(height: 2.h),
          Text(
            'Make sure you\'re connected to the internet and try again.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
<<<<<<< HEAD
          SizedBox(height: 32.0),
          // Retry button
          SizedBox(
            width: 240.0,
            height: 48.0,
=======
          SizedBox(height: 4.h),
          // Retry button
          SizedBox(
            width: 60.w,
            height: 6.h,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
                    size: 20.0,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'Try Again',
                    style: GoogleFonts.inter(
                      fontSize: 16.0,
=======
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Try Again',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
