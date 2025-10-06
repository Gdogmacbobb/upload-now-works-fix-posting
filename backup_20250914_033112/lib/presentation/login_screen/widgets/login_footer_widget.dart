import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class LoginFooterWidget extends StatelessWidget {
  const LoginFooterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),

        // Divider with OR text
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.borderSubtle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.borderSubtle,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Sign Up Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'New to YNFNY? ',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/account-type-selection');
              },
              child: Text(
                'Sign Up',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.primaryOrange,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Terms and Privacy
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'By continuing, you agree to our Terms of Service and Privacy Policy',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  void _handleBiometricLogin(BuildContext context) {
    // Show biometric authentication dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          'Biometric Authentication',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'fingerprint',
              color: AppTheme.primaryOrange,
              size: 60,
            ),
            const SizedBox(height: 8),
            Text(
              'Use your fingerprint or face to sign in quickly and securely',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Simulate successful biometric authentication
              Navigator.pushReplacementNamed(context, '/discovery-feed');
            },
            child: Text(
              'Continue',
              style: TextStyle(color: AppTheme.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }
}
