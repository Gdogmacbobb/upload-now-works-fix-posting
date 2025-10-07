import 'package:flutter/material.dart';
import 'package:ynfny/utils/responsive_scale.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/account_type_card.dart';
import './widgets/continue_button_widget.dart';
import './widgets/explanation_text_widget.dart';
import './widgets/ynfny_logo_widget.dart';

class AccountTypeSelection extends StatefulWidget {
  const AccountTypeSelection({super.key});

  @override
  State<AccountTypeSelection> createState() => _AccountTypeSelectionState();
}

class _AccountTypeSelectionState extends State<AccountTypeSelection> {
  String? selectedAccountType;

  final List<Map<String, dynamic>> accountTypes = [
    {
      "type": "street_performer",
      "title": "Street Performer",
      "description": "Showcase your talent and earn from your performances",
      "iconName": "mic",
      "accentColor": AppTheme.primaryOrange,
      "features": [
        "Upload and share performance videos",
        "Receive donations from supporters",
        "Build your follower base",
        "Monetize your street art talents"
      ],
      "verificationInfo":
          "Verification required: 1-2 business days approval process"
    },
    {
      "type": "new_yorker",
      "title": "New Yorker",
      "description": "Discover and watch amazing street performers do their thing",
      "iconName": "favorite",
      "accentColor": AppTheme.successGreen,
      "features": [
        "Discover local street performances",
        "Support performers with donations",
        "Share and repost favorite content"
      ],
      "verificationInfo":
          "Instant access: Start discovering performances immediately"
    }
  ];

  void _selectAccountType(String type) {
    setState(() {
      selectedAccountType = type;
    });
  }

  void _continueToRegistration() {
    if (selectedAccountType != null) {
      final selectedType = accountTypes.firstWhere(
        (type) => type['type'] == selectedAccountType,
      );
      final accountTypeTitle = selectedType['title'] as String;
      
      print('DEBUG: Account type selection - type: $selectedAccountType, title: $accountTypeTitle');
      
      Navigator.pushNamed(
        context,
        '/registration-screen',
        arguments: {'accountType': accountTypeTitle},
      );
    }
  }

  Color? _getSelectedAccentColor() {
    if (selectedAccountType == null) return null;

    final selectedType = accountTypes.firstWhere(
      (type) => type['type'] == selectedAccountType,
    );
    return selectedType['accentColor'] as Color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Logo Section
            const YnfnyLogoWidget(),

            // Account Information Section - Moved to top below YNFNY
            const ExplanationTextWidget(),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    // Account Type Cards
                    ...accountTypes.map((accountType) {
                      return AccountTypeCard(
                        title: accountType['title'] as String,
                        description: accountType['description'] as String,
                        iconName: accountType['iconName'] as String,
                        accentColor: accountType['accentColor'] as Color,
                        features: List<String>.from(accountType['features']),
                        verificationInfo:
                            accountType['verificationInfo'] as String,
                        isSelected: selectedAccountType == accountType['type'],
                        onTap: () =>
                            _selectAccountType(accountType['type'] as String),
                      );
                    }).toList(),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: ContinueButtonWidget(
                isEnabled: selectedAccountType != null,
                accentColor: _getSelectedAccentColor(),
                onPressed: _continueToRegistration,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
