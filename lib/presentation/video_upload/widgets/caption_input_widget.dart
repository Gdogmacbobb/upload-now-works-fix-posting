import 'package:flutter/material.dart';

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
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Caption',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.0),
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
                fontSize: 14.0,
              ),
              decoration: InputDecoration(
                hintText: 'Share your performance story... #StreetArt #NYC',
                hintStyle:
                    AppTheme.darkTheme.inputDecorationTheme.hintStyle?.copyWith(
                  fontSize: 14.0,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16.0),
                counterText: '',
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add hashtags and @mentions',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 11.0,
                  color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${widget.controller.text.length}/$maxCharacters',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 11.0,
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
