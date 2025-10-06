import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:ynfny/utils/responsive_scale.dart';
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

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
            padding: EdgeInsets.all(4.w),
            height: 40.h,
            child: Column(children: [
              Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                      color: AppTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(2))),
              SizedBox(height: 2.h),
              Text('Add New Card',
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              SizedBox(height: 3.h),
              Text(
                  'This feature will integrate with Stripe for secure card management.',
                  style: AppTheme.darkTheme.textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.textSecondary)),
              SizedBox(height: 3.h),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close')),
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Payment Method',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          SizedBox(height: 2.h),

          // Payment Methods List
          ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _paymentMethods.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                final isSelected = widget.selectedPaymentMethod == method['id'];

                return GestureDetector(
                    onTap: () => _selectPaymentMethod(method['id'] as String),
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 2.h),
                        decoration: BoxDecoration(
                            color: isSelected
<<<<<<< HEAD
                                ? AppTheme.primaryOrange.withOpacity(0.1)
=======
                                ? AppTheme.primaryOrange.withValues(alpha: 0.1)
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                                : AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryOrange
                                    : AppTheme.borderSubtle,
                                width: isSelected ? 2 : 1)),
                        child: Row(children: [
                          Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                  color: AppTheme.inputBackground,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                  child: CustomIconWidget(
                                      iconName: method['icon'] as String,
                                      color: AppTheme.textPrimary,
                                      size: 20))),
                          SizedBox(width: 3.w),
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

          SizedBox(height: 2.h),

          // Add New Card Button
          GestureDetector(
              onTap: _addNewCard,
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.primaryOrange, width: 1.5)),
                  child: Row(children: [
                    Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                            color:
<<<<<<< HEAD
                                AppTheme.primaryOrange.withOpacity(0.1),
=======
                                AppTheme.primaryOrange.withValues(alpha: 0.1),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                            child: CustomIconWidget(
                                iconName: 'add',
                                color: AppTheme.primaryOrange,
                                size: 20))),
                    SizedBox(width: 3.w),
                    Text('Add New Card',
                        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.w500)),
                  ]))),
        ]));
  }
}
