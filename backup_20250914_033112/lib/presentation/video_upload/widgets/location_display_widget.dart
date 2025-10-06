import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

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
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.20),
          GestureDetector(
            onTap: onLocationTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
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
                    padding: EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity( 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'location_on',
                      color: AppTheme.successGreen,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
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
                            SizedBox(width: AppSpacing.xxs),
                            Text(
                              currentLocation,
                              style: AppTheme.darkTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (specificSpot != null) ...[
                          SizedBox(height: 0.20),
                          Text(
                            specificSpot!,
                            style: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              fontSize: 12,
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
          SizedBox(height: AppSpacing.xxs),
          Text(
            'NYC location verified • Tap to select specific spot',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
