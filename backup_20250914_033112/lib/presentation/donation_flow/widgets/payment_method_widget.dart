import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class PaymentMethodWidget extends StatefulWidget {
  final Function(String) onPaymentMethodSelected;
  final String selectedPaymentMethod;

  const PaymentMethodWidget({
    Key? key,
    required this.onPaymentMethodSelected,
    required this.selectedPaymentMethod,
  }) : super(key: key);

  @override
  State<PaymentMethodWidget> createState() => _PaymentMethodWidgetState();
}

class _PaymentMethodWidgetState extends State<PaymentMethodWidget> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'apple_pay',
      'name': 'Apple Pay',
      'icon': 'apple',
      'available': true,
    },
    {
      'id': 'google_pay',
      'name': 'Google Pay',
      'icon': 'google',
      'available': true,
    },
    {
      'id': 'card_1234',
      'name': 'Visa •••• 1234',
      'icon': 'credit_card',
      'available': true,
    },
    {
      'id': 'card_5678',
      'name': 'Mastercard •••• 5678',
      'icon': 'credit_card',
      'available': true,
    },
  ];

  void _selectPaymentMethod(String methodId) {
    widget.onPaymentMethodSelected(methodId);
  }

  void _addNewCard() {
    // Navigate to add card screen or show modal
    showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.surfaceDark,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => Container(
            padding: EdgeInsets.all(AppSpacing.md),
            height: 40,
            child: Column(children: [
              Container(
                  width: 48,
                  height: 0.20,
                  decoration: BoxDecoration(
                      color: AppTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(2))),
              SizedBox(height: AppSpacing.xs),
              Text('Add New Card',
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              SizedBox(height: AppSpacing.sm),
              Text(
                  'This feature will integrate with Stripe for secure card management.',
                  style: AppTheme.darkTheme.textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.textSecondary)),
              SizedBox(height: AppSpacing.sm),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close')),
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Payment Method',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          SizedBox(height: AppSpacing.xs),

          // Payment Methods List
          ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _paymentMethods.length,
              separatorBuilder: (context, index) => SizedBox(height: AppSpacing.xxs),
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                final isSelected = widget.selectedPaymentMethod == method['id'];

                return GestureDetector(
                    onTap: () => _selectPaymentMethod(method['id'] as String),
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryOrange.withOpacity( 0.1)
                                : AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryOrange
                                    : AppTheme.borderSubtle,
                                width: isSelected ? 2 : 1)),
                        child: Row(children: [
                          Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                  color: AppTheme.inputBackground,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                  child: CustomIconWidget(
                                      iconName: method['icon'] as String,
                                      color: AppTheme.textPrimary,
                                      size: 20))),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                              child: Text(method['name'] as String,
                                  style: AppTheme.darkTheme.textTheme.bodyLarge
                                      ?.copyWith(
                                          color: AppTheme.textPrimary,
                                          fontWeight: FontWeight.w500))),
                          if (isSelected)
                            CustomIconWidget(
                                iconName: 'check_circle',
                                color: AppTheme.primaryOrange,
                                size: 20),
                        ])));
              }),

          SizedBox(height: AppSpacing.xs),

          // Add New Card Button
          GestureDetector(
              onTap: _addNewCard,
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.primaryOrange, width: 1.5)),
                  child: Row(children: [
                    Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                            color:
                                AppTheme.primaryOrange.withOpacity( 0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                            child: CustomIconWidget(
                                iconName: 'add',
                                color: AppTheme.primaryOrange,
                                size: 20))),
                    SizedBox(width: AppSpacing.sm),
                    Text('Add New Card',
                        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.w500)),
                  ]))),
        ]));
  }
}
