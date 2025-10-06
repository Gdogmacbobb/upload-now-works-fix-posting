import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

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
      padding: EdgeInsets.all(AppSpacing.md),
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: AppTheme.glassmorphismDecoration(
        backgroundColor: isVerified
            ? AppTheme.successGreen.withOpacity( 0.2)
            : AppTheme.accentRed.withOpacity( 0.2),
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
              SizedBox(width: AppSpacing.sm),
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
          SizedBox(height: AppSpacing.xs),
          if (currentLocation.isNotEmpty) ...[
            Text(
              'Current Location:',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 0.20),
            Text(
              currentLocation,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
          ],
          if (!isVerified) ...[
            Text(
              'Select NYC Borough:',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppSpacing.xxs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xxs,
              children: boroughs.map((borough) {
                final isSelected = selectedBorough == borough;
                return GestureDetector(
                  onTap: () => onBoroughSelected(borough),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
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
            SizedBox(height: AppSpacing.xs),
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
