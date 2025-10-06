import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:ynfny/utils/responsive_scale.dart';
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

class YnfnyLogoWidget extends StatelessWidget {
  const YnfnyLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
<<<<<<< HEAD
                  color: AppTheme.primaryOrange.withOpacity(0.2),
=======
                  color: AppTheme.primaryOrange.withValues(alpha: 0.2),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/YNFNY_Logo-1753709879889.png',
                width: 32.w,
                height: 32.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
<<<<<<< HEAD
                        color: AppTheme.primaryOrange.withOpacity(0.3),
=======
                        color: AppTheme.primaryOrange.withValues(alpha: 0.3),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'account_balance',
                          color: AppTheme.primaryOrange,
                          size: 10.w,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'YNFNY',
                          style: AppTheme.darkTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 3.5.h),
          Text(
            'YNFNY',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryOrange,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
