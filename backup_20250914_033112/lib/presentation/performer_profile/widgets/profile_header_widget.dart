import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> performerData;
  final bool isFollowing;
  final VoidCallback onFollowTap;
  final bool isCurrentUserProfile;
  final VoidCallback? onEditTap;

  const ProfileHeaderWidget({
    super.key,
    required this.performerData,
    required this.isFollowing,
    required this.onFollowTap,
    required this.isCurrentUserProfile,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
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
              // Profile Avatar
              Container(
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
                    imageUrl: performerData["avatar"] as String? ?? "",
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // Profile Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      performerData["name"] as String? ?? "Unknown Performer",
                      style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    if (performerData["verificationStatus"] == "verified")
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'verified',
                            color: AppTheme.primaryOrange,
                            size: 16,
                          ),
                          SizedBox(width: AppSpacing.xxs),
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
                          SizedBox(width: AppSpacing.xxs),
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
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
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
          SizedBox(height: AppSpacing.xs),
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
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatColumn(
                      "Following",
                      _formatCount(performerData["followingCount"] as int? ?? 0),
                    ),
                    if (isCurrentUserProfile && onEditTap != null) ...[
                      SizedBox(width: AppSpacing.xs),
                      GestureDetector(
                        onTap: onEditTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryOrange,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            "Edit",
                            style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.primaryOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          // Performance Type Tags
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xxs,
            children: (performerData["performanceTypes"] as List?)?.isNotEmpty == true
                ? (performerData["performanceTypes"] as List)
                    .map((type) => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryOrange.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            type as String,
                            style:
                                AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList()
                : [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.textSecondary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        "Not set",
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
          ),
          // Borough Location (universal field)
          SizedBox(height: AppSpacing.xxs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: AppTheme.primaryOrange,
                size: 14,
              ),
              SizedBox(width: AppSpacing.xxs),
              Text(
                (performerData["borough"] as String?)?.isEmpty != false 
                  ? "Not set"
                  : performerData["borough"] as String,
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: (performerData["borough"] as String?)?.isEmpty != false 
                    ? AppTheme.textSecondary
                    : AppTheme.textPrimary,
                  fontStyle: (performerData["borough"] as String?)?.isEmpty != false 
                    ? FontStyle.italic 
                    : FontStyle.normal,
                ),
              ),
            ],
          ),
          if (performerData["bio"] != null &&
              (performerData["bio"] as String).isNotEmpty)
            SizedBox(height: AppSpacing.xs),
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
        SizedBox(height: 2),
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
}
