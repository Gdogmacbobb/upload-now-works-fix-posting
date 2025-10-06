import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
<<<<<<< HEAD
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../../core/app_export.dart';

class AnimatedLogoWidget extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const AnimatedLogoWidget({
    Key? key,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<AnimatedLogoWidget> createState() => _AnimatedLogoWidgetState();
}

class _AnimatedLogoWidgetState extends State<AnimatedLogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimation();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimation() {
    _animationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onAnimationComplete?.call();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
<<<<<<< HEAD
            width: 320.0,
=======
            width: 80.w,
            height: 35.h,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentRed
<<<<<<< HEAD
                      .withOpacity(_glowAnimation.value * 0.4),
=======
                      .withValues(alpha: _glowAnimation.value * 0.4),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 5 * _glowAnimation.value,
                ),
              ],
            ),
            child: Column(
<<<<<<< HEAD
              mainAxisSize: MainAxisSize.min,
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // YNFNY Logo Image - Made bigger
                Container(
<<<<<<< HEAD
                  width: 280.0, // Fixed width
                  height: 224.0, // Fixed height
=======
                  width: 70.w, // Increased from 60.w to 70.w
                  height: 28.h, // Increased from 25.h to 28.h
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentRed
<<<<<<< HEAD
                            .withOpacity(_glowAnimation.value * 0.6),
=======
                            .withValues(alpha: _glowAnimation.value * 0.6),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                        blurRadius: 15 * _glowAnimation.value,
                        spreadRadius: 2 * _glowAnimation.value,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/YNFNY_Logo-1753709879889.png',
<<<<<<< HEAD
                      width: 280.0, // Fixed width
                      height: 224.0, // Fixed height
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 280.0, // Fixed width
                          height: 224.0, // Fixed height
=======
                      width: 70.w, // Increased from 60.w to 70.w
                      height: 28.h, // Increased from 25.h to 28.h
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 70.w, // Increased from 60.w to 70.w
                          height: 28.h, // Increased from 25.h to 28.h
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'account_balance',
                                color: AppTheme.backgroundDark,
<<<<<<< HEAD
                                size: 60.0,
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                'YNFNY',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18.0,
=======
                                size: 15.w,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'YNFNY',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.backgroundDark,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
<<<<<<< HEAD
                    height: 24.0), // Fixed height to push text down
=======
                    height: 3.h), // Increased from 2.h to 3.h to push text down
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                // Added "You Are Not From New York" text in orange
                Text(
                  'You Are Not From New York',
                  style: GoogleFonts.inter(
                    color: AppTheme.primaryOrange,
<<<<<<< HEAD
                    fontSize: 14.0,
=======
                    fontSize: 14.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ).copyWith(
                    color: Color(0XFFFF8C00),
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    height: 1.43,
                    letterSpacing: 1,
                    wordSpacing: 0,
                  ),
                  textAlign: TextAlign.center,
                ),
<<<<<<< HEAD
                SizedBox(height: 16.0),
=======
                SizedBox(height: 2.h),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                // WE OUTSIDE Text
                Text(
                  'WE OUTSIDE',
                  style: GoogleFonts.inter(
<<<<<<< HEAD
                    fontSize: 10.0,
=======
                    fontSize: 10.sp,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
