import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:ynfny/utils/responsive_scale.dart';

import '../../../core/app_export.dart';
import '../../user_profile/user_profile.dart';
=======
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> performerData;
  final bool isFollowing;
  final VoidCallback onFollowTap;
<<<<<<< HEAD
  final String? currentUserId;
  final VoidCallback? onEditTap;
  final VoidCallback? onProfileUpdated;
  final VoidCallback? onAvatarTap;
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

  const ProfileHeaderWidget({
    super.key,
    required this.performerData,
    required this.isFollowing,
    required this.onFollowTap,
<<<<<<< HEAD
    this.currentUserId,
    this.onEditTap,
    this.onProfileUpdated,
    this.onAvatarTap,
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
<<<<<<< HEAD
              // Profile Avatar - Tappable if onAvatarTap provided
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryOrange,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      imageUrl: performerData["avatar"] as String? ?? "",
                      width: 20.w,
                      height: 20.w,
                      fit: BoxFit.cover,
                    ),
=======
              // Profile Avatar
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryOrange,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl: performerData["avatar"] as String? ?? "",
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.cover,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              // Profile Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
<<<<<<< HEAD
                    // Full Name
                    Text(
                      performerData["name"] as String? ?? "Unknown Performer",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Username handle
                    Text(
                      "@${performerData['username'] as String? ?? 'unknown'}",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    
                    SizedBox(height: 0.5.h),
                    
                    // Role Pill - SOLID orange background
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8C00),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatRole(performerData['role'] as String?),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 0.5.h),
                    
                    // Verification status below role pill
=======
                    Text(
                      performerData["name"] as String? ?? "Unknown Performer",
                      style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                    if (performerData["verificationStatus"] == "verified")
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'verified',
                            color: AppTheme.primaryOrange,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            "Verified Performer",
                            style: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                        ],
                      ),
                    if (performerData["verificationStatus"] == "pending")
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'schedule',
                            color: AppTheme.textSecondary,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            "Verification Pending",
                            style: AppTheme.darkTheme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Follow Button
              ElevatedButton(
                onPressed: onFollowTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing
                      ? AppTheme.darkTheme.colorScheme.surface
                      : AppTheme.primaryOrange,
                  foregroundColor: isFollowing
                      ? AppTheme.textPrimary
                      : AppTheme.backgroundDark,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: isFollowing
                        ? const BorderSide(color: AppTheme.borderSubtle)
                        : BorderSide.none,
                  ),
                ),
                child: Text(
                  isFollowing ? "Following" : "Follow",
                  style: AppTheme.darkTheme.textTheme.labelLarge,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
<<<<<<< HEAD
          // Stats Row with conditional Edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Supporters count (followers)
              Column(
                children: [
                  Text(
                    _formatCount(performerData["followersCount"] as int? ?? 0),
                    style: AppTheme.performerStatsStyle(isLight: false).copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    "Supporters",
                    style: AppTheme.darkTheme.textTheme.bodySmall,
                  ),
                ],
              ),
              SizedBox(width: 20),

              // Supporting count (following)
              Column(
                children: [
                  Text(
                    _formatCount(performerData["supportingCount"] as int? ?? 0),
                    style: AppTheme.performerStatsStyle(isLight: false).copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    "Supporting",
                    style: AppTheme.darkTheme.textTheme.bodySmall,
                  ),
                ],
              ),
              SizedBox(width: 20),

              // Videos count
              Column(
                children: [
                  Text(
                    (performerData["videoCount"] as int? ?? 0).toString(),
                    style: AppTheme.performerStatsStyle(isLight: false).copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    "Videos",
                    style: AppTheme.darkTheme.textTheme.bodySmall,
                  ),
                ],
              ),

              // Conditional Edit button (only show for current user's own profile)
              if (currentUserId != null && 
                  performerData["id"]?.toString() == currentUserId && 
                  onEditTap != null) ...[
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfile(userId: performerData["id"]),
                      ),
                    );
                    
                    // Trigger refresh of performer data when returning
                    if (result == true && onProfileUpdated != null) {
                      onProfileUpdated!();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF8C00), // Orange
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: Text(
                    "Edit",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          SizedBox(height: 2.h),
          // Performance Type Tags with Icons
=======
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn(
                "Videos",
                (performerData["videoCount"] as int? ?? 0).toString(),
              ),
              _buildStatColumn(
                "Followers",
                _formatCount(performerData["followersCount"] as int? ?? 0),
              ),
              _buildStatColumn(
                "Following",
                _formatCount(performerData["followingCount"] as int? ?? 0),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Performance Type Tags
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
          if (performerData["performanceTypes"] != null)
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: (performerData["performanceTypes"] as List)
                  .map((type) => Container(
                        padding: EdgeInsets.symmetric(
<<<<<<< HEAD
                            horizontal: 3.w, vertical: 0.8.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryOrange.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _getPerformanceIcon(type as String),
                            SizedBox(width: 1.w),
                            Text(
                              type,
                              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
=======
                            horizontal: 3.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                AppTheme.primaryOrange.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          type as String,
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.w500,
                          ),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                        ),
                      ))
                  .toList(),
            ),
<<<<<<< HEAD
          
          // Bio
          if (performerData["bio"] != null &&
              (performerData["bio"] as String).isNotEmpty) ...[
            SizedBox(height: 2.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                performerData["bio"] as String,
                style: AppTheme.darkTheme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
          if (performerData["frequentLocations"] != null) SizedBox(height: 1.h),
          // Frequent Locations
          if (performerData["frequentLocations"] != null)
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: (performerData["frequentLocations"] as List)
                  .take(3)
                  .map((location) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'location_on',
                            color: AppTheme.textSecondary,
                            size: 14,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            location as String,
                            style: AppTheme.darkTheme.textTheme.bodySmall,
                          ),
                        ],
                      ))
                  .toList(),
            ),
<<<<<<< HEAD
=======
          if (performerData["bio"] != null &&
              (performerData["bio"] as String).isNotEmpty)
            SizedBox(height: 2.h),
          // Bio
          if (performerData["bio"] != null &&
              (performerData["bio"] as String).isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                performerData["bio"] as String,
                style: AppTheme.darkTheme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.performerStatsStyle(isLight: false).copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return "${(count / 1000000).toStringAsFixed(1)}M";
    } else if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}K";
    }
    return count.toString();
  }
<<<<<<< HEAD

  String _formatRole(String? role) {
    if (role == null || role.isEmpty) return 'Street Performer';
    
    switch (role.toLowerCase()) {
      case 'street_performer':
      case 'performer':
        return 'Street Performer';
      case 'new_yorker':
      case 'newyorker':
        return 'New Yorker';
      case 'admin':
        return 'Admin';
      default:
        return 'Street Performer';
    }
  }

  Widget _getPerformanceIcon(String performanceType) {
    String emoji;
    switch (performanceType.toLowerCase()) {
      case 'music':
        emoji = '🎵';
        break;
      case 'dance':
        emoji = '💃';
        break;
      case 'visual arts':
        emoji = '🎨';
        break;
      case 'comedy':
        emoji = '🎭';
        break;
      case 'magic':
        emoji = '✨';
        break;
      case 'other':
        emoji = '⭐';
        break;
      default:
        emoji = '⭐';
    }
    
    return Text(
      emoji,
      style: TextStyle(
        fontSize: 16,
        height: 1.0,
      ),
    );
  }
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
}
