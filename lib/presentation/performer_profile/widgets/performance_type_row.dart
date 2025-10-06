import 'package:flutter/material.dart';
import '../../../core/app_export.dart';

class PerformanceTypeRow extends StatelessWidget {
  final List<String> performanceTypes;

  const PerformanceTypeRow({
    super.key,
    required this.performanceTypes,
  });

  @override
  Widget build(BuildContext context) {
    if (performanceTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: performanceTypes.map((type) {
          final iconData = _getIconForType(type);
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8C00).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFF8C00),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  iconData,
                  color: const Color(0xFFFF8C00),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconForType(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('music')) {
      return Icons.music_note;
    } else if (lowerType.contains('dance')) {
      return Icons.directions_run;
    } else if (lowerType.contains('visual') || lowerType.contains('art')) {
      return Icons.brush;
    } else if (lowerType.contains('comedy')) {
      return Icons.theater_comedy;
    } else if (lowerType.contains('magic')) {
      return Icons.auto_awesome;
    } else {
      return Icons.star;
    }
  }
}
