import 'package:flutter/material.dart';

class DebugOverlayWidget extends StatelessWidget {
  final String routeName;
  final String platform;

  const DebugOverlayWidget({
    Key? key,
    required this.routeName,
    required this.platform,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;
    final viewPadding = mediaQuery.viewPadding;
    final viewInsets = mediaQuery.viewInsets;

    return Positioned(
      top: 50,
      left: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          border: Border.all(color: Colors.yellow, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('DEBUG OVERLAY', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 10)),
            const SizedBox(height: 4),
            Text('Route: $routeName', style: const TextStyle(color: Colors.white, fontSize: 9)),
            Text('Platform: $platform', style: const TextStyle(color: Colors.white, fontSize: 9)),
            const SizedBox(height: 4),
            Text('MQ.padding.top: ${padding.top.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 9)),
            Text('MQ.padding.bottom: ${padding.bottom.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 9)),
            Text('viewPadding.top: ${viewPadding.top.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 9)),
            Text('viewInsets.top: ${viewInsets.top.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 9)),
            Text('viewInsets.bottom: ${viewInsets.bottom.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 9)),
            Text('Size: ${mediaQuery.size.width.toStringAsFixed(0)}x${mediaQuery.size.height.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class RedStripeWidget extends StatelessWidget {
  const RedStripeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 2,
        color: Colors.red.withOpacity(0.7),
      ),
    );
  }
}
