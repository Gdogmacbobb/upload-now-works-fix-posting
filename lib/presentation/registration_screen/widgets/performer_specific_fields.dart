import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:ynfny/utils/responsive_scale.dart';
import 'package:ynfny/core/constants/performance_categories.dart';
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

class PerformerSpecificFields extends StatefulWidget {
<<<<<<< HEAD
  final List<String> selectedPerformanceTypes;
  final Function(String, bool) onCategoryToggled;
  final TextEditingController instagramController;
  final TextEditingController tiktokController;
  final TextEditingController youtubeController;
  final DateTime? selectedBirthDate;
  final Function(DateTime?) onBirthDateChanged;

  const PerformerSpecificFields({
    Key? key,
    required this.selectedPerformanceTypes,
    required this.onCategoryToggled,
    required this.instagramController,
    required this.tiktokController,
    required this.youtubeController,
    this.selectedBirthDate,
    required this.onBirthDateChanged,
=======
  final String? selectedPerformanceType;
  final Function(String?) onPerformanceTypeChanged;
  final TextEditingController instagramController;
  final TextEditingController tiktokController;
  final TextEditingController youtubeController;

  const PerformerSpecificFields({
    Key? key,
    this.selectedPerformanceType,
    required this.onPerformanceTypeChanged,
    required this.instagramController,
    required this.tiktokController,
    required this.youtubeController,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
  }) : super(key: key);

  @override
  State<PerformerSpecificFields> createState() =>
      _PerformerSpecificFieldsState();
}

class _PerformerSpecificFieldsState extends State<PerformerSpecificFields> {
<<<<<<< HEAD
  Widget _getIconForType(String category, bool isSelected) {
    return Text(
      PerformanceCategories.getEmoji(category),
      style: TextStyle(
        fontSize: 32,
        height: 1.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainCategories = PerformanceCategories.getMainCategories();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Age Verification',
=======
  final List<Map<String, dynamic>> performanceTypes = [
    {
      'value': 'music',
      'label': 'Music',
      'icon': 'music_note',
      'description': 'Singing, instruments, beatboxing',
    },
    {
      'value': 'dance',
      'label': 'Dance',
      'icon': 'sports_gymnastics',
      'description': 'Hip-hop, breakdancing, contemporary',
    },
    {
      'value': 'art',
      'label': 'Visual Art',
      'icon': 'palette',
      'description': 'Painting, drawing, sculpture',
    },
    {
      'value': 'comedy',
      'label': 'Comedy',
      'icon': 'theater_comedy',
      'description': 'Stand-up, improv, street comedy',
    },
    {
      'value': 'magic',
      'label': 'Magic',
      'icon': 'auto_fix_high',
      'description': 'Street magic, illusions',
    },
    {
      'value': 'other',
      'label': 'Other',
      'icon': 'category',
      'description': 'Acrobatics, juggling, etc.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Performance Type Section
        Text(
          'Performance Type',
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.primaryOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
<<<<<<< HEAD
          'You must be 18 or older to create an account',
=======
          'What type of street performance do you specialize in?',
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 2.h),

<<<<<<< HEAD
        Text(
          'Date of Birth',
          style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: () => _selectBirthDate(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.w),
            decoration: BoxDecoration(
              color: AppTheme.inputBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.borderSubtle,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    widget.selectedBirthDate != null
                        ? '${widget.selectedBirthDate!.month}/${widget.selectedBirthDate!.day}/${widget.selectedBirthDate!.year}'
                        : 'Select your birth date',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: widget.selectedBirthDate != null
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ),
                CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  color: AppTheme.textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),

        if (widget.selectedBirthDate != null)
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: _isAgeValid() ? 'check_circle' : 'error',
                  color: _isAgeValid()
                      ? AppTheme.successGreen
                      : AppTheme.accentRed,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  _isAgeValid()
                      ? 'Age verified (${_calculateAge()} years old)'
                      : 'You must be 18 or older to register',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: _isAgeValid()
                        ? AppTheme.successGreen
                        : AppTheme.accentRed,
                  ),
                ),
              ],
            ),
          ),

        SizedBox(height: 4.h),

        Text(
          'Performance Types',
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.primaryOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Select your performance categories',
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 2.h),

        // Main Category Grid
=======
        // Performance Type Grid
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
<<<<<<< HEAD
            childAspectRatio: 2.2,
          ),
          itemCount: mainCategories.length,
          itemBuilder: (context, index) {
            final category = mainCategories[index];
            final isSelected = widget.selectedPerformanceTypes.contains(category);

            return GestureDetector(
              onTap: () {
                widget.onCategoryToggled(category, !isSelected);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2A2A2D)
                      : const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFF8C00)
                        : const Color(0xFF3A3A3D),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF8C00).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
=======
            childAspectRatio: 2.5,
          ),
          itemCount: performanceTypes.length,
          itemBuilder: (context, index) {
            final type = performanceTypes[index];
            final isSelected = widget.selectedPerformanceType == type['value'];

            return GestureDetector(
              onTap: () {
                widget.onPerformanceTypeChanged(type['value']);
              },
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryOrange.withValues(alpha: 0.2)
                      : AppTheme.darkTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryOrange
                        : AppTheme.borderSubtle,
                    width: isSelected ? 2 : 1,
                  ),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
<<<<<<< HEAD
                    _getIconForType(category, isSelected),
                    SizedBox(height: 6),
                    Text(
                      category,
                      style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
=======
                    CustomIconWidget(
                      iconName: type['icon'],
                      color: isSelected
                          ? AppTheme.primaryOrange
                          : AppTheme.textSecondary,
                      size: 24,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      type['label'],
                      style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? AppTheme.primaryOrange
                            : AppTheme.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        SizedBox(height: 4.h),

        // Social Media Verification Section
        Text(
          'Social Media Verification',
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.primaryOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Link your social media accounts to verify your performance history (at least one required)',
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 2.h),

        // Instagram Handle
        Text(
          'Instagram Handle',
          style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.instagramController,
          style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: '@username',
            hintStyle: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withAlpha(153),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'camera_alt',
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!value.startsWith('@')) {
                return 'Instagram handle must start with @';
              }
              if (value.length < 2) {
                return 'Please enter a valid Instagram handle';
              }
            }
            return null;
          },
        ),
        SizedBox(height: 3.h),

        // TikTok Handle
        Text(
          'TikTok Handle',
          style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.tiktokController,
          style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: '@username',
            hintStyle: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withAlpha(153),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'video_library',
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!value.startsWith('@')) {
                return 'TikTok handle must start with @';
              }
              if (value.length < 2) {
                return 'Please enter a valid TikTok handle';
              }
            }
            return null;
          },
        ),
        SizedBox(height: 3.h),

        // YouTube Channel
        Text(
          'YouTube Channel',
          style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.youtubeController,
          style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Channel name or URL',
            hintStyle: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withAlpha(153),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'play_circle',
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
<<<<<<< HEAD
            if (value != null && value.isNotEmpty && value.length < 2) {
=======
            if (value != null && value.isNotEmpty && value.length < 3) {
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              return 'Please enter a valid YouTube channel';
            }
            return null;
          },
        ),
      ],
    );
  }
<<<<<<< HEAD

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppTheme.darkTheme.colorScheme.surface,
              headerBackgroundColor: AppTheme.primaryOrange,
              headerForegroundColor: AppTheme.backgroundDark,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.backgroundDark;
                }
                return AppTheme.textPrimary;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.primaryOrange;
                }
                return Colors.transparent;
              }),
              todayForegroundColor:
                  WidgetStateProperty.all(AppTheme.primaryOrange),
              todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
              todayBorder: const BorderSide(color: AppTheme.primaryOrange),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != widget.selectedBirthDate) {
      widget.onBirthDateChanged(picked);
    }
  }

  bool _isAgeValid() {
    if (widget.selectedBirthDate == null) return false;
    return _calculateAge() >= 18;
  }

  int _calculateAge() {
    if (widget.selectedBirthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - widget.selectedBirthDate!.year;
    if (now.month < widget.selectedBirthDate!.month ||
        (now.month == widget.selectedBirthDate!.month &&
            now.day < widget.selectedBirthDate!.day)) {
      age--;
    }
    return age;
  }
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
}
