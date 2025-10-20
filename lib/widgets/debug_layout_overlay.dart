import 'package:flutter/material.dart';
import 'package:ynfny/utils/responsive_scale.dart';

class DebugLayoutOverlay extends StatelessWidget {
  final double headerTop;
  final double iconsBottom;
  final double captionBottom;
  final double fabBottom;
  final bool visible;

  const DebugLayoutOverlay({
    Key? key,
    required this.headerTop,
    required this.iconsBottom,
    required this.captionBottom,
    required this.fabBottom,
    this.visible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final screenHeight = MediaQuery.of(context).size.height;

    return IgnorePointer(
      child: Stack(
        children: [
          // Header guide line (ORANGE)
          Positioned(
            top: headerTop,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: Colors.orange.withOpacity(0.8),
            ),
          ),
          Positioned(
            top: headerTop + 5,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'HEADER: ${headerTop.toStringAsFixed(1)}px',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Icons baseline guide line (CYAN)
          Positioned(
            bottom: iconsBottom,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: Colors.cyan.withOpacity(0.8),
            ),
          ),
          Positioned(
            bottom: iconsBottom + 5,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ICONS: ${iconsBottom.toStringAsFixed(1)}px',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Caption baseline guide line (PINK)
          Positioned(
            bottom: captionBottom,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: Colors.pink.withOpacity(0.8),
            ),
          ),
          Positioned(
            bottom: captionBottom + 5,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'CAPTION: ${captionBottom.toStringAsFixed(1)}px',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // FAB baseline guide line (LIME)
          Positioned(
            bottom: fabBottom,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: Colors.lime.withOpacity(0.8),
            ),
          ),
          Positioned(
            bottom: fabBottom + 5,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.lime.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'FAB: ${fabBottom.toStringAsFixed(1)}px',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Screen info overlay
          Positioned(
            top: 100,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Screen: ${screenHeight.toStringAsFixed(0)}px',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Top Padding: ${MediaQuery.of(context).padding.top.toStringAsFixed(1)}px',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
