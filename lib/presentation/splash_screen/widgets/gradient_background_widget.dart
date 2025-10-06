import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class GradientBackgroundWidget extends StatelessWidget {
  final Widget child;

  const GradientBackgroundWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.backgroundDark,
<<<<<<< HEAD
            AppTheme.backgroundDark.withOpacity(0.9),
=======
            AppTheme.backgroundDark.withValues(alpha: 0.9),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
            const Color(0xFF2C3E2D), // Muted green tone
            const Color(0xFF3D2F1F), // Bronze tone
            AppTheme.backgroundDark,
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Colors.transparent,
<<<<<<< HEAD
              AppTheme.backgroundDark.withOpacity(0.3),
              AppTheme.backgroundDark.withOpacity(0.7),
=======
              AppTheme.backgroundDark.withValues(alpha: 0.3),
              AppTheme.backgroundDark.withValues(alpha: 0.7),
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}
