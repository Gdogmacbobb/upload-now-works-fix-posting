import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:ynfny/utils/responsive_scale.dart';
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

class MessageInputWidget extends StatefulWidget {
  final Function(String) onMessageChanged;
  final String message;

  const MessageInputWidget({
    Key? key,
    required this.onMessageChanged,
    required this.message,
  }) : super(key: key);

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  final TextEditingController _messageController = TextEditingController();
  final int _maxCharacters = 100;

  @override
  void initState() {
    super.initState();
    _messageController.text = widget.message;
    _messageController.addListener(_onMessageChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageChanged);
    _messageController.dispose();
    super.dispose();
  }

  void _onMessageChanged() {
    widget.onMessageChanged(_messageController.text);
  }

  @override
  Widget build(BuildContext context) {
    final remainingCharacters = _maxCharacters - _messageController.text.length;
    final isNearLimit = remainingCharacters <= 20;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add a Message (Optional)',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '$remainingCharacters/$_maxCharacters',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color:
                      isNearLimit ? AppTheme.accentRed : AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),

          Container(
            decoration: BoxDecoration(
              color: AppTheme.inputBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _messageController.text.isNotEmpty
<<<<<<< HEAD
                    ? AppTheme.primaryOrange.withOpacity(0.5)
=======
                    ? AppTheme.primaryOrange.withValues(alpha: 0.5)
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                    : AppTheme.borderSubtle,
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: _messageController,
              maxLines: 3,
              maxLength: _maxCharacters,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Send some encouragement to the performer...',
                hintStyle: AppTheme.darkTheme.inputDecorationTheme.hintStyle,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                counterText: '', // Hide default counter
              ),
            ),
          ),

          SizedBox(height: 1.h),

          // Message Preview
          if (_messageController.text.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
              decoration: BoxDecoration(
<<<<<<< HEAD
                color: AppTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryOrange.withOpacity(0.3),
=======
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.3),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomIconWidget(
                    iconName: 'format_quote',
                    color: AppTheme.primaryOrange,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      _messageController.text,
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 1.h),

          // Suggested Messages
          Text(
            'Quick Messages:',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 0.5.h),

          Wrap(
            spacing: 2.w,
            runSpacing: 0.5.h,
            children: [
              'Keep up the great work! 🎵',
              'Amazing performance! 👏',
              'You made my day! ✨',
              'Love your energy! 🔥',
            ].map((suggestion) {
              return GestureDetector(
                onTap: () {
                  _messageController.text = suggestion;
                  widget.onMessageChanged(suggestion);
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    suggestion,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 10.sp,
                    ),
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
