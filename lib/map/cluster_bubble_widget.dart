import 'package:flutter/material.dart';

double getClusterSize(int count) {
  if (count < 10) return 70;
  if (count < 50) return 90;
  return 110;
}

Color getClusterColor(int count) {
  if (count < 10) return Colors.orange;
  if (count < 50) return Colors.redAccent;
  return Colors.deepPurple;
}

class ClusterBubbleWidget extends StatefulWidget {
  final int count;
  final bool highlight;
  final double zoom;

  const ClusterBubbleWidget({
    super.key,
    required this.count,
    required this.highlight,
    required this.zoom,
  });

  @override
  State<ClusterBubbleWidget> createState() => _ClusterBubbleWidgetState();
}

class _ClusterBubbleWidgetState extends State<ClusterBubbleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = getClusterSize(widget.count);
    final color = getClusterColor(widget.count);
    final zoomScale = _calculateZoomScale(widget.zoom);

    return Transform.scale(
      scale: zoomScale,
      child: ScaleTransition(
        scale: _controller,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(widget.highlight ? 0.9 : 0.5),
                blurRadius: widget.highlight ? 25 : 12,
                spreadRadius: widget.highlight ? 6 : 2,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  double _calculateZoomScale(double zoom) {
    if (zoom < 9) return 0.8;
    if (zoom < 11) return 0.9;
    if (zoom < 13) return 1.0;
    if (zoom < 15) return 1.1;
    return 1.2;
  }
}
