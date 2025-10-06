import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

class LocationDisplayWidget extends StatelessWidget {
  final String currentLocation;
  final String? specificSpot;
  final VoidCallback onLocationTap;

  const LocationDisplayWidget({
    super.key,
    required this.currentLocation,
    this.specificSpot,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
<<<<<<< HEAD
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
=======
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
<<<<<<< HEAD
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.0),
=======
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.5.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
          GestureDetector(
            onTap: onLocationTap,
            child: Container(
              width: double.infinity,
<<<<<<< HEAD
              padding: EdgeInsets.all(16.0),
=======
              padding: EdgeInsets.all(4.w),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.darkTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
<<<<<<< HEAD
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.2),
=======
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.2),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'location_on',
                      color: AppTheme.successGreen,
                      size: 20,
                    ),
                  ),
<<<<<<< HEAD
                  SizedBox(width: 12.0),
=======
                  SizedBox(width: 3.w),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'verified',
                              color: AppTheme.successGreen,
                              size: 16,
                            ),
<<<<<<< HEAD
                            SizedBox(width: 4.0),
=======
                            SizedBox(width: 1.w),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                            Text(
                              currentLocation,
                              style: AppTheme.darkTheme.textTheme.bodyMedium
                                  ?.copyWith(
<<<<<<< HEAD
                                fontSize: 14.0,
=======
                                fontSize: 14.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (specificSpot != null) ...[
<<<<<<< HEAD
                          SizedBox(height: 4.0),
=======
                          SizedBox(height: 0.5.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                          Text(
                            specificSpot!,
                            style: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
<<<<<<< HEAD
                              fontSize: 12.0,
=======
                              fontSize: 12.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                              color: AppTheme
                                  .darkTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
<<<<<<< HEAD
          SizedBox(height: 8.0),
          Text(
            'NYC location verified • Tap to select specific spot',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              fontSize: 11.0,
=======
          SizedBox(height: 1.h),
          Text(
            'NYC location verified • Tap to select specific spot',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              fontSize: 11.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
