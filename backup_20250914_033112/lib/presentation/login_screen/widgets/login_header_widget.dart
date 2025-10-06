import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // YNFNY Logo - Made bigger
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowDark,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/YNFNY_Logo-1753709879889.png',
              width: 140,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Statue of Liberty silhouette
                      Icon(
                        Icons.account_balance,
                        color: AppTheme.textSecondary,
                        size: 64,
                      ),
                      // Red glowing eyes effect
                      Positioned(
                        top: 32,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppTheme.accentRed,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentRed
                                        .withOpacity(0.6),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppTheme.accentRed,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentRed
                                        .withOpacity( 0.6),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // YNFNY Brand Text
        Text(
          'YNFNY',
          style: AppTheme.darkTheme.textTheme.headlineLarge?.copyWith(
            color: AppTheme.primaryOrange,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),

        const SizedBox(height: 2),

        // WE OUTSIDE Tagline
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange.withOpacity( 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.primaryOrange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            'WE OUTSIDE',
            style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Welcome Back Text
        Text(
          'Welcome Back',
          style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 2),

        // Subtitle
        Text(
          'Sign in to discover NYC street performers',
          style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
