import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class PerformanceTypeSelectorWidget extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeSelected;

  const PerformanceTypeSelectorWidget({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  static const List<Map<String, dynamic>> performanceTypes = [
    {'name': 'Music', 'icon': 'music_note'},
    {'name': 'Dance', 'icon': 'directions_run'},
    {'name': 'Visual Arts', 'icon': 'palette'},
    {'name': 'Skit', 'icon': 'theater_comedy'},
    {'name': 'Other', 'icon': 'category'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Type',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.20),
          SizedBox(
            height: AppSpacing.lg,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: performanceTypes.length,
              separatorBuilder: (context, index) => SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final type = performanceTypes[index];
                final isSelected = selectedType == type['name'];

                return GestureDetector(
                  onTap: () => onTypeSelected(type['name'] as String),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.darkTheme.colorScheme.primary
                          : AppTheme.darkTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.darkTheme.colorScheme.primary
                            : AppTheme.darkTheme.colorScheme.outline,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: type['icon'] as String,
                          color: isSelected
                              ? AppTheme.darkTheme.colorScheme.onPrimary
                              : AppTheme.darkTheme.colorScheme.onSurface,
                          size: 18,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          type['name'] as String,
                          style: AppTheme.darkTheme.textTheme.labelMedium
                              ?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppTheme.darkTheme.colorScheme.onPrimary
                                : AppTheme.darkTheme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
