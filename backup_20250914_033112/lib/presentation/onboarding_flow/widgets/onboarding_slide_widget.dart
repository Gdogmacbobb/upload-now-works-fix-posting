import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class OnboardingSlideWidget extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final bool isLastSlide;

  const OnboardingSlideWidget({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    this.isLastSlide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.backgroundDark,
            AppTheme.backgroundDark.withOpacity( 0.8),
            AppTheme.backgroundDark,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Hero Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.backgroundDark.withOpacity( 0.3),
                    AppTheme.backgroundDark.withOpacity( 0.8),
                  ],
                ),
              ),
              child: CustomImageWidget(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 45,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.backgroundDark.withOpacity( 0.9),
                    AppTheme.backgroundDark,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.xs),

                  // Title
                  Text(
                    title,
                    style:
                        AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: AppSpacing.xs),

                  // Description
                  Text(
                    description,
                    style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: AppSpacing.md),

                  // Brand Accent
                  if (isLastSlide)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity( 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryOrange.withOpacity( 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'WE OUTSIDE',
                        style:
                            AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
