// Disabled: import package:camera
import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';
import '../../../theme/app_theme.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController? cameraController;
  final bool showGrid;
  final VoidCallback? onTapToFocus;
  final Offset? focusPoint;

  const CameraPreviewWidget({
    super.key,
    this.cameraController,
    required this.showGrid,
    this.onTapToFocus,
    this.focusPoint,
  });

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.backgroundDark,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.primaryOrange,
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Initializing Camera...',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTapUp: (details) {
        if (onTapToFocus != null) {
          onTapToFocus!();
        }
      },
      child: Stack(
        children: [
          // Camera preview
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CameraPreview(cameraController!),
          ),

          // Grid overlay
          if (showGrid)
            CustomPaint(
              size: Size(double.infinity, double.infinity),
              painter: GridPainter(),
            ),

          // Focus indicator
          if (focusPoint != null)
            Positioned(
              left: focusPoint!.dx - 25,
              top: focusPoint!.dy - 25,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryOrange,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textPrimary.withOpacity( 0.3)
      ..strokeWidth = 1;

    // Vertical lines
    final verticalSpacing = size.width / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(verticalSpacing * i, 0),
        Offset(verticalSpacing * i, size.height),
        paint,
      );
    }

    // Horizontal lines
    final horizontalSpacing = size.height / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(0, horizontalSpacing * i),
        Offset(size.width, horizontalSpacing * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
