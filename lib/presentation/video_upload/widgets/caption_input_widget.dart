import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CaptionInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const CaptionInputWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<CaptionInputWidget> createState() => _CaptionInputWidgetState();
}

class _CaptionInputWidgetState extends State<CaptionInputWidget> {
  static const int maxCharacters = 280;

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
            'Caption',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
<<<<<<< HEAD
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.0),
=======
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
          Container(
            decoration: BoxDecoration(
              color: AppTheme.inputBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.darkTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              onChanged: (value) {
                setState(() {});
                widget.onChanged(value);
              },
              maxLines: 4,
              maxLength: maxCharacters,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
<<<<<<< HEAD
                fontSize: 14.0,
=======
                fontSize: 14.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              ),
              decoration: InputDecoration(
                hintText: 'Share your performance story... #StreetArt #NYC',
                hintStyle:
                    AppTheme.darkTheme.inputDecorationTheme.hintStyle?.copyWith(
<<<<<<< HEAD
                  fontSize: 14.0,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16.0),
=======
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(4.w),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                counterText: '',
              ),
            ),
          ),
<<<<<<< HEAD
          SizedBox(height: 8.0),
=======
          SizedBox(height: 1.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add hashtags and @mentions',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
<<<<<<< HEAD
                  fontSize: 11.0,
=======
                  fontSize: 11.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${widget.controller.text.length}/$maxCharacters',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
<<<<<<< HEAD
                  fontSize: 11.0,
=======
                  fontSize: 11.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  color: widget.controller.text.length > maxCharacters * 0.9
                      ? AppTheme.accentRed
                      : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
