import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class HandleSuggestionsWidget extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;

  const HandleSuggestionsWidget({
    Key? key,
    required this.suggestions,
    required this.onSuggestionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'lightbulb',
                color: AppTheme.primaryOrange,
                size: 20,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Suggested Alternatives',
                style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xxs,
            children: suggestions
                .map((suggestion) => _buildSuggestionChip(suggestion))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return GestureDetector(
      onTap: () => onSuggestionTap(suggestion),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange.withAlpha(26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryOrange.withAlpha(77),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '@',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              suggestion,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: AppSpacing.xxs),
            CustomIconWidget(
              iconName: 'arrow_forward',
              color: AppTheme.primaryOrange,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
