import 'package:flutter/material.dart';
import 'package:ynfny/utils/responsive_scale.dart';

import '../../../core/app_export.dart';

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // YNFNY Logo - Made bigger
        Container(
          width: 35.w,
          height: 35.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowDark,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.w),
            child: Image.asset(
              'assets/images/YNFNY_Logo-1753709879889.png',
              width: 35.w,
              height: 35.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 35.w,
                  height: 35.w,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Statue of Liberty silhouette
                      CustomIconWidget(
                        iconName: 'account_balance',
                        color: AppTheme.textSecondary,
                        size: 16.w,
                      ),
                      // Red glowing eyes effect
                      Positioned(
                        top: 8.w,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 1.5.w,
                              height: 1.5.w,
                              decoration: BoxDecoration(
                                color: AppTheme.accentRed,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentRed
                                        .withOpacity(0.6),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 2.5.w),
                            Container(
                              width: 1.5.w,
                              height: 1.5.w,
                              decoration: BoxDecoration(
                                color: AppTheme.accentRed,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentRed
                                        .withOpacity(0.6),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // YNFNY Brand Text
        Text(
          'YNFNY',
          style: AppTheme.darkTheme.textTheme.headlineLarge?.copyWith(
            color: AppTheme.primaryOrange,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),

        SizedBox(height: 0.5.h),

        // WE OUTSIDE Tagline
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
              color: AppTheme.primaryOrange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            'WE OUTSIDE',
            style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // Welcome Back Text
        Text(
          'Welcome Back',
          style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 0.5.h),

        // Subtitle
        Text(
          'Sign in to discover NYC street performers',
          style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
