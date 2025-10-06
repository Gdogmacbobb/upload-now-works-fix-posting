import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onAvatarTap;

  const ProfileHeaderWidget({
    super.key,
    required this.userData,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
<<<<<<< HEAD
      padding: EdgeInsets.all(16.0),
=======
      padding: EdgeInsets.all(4.w),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
      decoration: AppTheme.glassmorphismDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
<<<<<<< HEAD
                  width: 80.0,
                  height: 80.0,
=======
                  width: 20.w,
                  height: 20.w,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
                      width: 80.0,
                      height: 80.0,
=======
                      width: 20.w,
                      height: 20.w,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
<<<<<<< HEAD
              SizedBox(width: 16.0),
=======
              SizedBox(width: 4.w),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
                    SizedBox(height: 8.0),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
=======
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 0.5.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                      decoration: BoxDecoration(
                        color: (userData["accountType"] as String? ??
                                    "new_yorker") ==
                                "performer"
<<<<<<< HEAD
                            ? AppTheme.primaryOrange.withOpacity(0.2)
                            : AppTheme.accentRed.withOpacity(0.2),
=======
                            ? AppTheme.primaryOrange.withValues(alpha: 0.2)
                            : AppTheme.accentRed.withValues(alpha: 0.2),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
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
<<<<<<< HEAD
          SizedBox(height: 16.0),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Supporters count (followers)
              Column(
                children: [
                  Text(
                    _formatCount(userData["followersCount"] as int? ?? 0),
                    style: AppTheme.performerStatsStyle(isLight: false).copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    "Supporters",
                    style: AppTheme.darkTheme.textTheme.bodySmall,
                  ),
                ],
              ),

              // Supporting count (following)
              Column(
                children: [
                  Text(
                    _formatCount(userData["supportingCount"] as int? ?? 0),
                    style: AppTheme.performerStatsStyle(isLight: false).copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    "Supporting",
                    style: AppTheme.darkTheme.textTheme.bodySmall,
                  ),
                ],
              ),

              // Videos count
              Column(
                children: [
                  Text(
                    (userData["videoCount"] as int? ?? 0).toString(),
                    style: AppTheme.performerStatsStyle(isLight: false).copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    "Videos",
                    style: AppTheme.darkTheme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
        ],
      ),
    );
  }
<<<<<<< HEAD

  String _formatCount(int count) {
    if (count >= 1000000) {
      return "${(count / 1000000).toStringAsFixed(1)}M";
    } else if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}K";
    }
    return count.toString();
  }
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
}
