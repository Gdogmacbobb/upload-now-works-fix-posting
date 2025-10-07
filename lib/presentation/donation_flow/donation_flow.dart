import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ynfny/utils/responsive_scale.dart';

import '../../core/app_export.dart';
import './widgets/amount_selection_widget.dart';
import './widgets/donation_success_widget.dart';
import './widgets/message_input_widget.dart';
import './widgets/payment_method_widget.dart';
import './widgets/performer_info_widget.dart';
import './widgets/transaction_summary_widget.dart';

class DonationFlow extends StatefulWidget {
  const DonationFlow({Key? key}) : super(key: key);

  @override
  State<DonationFlow> createState() => _DonationFlowState();
}

class _DonationFlowState extends State<DonationFlow> {
  double _selectedAmount = 0.0;
  String _selectedPaymentMethod = '';
  String _donationMessage = '';
  bool _isNonRefundableAccepted = false;
  bool _isProcessing = false;
  bool _showSuccess = false;
  String _transactionId = '';

  // Mock performer data
  final Map<String, dynamic> _performerData = {
    'id': 'performer_001',
    'name': 'Marcus "Jazz Hands" Rodriguez',
    'performanceType': 'Jazz Saxophone',
    'location': 'Washington Square Park, Manhattan',
    'avatar':
        'https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=400',
    'recentPerformance':
        'https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg?auto=compress&cs=tinysrgb&w=400',
    'followers': 2847,
    'totalDonations': 15420.50,
  };

  double get _platformFee => _selectedAmount * 0.05;
  double get _netAmount => _selectedAmount - _platformFee;

  bool get _canProceed =>
      _selectedAmount > 0 &&
      _selectedPaymentMethod.isNotEmpty &&
      _isNonRefundableAccepted;

  @override
  void initState() {
    super.initState();
    // Set default payment method
    _selectedPaymentMethod = 'apple_pay';
  }

  void _onAmountSelected(double amount) {
    setState(() {
      _selectedAmount = amount;
    });
  }

  void _onPaymentMethodSelected(String methodId) {
    setState(() {
      _selectedPaymentMethod = methodId;
    });
  }

  void _onMessageChanged(String message) {
    setState(() {
      _donationMessage = message;
    });
  }

  void _onNonRefundableChanged(bool accepted) {
    setState(() {
      _isNonRefundableAccepted = accepted;
    });
  }

  Future<void> _processDonation() async {
    if (!_canProceed) return;

    setState(() {
      _isProcessing = true;
    });

    HapticFeedback.mediumImpact();

    try {
      // Simulate Stripe payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Generate mock transaction ID
      _transactionId =
          'TXN_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      // Simulate biometric authentication
      await _simulateBiometricAuth();

      setState(() {
        _showSuccess = true;
        _isProcessing = false;
      });

      HapticFeedback.heavyImpact();
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      _showErrorDialog(
          'Payment failed. Please try again or use a different payment method.');
    }
  }

  Future<void> _simulateBiometricAuth() async {
    // Simulate Face ID / Touch ID / Fingerprint authentication
    await Future.delayed(const Duration(milliseconds: 800));
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          'Payment Error',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _shareSuccess() {
    // Simulate sharing to social media
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Shared your support for ${_performerData['name']}!'),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _closeFlow() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: _showSuccess ? _buildSuccessView() : _buildDonationForm(),
      ),
    );
  }

  Widget _buildSuccessView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _closeFlow,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Donation Complete',
                    style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 12.w), // Balance the close button
              ],
            ),
          ),

          SizedBox(height: 2.h),

          DonationSuccessWidget(
            donationAmount: _selectedAmount,
            performerName: _performerData['name'] as String,
            transactionId: _transactionId,
            onClose: _closeFlow,
            onShareSuccess: _shareSuccess,
          ),
        ],
      ),
    );
  }

  Widget _buildDonationForm() {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowDark,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.inputBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Support Performer',
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 12.w), // Balance the back button
            ],
          ),
        ),

        // Form Content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 2.h),

                // Performer Info
                PerformerInfoWidget(performerData: _performerData),

                // Amount Selection
                AmountSelectionWidget(
                  onAmountSelected: _onAmountSelected,
                  selectedAmount: _selectedAmount,
                ),

                // Payment Method
                PaymentMethodWidget(
                  onPaymentMethodSelected: _onPaymentMethodSelected,
                  selectedPaymentMethod: _selectedPaymentMethod,
                ),

                // Message Input
                MessageInputWidget(
                  onMessageChanged: _onMessageChanged,
                  message: _donationMessage,
                ),

                // Transaction Summary
                if (_selectedAmount > 0)
                  TransactionSummaryWidget(
                    donationAmount: _selectedAmount,
                    platformFee: _platformFee,
                    netAmount: _netAmount,
                    isNonRefundableAccepted: _isNonRefundableAccepted,
                    onNonRefundableChanged: _onNonRefundableChanged,
                  ),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),

        // Donate Button
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowDark,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              if (_selectedAmount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'favorite',
                        color: AppTheme.primaryOrange,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Donating \$${_selectedAmount.toStringAsFixed(2)} to ${_performerData['name']}',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _canProceed && !_isProcessing ? _processDonation : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canProceed
                        ? AppTheme.primaryOrange
                        : AppTheme.borderSubtle,
                    foregroundColor: _canProceed
                        ? AppTheme.backgroundDark
                        : AppTheme.textSecondary,
                    padding: EdgeInsets.symmetric(vertical: 2.5.h),
                    elevation: _canProceed ? 4 : 0,
                  ),
                  child: _isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 5.w,
                              height: 5.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.backgroundDark,
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Processing...',
                              style: AppTheme.darkTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.backgroundDark,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'favorite',
                              color: _canProceed
                                  ? AppTheme.backgroundDark
                                  : AppTheme.textSecondary,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              _selectedAmount > 0
                                  ? 'Donate \$${_selectedAmount.toStringAsFixed(2)}'
                                  : 'Select Amount to Donate',
                              style: AppTheme.darkTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
