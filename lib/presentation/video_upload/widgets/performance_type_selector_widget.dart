import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

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
<<<<<<< HEAD
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
=======
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Type',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
<<<<<<< HEAD
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.0),
          SizedBox(
            height: 48.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: performanceTypes.length,
              separatorBuilder: (context, index) => SizedBox(width: 12.0),
=======
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.5.h),
          SizedBox(
            height: 6.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: performanceTypes.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              itemBuilder: (context, index) {
                final type = performanceTypes[index];
                final isSelected = selectedType == type['name'];

                return GestureDetector(
                  onTap: () => onTypeSelected(type['name'] as String),
                  child: Container(
                    padding:
<<<<<<< HEAD
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
=======
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
                        SizedBox(width: 8.0),
=======
                        SizedBox(width: 2.w),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                        Text(
                          type['name'] as String,
                          style: AppTheme.darkTheme.textTheme.labelMedium
                              ?.copyWith(
<<<<<<< HEAD
                            fontSize: 12.0,
=======
                            fontSize: 12.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
