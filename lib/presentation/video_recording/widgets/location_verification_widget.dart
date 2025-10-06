import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

class LocationVerificationWidget extends StatelessWidget {
  final bool isVerified;
  final String currentLocation;
  final String? selectedBorough;
  final List<String> boroughs;
  final Function(String) onBoroughSelected;
  final VoidCallback? onRetryLocation;

  const LocationVerificationWidget({
    super.key,
    required this.isVerified,
    required this.currentLocation,
    this.selectedBorough,
    required this.boroughs,
    required this.onBoroughSelected,
    this.onRetryLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
<<<<<<< HEAD
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: AppTheme.glassmorphismDecoration(
        backgroundColor: isVerified
            ? AppTheme.successGreen.withOpacity(0.2)
            : AppTheme.accentRed.withOpacity(0.2),
=======
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: AppTheme.glassmorphismDecoration(
        backgroundColor: isVerified
            ? AppTheme.successGreen.withValues(alpha: 0.2)
            : AppTheme.accentRed.withValues(alpha: 0.2),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: isVerified ? 'check_circle' : 'location_off',
                color: isVerified ? AppTheme.successGreen : AppTheme.accentRed,
                size: 24,
              ),
<<<<<<< HEAD
              SizedBox(width: 12.0),
=======
              SizedBox(width: 3.w),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              Expanded(
                child: Text(
                  isVerified
                      ? 'NYC Location Verified'
                      : 'Location Verification Required',
                  style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    color:
                        isVerified ? AppTheme.successGreen : AppTheme.accentRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
<<<<<<< HEAD
          SizedBox(height: 16.0),
=======
          SizedBox(height: 2.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
          if (currentLocation.isNotEmpty) ...[
            Text(
              'Current Location:',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
<<<<<<< HEAD
            SizedBox(height: 4.0),
=======
            SizedBox(height: 0.5.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
            Text(
              currentLocation,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
<<<<<<< HEAD
            SizedBox(height: 16.0),
=======
            SizedBox(height: 2.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
          ],
          if (!isVerified) ...[
            Text(
              'Select NYC Borough:',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
<<<<<<< HEAD
            SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
=======
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              children: boroughs.map((borough) {
                final isSelected = selectedBorough == borough;
                return GestureDetector(
                  onTap: () => onBoroughSelected(borough),
                  child: Container(
                    padding:
<<<<<<< HEAD
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
=======
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryOrange
                          : AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryOrange
                            : AppTheme.borderSubtle,
                      ),
                    ),
                    child: Text(
                      borough,
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? AppTheme.backgroundDark
                            : AppTheme.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
<<<<<<< HEAD
            SizedBox(height: 16.0),
=======
            SizedBox(height: 2.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
            if (onRetryLocation != null)
              TextButton.icon(
                onPressed: onRetryLocation,
                icon: CustomIconWidget(
                  iconName: 'refresh',
                  color: AppTheme.primaryOrange,
                  size: 18,
                ),
                label: Text(
                  'Retry GPS Location',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
