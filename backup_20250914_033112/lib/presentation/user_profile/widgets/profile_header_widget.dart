import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onAvatarTap;
  final bool isCurrentUserProfile;
  final VoidCallback? onEditTap;

  const ProfileHeaderWidget({
    super.key,
    required this.userData,
    required this.onAvatarTap,
    required this.isCurrentUserProfile,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: AppTheme.glassmorphismDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryOrange,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      imageUrl: userData["avatar"] as String? ?? "",
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData["name"] as String? ?? "Unknown User",
                      style: AppTheme.darkTheme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: (userData["accountType"] as String? ??
                                    "new_yorker") ==
                                "performer"
                            ? AppTheme.primaryOrange.withOpacity( 0.2)
                            : AppTheme.accentRed.withOpacity( 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (userData["accountType"] as String? ??
                                      "new_yorker") ==
                                  "performer"
                              ? AppTheme.primaryOrange
                              : AppTheme.accentRed,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        (userData["accountType"] as String? ?? "new_yorker") ==
                                "performer"
                            ? "Street Performer"
                            : "New Yorker",
                        style:
                            AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                          color: (userData["accountType"] as String? ??
                                      "new_yorker") ==
                                  "performer"
                              ? AppTheme.primaryOrange
                              : AppTheme.accentRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
