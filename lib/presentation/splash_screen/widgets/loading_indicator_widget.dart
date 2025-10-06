import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class LoadingIndicatorWidget extends StatefulWidget {
  final String loadingText;

  const LoadingIndicatorWidget({
    Key? key,
    this.loadingText = 'Initializing...',
  }) : super(key: key);

  @override
  State<LoadingIndicatorWidget> createState() => _LoadingIndicatorWidgetState();
}

class _LoadingIndicatorWidgetState extends State<LoadingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Custom loading indicator with NYC street aesthetic
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Container(
<<<<<<< HEAD
                width: 32.0,
                height: 32.0,
=======
                width: 8.w,
                height: 8.w,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.borderSubtle,
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Orange accent arc
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        value: 0.3,
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryOrange,
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    // Red accent dot
                    Positioned(
<<<<<<< HEAD
                      top: 2.0,
                      left: 14.0,
                      child: Container(
                        width: 4.0,
                        height: 4.0,
=======
                      top: 0.5.w,
                      left: 3.5.w,
                      child: Container(
                        width: 1.w,
                        height: 1.w,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                        decoration: BoxDecoration(
                          color: AppTheme.accentRed,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
<<<<<<< HEAD
                              color: AppTheme.accentRed.withOpacity(0.6),
=======
                              color: AppTheme.accentRed.withValues(alpha: 0.6),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
<<<<<<< HEAD
        SizedBox(height: 24.0),
=======
        SizedBox(height: 3.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
        // Loading text with typing animation
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final dots = '.' * ((_animationController.value * 3).floor() + 1);
            return Text(
              '${widget.loadingText}$dots',
              style: GoogleFonts.inter(
<<<<<<< HEAD
                fontSize: 14.0,
=======
                fontSize: 14.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            );
          },
        ),
      ],
    );
  }
}