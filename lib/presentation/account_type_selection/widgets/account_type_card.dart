import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'package:ynfny/utils/responsive_scale.dart';
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

class AccountTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconName;
  final Color accentColor;
  final List<String> features;
  final String verificationInfo;
  final bool isSelected;
  final VoidCallback onTap;

  const AccountTypeCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconName,
    required this.accentColor,
    required this.features,
    required this.verificationInfo,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 25.h,
<<<<<<< HEAD
=======
          maxHeight: 35.h,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
        ),
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
<<<<<<< HEAD
              ? accentColor.withOpacity(0.1)
=======
              ? accentColor.withValues(alpha: 0.1)
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : AppTheme.borderSubtle,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
<<<<<<< HEAD
                  ? accentColor.withOpacity(0.2)
=======
                  ? accentColor.withValues(alpha: 0.2)
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  : AppTheme.shadowDark,
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
<<<<<<< HEAD
                      color: accentColor.withOpacity(0.2),
=======
                      color: accentColor.withValues(alpha: 0.2),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: iconName,
                      color: accentColor,
                      size: 6.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style:
                              AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                            color:
                                isSelected ? accentColor : AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          description,
<<<<<<< HEAD
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
=======
                          style:
                              AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
<<<<<<< HEAD
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features:',
                    style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ...features.map((feature) => Padding(
                    padding: EdgeInsets.only(bottom: 0.5.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 0.5.h),
                          width: 1.w,
                          height: 1.w,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
=======
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features:',
                      style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Expanded(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: features.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 0.5.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 0.5.h),
                                  width: 1.w,
                                  height: 1.w,
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    features[index],
                                    style: AppTheme
                                        .darkTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              ),
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
<<<<<<< HEAD
                  color: AppTheme.backgroundDark.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.borderSubtle.withOpacity(0.3),
=======
                  color: AppTheme.backgroundDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.borderSubtle.withValues(alpha: 0.3),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info_outline',
                      color: AppTheme.textSecondary,
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        verificationInfo,
<<<<<<< HEAD
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
=======
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 10.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
