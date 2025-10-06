import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

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
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
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
          SizedBox(height: AppSpacing.xxs),

          Container(
            decoration: BoxDecoration(
              color: AppTheme.inputBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _messageController.text.isNotEmpty
                    ? AppTheme.primaryOrange.withOpacity( 0.5)
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
                    EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                counterText: '', // Hide default counter
              ),
            ),
          ),

          SizedBox(height: AppSpacing.xxs),

          // Message Preview
          if (_messageController.text.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 1.20),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity( 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryOrange.withOpacity( 0.3),
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
                  SizedBox(width: AppSpacing.xs),
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

          SizedBox(height: AppSpacing.xxs),

          // Suggested Messages
          Text(
            'Quick Messages:',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 0.20),

          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: 0.20,
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
                      EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 0.20),
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
                      fontSize: 10,
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
