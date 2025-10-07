import 'package:flutter/material.dart';

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
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.0),
          GestureDetector(
            onTap: onLocationTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
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
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'location_on',
                      color: AppTheme.successGreen,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12.0),
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
                            SizedBox(width: 4.0),
                            Text(
                              currentLocation,
                              style: AppTheme.darkTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (specificSpot != null) ...[
                          SizedBox(height: 4.0),
                          Text(
                            specificSpot!,
                            style: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              fontSize: 12.0,
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
          SizedBox(height: 8.0),
          Text(
            'NYC location verified • Tap to select specific spot',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              fontSize: 11.0,
              color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
