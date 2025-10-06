import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PerformerSpecificFields extends StatefulWidget {
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
  }) : super(key: key);

  @override
  State<PerformerSpecificFields> createState() =>
      _PerformerSpecificFieldsState();
}

class _PerformerSpecificFieldsState extends State<PerformerSpecificFields> {
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
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.primaryOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'What type of street performance do you specialize in?',
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 2.h),

        // Performance Type Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
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
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
            if (value != null && value.isNotEmpty && value.length < 3) {
              return 'Please enter a valid YouTube channel';
            }
            return null;
          },
        ),
      ],
    );
  }
}
