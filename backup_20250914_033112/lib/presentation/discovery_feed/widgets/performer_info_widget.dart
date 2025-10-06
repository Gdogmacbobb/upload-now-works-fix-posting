import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class PerformerInfoWidget extends StatelessWidget {
  final Map<String, dynamic> performerData;
  final VoidCallback? onPerformerTap;

  const PerformerInfoWidget({
    Key? key,
    required this.performerData,
    this.onPerformerTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract performer data from the video data structure
    final performer = performerData['performer'] as Map<String, dynamic>? ?? {};
    final username =
        performer['username'] ?? performerData['username'] ?? 'performer';
    final isVerified =
        performer['isVerified'] ?? performerData['isVerified'] ?? false;
    final performanceType =
        performer['performanceType'] ?? performerData['performanceType'];
    final location = performerData['location'] ?? 'NYC';
    final caption =
        performerData['caption'] ?? performerData['description'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Performer name and verification
        GestureDetector(
          onTap: onPerformerTap,
          child: Row(
            children: [
              Text(
                '@$username',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: AppTheme.backgroundDark.withOpacity( 0.8),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              if (isVerified)
                CustomIconWidget(
                  iconName: 'verified',
                  color: AppTheme.primaryOrange,
                  size: AppSpacing.md,
                ),
            ],
          ),
        ),

        SizedBox(height: AppSpacing.xxs),

        // Performance type tag
        if (performanceType != null && performanceType.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withOpacity( 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryOrange.withOpacity( 0.5),
                width: 1,
              ),
            ),
            child: Text(
              _formatPerformanceType(performanceType),
              style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.primaryOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        SizedBox(height: AppSpacing.xxs),

        // Location
        if (location.isNotEmpty)
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: AppTheme.textSecondary,
                size: AppSpacing.md,
              ),
              SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  location,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    shadows: [
                      Shadow(
                        color: AppTheme.backgroundDark.withOpacity( 0.8),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

        SizedBox(height: AppSpacing.xs),

        // Caption with hashtags
        if (caption.isNotEmpty)
          Container(
            constraints: BoxConstraints(maxHeight: AppSpacing.xl),
            child: SingleChildScrollView(
              child: RichText(
                text: TextSpan(
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    shadows: [
                      Shadow(
                        color: AppTheme.backgroundDark.withOpacity( 0.8),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  children: _buildCaptionSpans(caption),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatPerformanceType(String type) {
    switch (type.toLowerCase()) {
      case 'singer':
        return '🎤 Singer';
      case 'dancer':
        return '💃 Dancer';
      case 'magician':
        return '🎩 Magician';
      case 'musician':
        return '🎵 Musician';
      case 'artist':
        return '🎨 Artist';
      default:
        return '🎭 Performer';
    }
  }

  List<TextSpan> _buildCaptionSpans(String caption) {
    final List<TextSpan> spans = [];
    final RegExp hashtagRegex = RegExp(r'#\w+');
    final matches = hashtagRegex.allMatches(caption);

    int lastEnd = 0;
    for (final match in matches) {
      // Add text before hashtag
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: caption.substring(lastEnd, match.start),
        ));
      }

      // Add hashtag with orange color
      spans.add(TextSpan(
        text: match.group(0),
        style: TextStyle(
          color: AppTheme.primaryOrange,
          fontWeight: FontWeight.w500,
        ),
      ));

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < caption.length) {
      spans.add(TextSpan(
        text: caption.substring(lastEnd),
      ));
    }

    return spans.isEmpty ? [TextSpan(text: caption)] : spans;
  }
}
