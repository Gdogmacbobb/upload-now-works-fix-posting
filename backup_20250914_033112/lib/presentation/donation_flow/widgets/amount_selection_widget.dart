import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ynfny/core/app_export.dart';

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
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
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
          SizedBox(height: AppSpacing.xs),

          // Preset Amount Buttons
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xxs,
            children: _presetAmounts.map((amount) {
              final isSelected =
                  widget.selectedAmount == amount && !_isCustomAmountSelected;
              return GestureDetector(
                onTap: () => _selectPresetAmount(amount),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 1.20),
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
                      fontSize: 14,
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

          SizedBox(height: AppSpacing.xs),

          // Custom Amount Input
          Text(
            'Or enter custom amount',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xxs),

          Container(
            decoration: BoxDecoration(
              color: _isCustomAmountSelected
                  ? AppTheme.primaryOrange.withOpacity( 0.1)
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
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: '\$0.00',
                hintStyle: AppTheme.darkTheme.inputDecorationTheme.hintStyle,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: AppSpacing.md, top: AppSpacing.xs, bottom: AppSpacing.xs),
                  child: Text(
                    '\$',
                    style:
                        AppTheme.donationAmountStyle(isLight: false).copyWith(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                prefixIconConstraints:
                    BoxConstraints(minWidth: 0, minHeight: 0),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              ),
            ),
          ),

          SizedBox(height: AppSpacing.xxs),

          // Selected Amount Display
          if (widget.selectedAmount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity( 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryOrange.withOpacity( 0.3),
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
                  SizedBox(width: AppSpacing.xs),
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
