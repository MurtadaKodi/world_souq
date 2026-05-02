import 'package:flutter/material.dart';

class ClusterMarker extends StatelessWidget {

  const ClusterMarker({
    required this.count, required this.zoom, super.key,
  });
  final int count;
  final double zoom;

  double _scale() {
    if (zoom < 10) return 0.7;
    if (zoom < 12) return 0.9;
    if (zoom < 14) return 1.1;
    return 1.3;
  }

  double _opacity() {
    if (zoom > 15) return 0; // fade out
    if (zoom < 10) return 1;
    return 1.0 - ((zoom - 10) / 5);
  }

  @override
  Widget build(BuildContext context) {
    final color = count > 20
        ? Colors.red
        : count > 10
            ? Colors.orange
            : Colors.blue;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _opacity(),
      child: Transform.scale(
        scale: _scale(),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8),
            ],
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}