import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class RecordingSettingsWidget extends StatelessWidget {
  final bool showGrid;
  final VoidCallback onToggleGrid;
  final String selectedQuality;
  final List<String> qualityOptions;
  final Function(String) onQualityChanged;
  final VoidCallback? onClose;

  const RecordingSettingsWidget({
    super.key,
    required this.showGrid,
    required this.onToggleGrid,
    required this.selectedQuality,
    required this.qualityOptions,
    required this.onQualityChanged,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: AppTheme.glassmorphismDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recording Settings',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onClose != null)
                GestureDetector(
                  onTap: onClose,
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.textSecondary,
                    size: 24,
                  ),
                ),
            ],
          ),
          SizedBox(height: 24.0),

          // Grid toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Show Grid',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              Switch(
                value: showGrid,
                onChanged: (_) => onToggleGrid(),
                activeColor: AppTheme.primaryOrange,
              ),
            ],
          ),
          SizedBox(height: 16.0),

          // Quality selection
          Text(
            'Video Quality',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.0),
          Column(
            children: qualityOptions.map((quality) {
              final isSelected = selectedQuality == quality;
              return GestureDetector(
                onTap: () => onQualityChanged(quality),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  margin: EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryOrange.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryOrange
                          : AppTheme.borderSubtle,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 12.0),
                      CustomIconWidget(
                        iconName: isSelected
                            ? 'radio_button_checked'
                            : 'radio_button_unchecked',
                        color: isSelected
                            ? AppTheme.primaryOrange
                            : AppTheme.textSecondary,
                        size: 20,
                      ),
                      SizedBox(width: 12.0),
                      Text(
                        quality,
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.primaryOrange
                              : AppTheme.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
