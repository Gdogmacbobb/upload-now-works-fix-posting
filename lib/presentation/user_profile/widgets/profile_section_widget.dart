import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

class ProfileSectionWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Function(String) onItemTap;

  const ProfileSectionWidget({
    super.key,
    required this.title,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
<<<<<<< HEAD
      margin: EdgeInsets.only(bottom: 16.0),
=======
      margin: EdgeInsets.only(bottom: 2.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
      decoration: AppTheme.performerCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
<<<<<<< HEAD
            padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
=======
            padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
            child: Text(
              title,
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
<<<<<<< HEAD
              color: AppTheme.borderSubtle.withOpacity(0.3),
              height: 1,
              indent: 16.0,
              endIndent: 16.0,
=======
              color: AppTheme.borderSubtle.withValues(alpha: 0.3),
              height: 1,
              indent: 4.w,
              endIndent: 4.w,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                contentPadding:
<<<<<<< HEAD
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                leading: CustomIconWidget(
                  iconName: item["icon"] as String,
                  color: AppTheme.textSecondary,
                  size: 24.0,
=======
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
                leading: CustomIconWidget(
                  iconName: item["icon"] as String,
                  color: AppTheme.textSecondary,
                  size: 6.w,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                ),
                title: Text(
                  item["title"] as String,
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                subtitle: item["subtitle"] != null
                    ? Text(
                        item["subtitle"] as String,
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      )
                    : null,
                trailing: item["showBadge"] == true
                    ? Container(
<<<<<<< HEAD
                        width: 8.0,
                        height: 8.0,
=======
                        width: 2.w,
                        height: 2.w,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                        decoration: const BoxDecoration(
                          color: AppTheme.accentRed,
                          shape: BoxShape.circle,
                        ),
                      )
                    : CustomIconWidget(
                        iconName: 'chevron_right',
                        color: AppTheme.textSecondary,
<<<<<<< HEAD
                        size: 20.0,
=======
                        size: 5.w,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                      ),
                onTap: () => onItemTap(item["route"] as String? ?? ""),
              );
            },
          ),
        ],
      ),
    );
  }
}
