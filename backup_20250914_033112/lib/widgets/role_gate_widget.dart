import 'package:flutter/material.dart';

import '../core/app_export.dart';
import '../models/user_profile.dart';
import '../services/role_service.dart';
import '../services/supabase_service.dart';

/// Widget that conditionally renders content based on user role permissions
class RoleGate extends StatefulWidget {
  /// The child widget to show when user has permission
  final Widget child;
  
  /// List of roles that are allowed to see the content
  final List<UserRole>? allowedRoles;
  
  /// List of performer features required to see the content
  final List<PerformerFeature>? requiredFeatures;
  
  /// Widget to show when user doesn't have permission (optional)
  final Widget? fallback;
  
  /// Whether to show an info message for restricted content
  final bool showInfoMessage;
  
  /// Custom info message to show when content is restricted
  final String? customInfoMessage;
  
  /// Whether to completely hide the content (vs showing disabled state)
  final bool hideWhenRestricted;

  const RoleGate({
    Key? key,
    required this.child,
    this.allowedRoles,
    this.requiredFeatures,
    this.fallback,
    this.showInfoMessage = false,
    this.customInfoMessage,
    this.hideWhenRestricted = false,
  }) : super(key: key);

  /// Constructor for performer-only features
  RoleGate.performerOnly({
    Key? key,
    required Widget child,
    Widget? fallback,
    bool showInfoMessage = false,
    String? customInfoMessage,
    bool hideWhenRestricted = false,
  }) : this(
          key: key,
          child: child,
          allowedRoles: [UserRole.streetPerformer, UserRole.admin],
          fallback: fallback,
          showInfoMessage: showInfoMessage,
          customInfoMessage: customInfoMessage,
          hideWhenRestricted: hideWhenRestricted,
        );

  /// Constructor for admin users only
  RoleGate.adminOnly({
    Key? key,
    required Widget child,
    Widget? fallback,
    bool showInfoMessage = false,
    String? customInfoMessage,
    bool hideWhenRestricted = false,
  }) : this(
          key: key,
          child: child,
          allowedRoles: [UserRole.admin],
          fallback: fallback,
          showInfoMessage: showInfoMessage,
          customInfoMessage: customInfoMessage,
          hideWhenRestricted: hideWhenRestricted,
        );

  /// Constructor for New Yorker users only
  RoleGate.newYorkerOnly({
    Key? key,
    required Widget child,
    Widget? fallback,
    bool showInfoMessage = false,
    String? customInfoMessage,
    bool hideWhenRestricted = false,
  }) : this(
          key: key,
          child: child,
          allowedRoles: [UserRole.newYorker, UserRole.admin],
          fallback: fallback,
          showInfoMessage: showInfoMessage,
          customInfoMessage: customInfoMessage,
          hideWhenRestricted: hideWhenRestricted,
        );

  /// Constructor for authenticated users only
  RoleGate.authenticated({
    Key? key,
    required Widget child,
    Widget? fallback,
    bool showInfoMessage = false,
    String? customInfoMessage,
    bool hideWhenRestricted = false,
  }) : this(
          key: key,
          child: child,
          allowedRoles: [UserRole.streetPerformer, UserRole.newYorker, UserRole.admin],
          fallback: fallback,
          showInfoMessage: showInfoMessage,
          customInfoMessage: customInfoMessage,
          hideWhenRestricted: hideWhenRestricted,
        );

  /// Constructor requiring any of multiple features
  RoleGate.requiresAnyFeature({
    Key? key,
    required Widget child,
    required List<PerformerFeature> features,
    Widget? fallback,
    bool showInfoMessage = false,
    String? customInfoMessage,
    bool hideWhenRestricted = false,
  }) : this(
          key: key,
          child: child,
          requiredFeatures: features,
          fallback: fallback,
          showInfoMessage: showInfoMessage,
          customInfoMessage: customInfoMessage,
          hideWhenRestricted: hideWhenRestricted,
        );

  /// Constructor for specific performer features
  RoleGate.requiresFeature({
    Key? key,
    required Widget child,
    required PerformerFeature feature,
    Widget? fallback,
    bool showInfoMessage = false,
    String? customInfoMessage,
    bool hideWhenRestricted = false,
  }) : this(
          key: key,
          child: child,
          requiredFeatures: [feature],
          fallback: fallback,
          showInfoMessage: showInfoMessage,
          customInfoMessage: customInfoMessage,
          hideWhenRestricted: hideWhenRestricted,
        );

  @override
  State<RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<RoleGate> {
  final RoleService _roleService = RoleService.instance;

  @override
  void initState() {
    super.initState();
    _initializeRole();
    _roleService.addListener(_onRoleChanged);
  }

  @override
  void dispose() {
    _roleService.removeListener(_onRoleChanged);
    super.dispose();
  }

  void _onRoleChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initializeRole() async {
    if (!_roleService.isInitialized) {
      await _roleService.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state while role is being determined
    if (_roleService.isLoading || 
        (!_roleService.isInitialized && _requiresAuthentication())) {
      return widget.hideWhenRestricted 
        ? const SizedBox.shrink()
        : _buildLoadingPlaceholder();
    }
    
    final hasPermission = _checkPermission(_roleService);
    
    if (hasPermission) {
      return widget.child;
    }
    
    // User doesn't have permission
    if (widget.hideWhenRestricted) {
      return const SizedBox.shrink();
    }
    
    if (widget.fallback != null) {
      return widget.fallback!;
    }
    
    if (widget.showInfoMessage) {
      return _buildInfoMessage(context, _roleService);
    }
    
    // Default: show disabled overlay
    return _buildDisabledOverlay(context, _roleService);
  }

  /// Check if this gate requires authentication
  bool _requiresAuthentication() {
    return widget.allowedRoles != null || widget.requiredFeatures != null;
  }

  /// Build loading placeholder while role is being determined
  Widget _buildLoadingPlaceholder() {
    return Container(
      height: 48, // Reasonable default height
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryOrange.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  /// Check if user has required permissions
  bool _checkPermission(RoleService roleService) {
    // Check role-based permissions
    if (widget.allowedRoles != null) {
      if (roleService.currentUserRole == null) return false;
      if (!widget.allowedRoles!.contains(roleService.currentUserRole)) return false;
    }
    
    // Check feature-based permissions (requires ANY of the features for requiresAnyFeature)
    if (widget.requiredFeatures != null) {
      // For single feature requirement, all features must be available
      // For multiple features (requiresAnyFeature), at least one must be available
      if (widget.requiredFeatures!.length == 1) {
        // Single feature requirement - must have this specific feature
        if (!roleService.hasPermission(widget.requiredFeatures!.first)) return false;
      } else {
        // Multiple features - user needs at least one (ANY logic)
        bool hasAnyFeature = false;
        for (final feature in widget.requiredFeatures!) {
          if (roleService.hasPermission(feature)) {
            hasAnyFeature = true;
            break;
          }
        }
        if (!hasAnyFeature) return false;
      }
    }
    
    return true;
  }

  /// Build info message for restricted content
  Widget _buildInfoMessage(BuildContext context, RoleService roleService) {
    final message = widget.customInfoMessage ?? _getDefaultInfoMessage(roleService);
    
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      margin: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'info',
            color: AppTheme.primaryOrange,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build disabled overlay for restricted content
  Widget _buildDisabledOverlay(BuildContext context, RoleService roleService) {
    return Stack(
      children: [
        // Faded version of the original widget
        Opacity(
          opacity: 0.4,
          child: IgnorePointer(child: widget.child),
        ),
        // Overlay with info
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.darkTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryOrange,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'lock',
                      color: AppTheme.primaryOrange,
                      size: 16,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      _getRestrictedMessage(roleService),
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Get default info message based on role restrictions
  String _getDefaultInfoMessage(RoleService roleService) {
    if (widget.customInfoMessage != null) return widget.customInfoMessage!;
    
    if (widget.allowedRoles?.contains(UserRole.streetPerformer) == true && 
        widget.allowedRoles != null && !widget.allowedRoles!.contains(UserRole.newYorker)) {
      return 'This feature is available for Street Performers only. Upgrade your account to access performer tools.';
    }
    
    if (widget.requiredFeatures?.contains(PerformerFeature.uploadVideo) == true ||
        widget.requiredFeatures?.contains(PerformerFeature.recordVideo) == true) {
      return 'Video upload and recording are exclusive to Street Performers. Join as a performer to share your talent!';
    }
    
    return 'This feature requires different account permissions. Contact support for more information.';
  }

  /// Get restricted message for overlay
  String _getRestrictedMessage(RoleService roleService) {
    if (widget.allowedRoles?.contains(UserRole.streetPerformer) == true && 
        widget.allowedRoles != null && !widget.allowedRoles!.contains(UserRole.newYorker)) {
      return 'Performer Only';
    }
    
    if (widget.requiredFeatures?.isNotEmpty == true) {
      return 'Permission Required';
    }
    
    return 'Restricted';
  }
}

/// Widget for showing upgrade prompt to New Yorkers
class UpgradePromptWidget extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onUpgrade;

  const UpgradePromptWidget({
    Key? key,
    this.title = 'Become a Street Performer',
    this.description = 'Upgrade your account to upload videos, edit your profile, and showcase your talent to the NYC community.',
    this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      margin: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryOrange.withOpacity(0.1),
            AppTheme.primaryOrange.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'star',
            color: AppTheme.primaryOrange,
            size: 32,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            description,
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onUpgrade != null) ...[
            SizedBox(height: AppSpacing.sm),
            ElevatedButton(
              onPressed: onUpgrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: 1.20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Upgrade Account',
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}