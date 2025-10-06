import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class ContextMenuWidget extends StatefulWidget {
  final VoidCallback? onSave;
  final VoidCallback? onReport;
  final VoidCallback? onNotInterested;
  final VoidCallback? onClose;

  const ContextMenuWidget({
    Key? key,
    this.onSave,
    this.onReport,
    this.onNotInterested,
    this.onClose,
  }) : super(key: key);

  @override
  State<ContextMenuWidget> createState() => _ContextMenuWidgetState();
}

class _ContextMenuWidgetState extends State<ContextMenuWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      widget.onClose?.call();
    });
  }

  void _handleAction(VoidCallback? action) {
    _animationController.reverse().then((_) {
      action?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleClose,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.backgroundDark.withOpacity( 0.8),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 280,
                    decoration: AppTheme.glassmorphismDecoration(
                      backgroundColor: AppTheme.surfaceDark,
                      borderRadius: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Options',
                                style: AppTheme.darkTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: _handleClose,
                                child: CustomIconWidget(
                                  iconName: 'close',
                                  color: AppTheme.textSecondary,
                                  size: AppSpacing.lg,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        Container(
                          height: 1,
                          color: AppTheme.borderSubtle,
                        ),

                        // Menu items
                        _buildMenuItem(
                          icon: 'bookmark_border',
                          title: 'Save Video',
                          subtitle: 'Add to your saved collection',
                          onTap: () => _handleAction(widget.onSave),
                        ),

                        _buildMenuItem(
                          icon: 'report',
                          title: 'Report',
                          subtitle: 'Report inappropriate content',
                          onTap: () => _handleAction(widget.onReport),
                          isDestructive: true,
                        ),

                        _buildMenuItem(
                          icon: 'visibility_off',
                          title: 'Not Interested',
                          subtitle: 'See fewer videos like this',
                          onTap: () => _handleAction(widget.onNotInterested),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? AppTheme.accentRed.withOpacity( 0.1)
                        : AppTheme.borderSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: icon,
                    color: isDestructive
                        ? AppTheme.accentRed
                        : AppTheme.textPrimary,
                    size: AppSpacing.lg,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: isDestructive
                              ? AppTheme.accentRed
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle,
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.textSecondary,
                  size: AppSpacing.lg,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            color: AppTheme.borderSubtle,
          ),
      ],
    );
  }
}
