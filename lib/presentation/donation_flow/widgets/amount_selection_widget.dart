import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'package:ynfny/utils/responsive_scale.dart';
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

class AmountSelectionWidget extends StatefulWidget {
  final Function(double) onAmountSelected;
  final double selectedAmount;

  const AmountSelectionWidget({
    Key? key,
    required this.onAmountSelected,
    required this.selectedAmount,
  }) : super(key: key);

  @override
  State<AmountSelectionWidget> createState() => _AmountSelectionWidgetState();
}

class _AmountSelectionWidgetState extends State<AmountSelectionWidget> {
  final TextEditingController _customAmountController = TextEditingController();
  final List<double> _presetAmounts = [1.0, 5.0, 10.0, 20.0, 50.0];
  bool _isCustomAmountSelected = false;

  @override
  void initState() {
    super.initState();
    _customAmountController.addListener(_onCustomAmountChanged);
  }

  @override
  void dispose() {
    _customAmountController.removeListener(_onCustomAmountChanged);
    _customAmountController.dispose();
    super.dispose();
  }

  void _onCustomAmountChanged() {
    final text = _customAmountController.text;
    if (text.isNotEmpty) {
      final amount = double.tryParse(text);
      if (amount != null && amount > 0) {
        setState(() {
          _isCustomAmountSelected = true;
        });
        widget.onAmountSelected(amount);
      }
    }
  }

  void _selectPresetAmount(double amount) {
    HapticFeedback.lightImpact();
    setState(() {
      _isCustomAmountSelected = false;
      _customAmountController.clear();
    });
    widget.onAmountSelected(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Amount',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),

          // Preset Amount Buttons
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _presetAmounts.map((amount) {
              final isSelected =
                  widget.selectedAmount == amount && !_isCustomAmountSelected;
              return GestureDetector(
                onTap: () => _selectPresetAmount(amount),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryOrange
                        : AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryOrange
                          : AppTheme.borderSubtle,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '\$${amount.toStringAsFixed(0)}',
                    style:
                        AppTheme.donationAmountStyle(isLight: false).copyWith(
                      fontSize: 14.sp,
                      color: isSelected
                          ? AppTheme.backgroundDark
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 2.h),

          // Custom Amount Input
          Text(
            'Or enter custom amount',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 1.h),

          Container(
            decoration: BoxDecoration(
              color: _isCustomAmountSelected
<<<<<<< HEAD
                  ? AppTheme.primaryOrange.withOpacity(0.1)
=======
                  ? AppTheme.primaryOrange.withValues(alpha: 0.1)
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  : AppTheme.inputBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isCustomAmountSelected
                    ? AppTheme.primaryOrange
                    : AppTheme.borderSubtle,
                width: _isCustomAmountSelected ? 2 : 1,
              ),
            ),
            child: TextFormField(
              controller: _customAmountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: AppTheme.donationAmountStyle(isLight: false).copyWith(
                fontSize: 16.sp,
              ),
              decoration: InputDecoration(
                hintText: '\$0.00',
                hintStyle: AppTheme.darkTheme.inputDecorationTheme.hintStyle,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 4.w, top: 2.h, bottom: 2.h),
                  child: Text(
                    '\$',
                    style:
                        AppTheme.donationAmountStyle(isLight: false).copyWith(
                      fontSize: 16.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                prefixIconConstraints:
                    BoxConstraints(minWidth: 0, minHeight: 0),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              ),
            ),
          ),

          SizedBox(height: 1.h),

          // Selected Amount Display
          if (widget.selectedAmount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
<<<<<<< HEAD
                color: AppTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryOrange.withOpacity(0.3),
=======
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.3),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.primaryOrange,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Selected: \$${widget.selectedAmount.toStringAsFixed(2)}',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
