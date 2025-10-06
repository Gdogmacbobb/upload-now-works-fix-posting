import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ynfny/core/app_export.dart';

class DonationSuccessWidget extends StatelessWidget {
  final double donationAmount;
  final String performerName;
  final String transactionId;
  final Function() onClose;
  final Function() onShareSuccess;

  const DonationSuccessWidget({
    Key? key,
    required this.donationAmount,
    required this.performerName,
    required this.transactionId,
    required this.onClose,
    required this.onShareSuccess,
  }) : super(key: key);

  void _shareSuccess() {
    HapticFeedback.lightImpact();
    onShareSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success Animation Container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.successGreen.withOpacity( 0.1),
              border: Border.all(
                color: AppTheme.successGreen,
                width: 2,
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'check',
                color: AppTheme.successGreen,
                size: 40,
              ),
            ),
          ),

          SizedBox(height: AppSpacing.sm),

          // Success Message
          Text(
            'Donation Successful!',
            style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.xxs),

          Text(
            'Thank you for supporting $performerName',
            style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.sm),

          // Donation Details
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.borderSubtle,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount Donated',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '\$${donationAmount.toStringAsFixed(2)}',
                      style:
                          AppTheme.donationAmountStyle(isLight: false).copyWith(
                        fontSize: 18,
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xxs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction ID',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      transactionId,
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xxs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date & Time',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.sm),

          // Receipt Email Notice
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withOpacity( 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryOrange.withOpacity( 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'email',
                  color: AppTheme.primaryOrange,
                  size: 16,
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'A receipt has been sent to your email address',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.sm),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareSuccess,
                  icon: CustomIconWidget(
                    iconName: 'share',
                    color: AppTheme.primaryOrange,
                    size: 18,
                  ),
                  label: Text('Share'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  ),
                  child: Text('Done'),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.xs),

          // Support Message
          Text(
            'Your support helps keep street art alive in NYC! 🎭',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
