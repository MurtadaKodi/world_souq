import 'package:flutter/material.dart';

class PriceMarker extends StatelessWidget {
  final String price;
  final bool selected;
  final bool isOwner;
  final bool isInsideRadius;
  final String? distanceText;
  final double zoom;

  const PriceMarker({
    super.key,
    required this.price,
    required this.selected,
    this.isOwner = false,
    this.isInsideRadius = true,
    this.distanceText,
    required this.zoom,
  });
  
  @override
Widget build(BuildContext context) {
  double calculateZoomScale(double zoom) {
  if (zoom < 9) return 0.7;
  if (zoom < 11) return 0.85;
  if (zoom < 13) return 1.0;
  if (zoom < 15) return 1.15;
  return 1.3;
}
  final bool isFar = zoom < 11;
  final bool isMedium = zoom >= 11 && zoom < 14;
  final zoomScale = calculateZoomScale(zoom);
  // ignore: unused_local_variable
  final bool isClose = zoom >= 14;

  Color backgroundColor;

  if (isOwner) {
    backgroundColor = Colors.green;
  } else if (!isInsideRadius) {
    backgroundColor = Colors.grey;
  } else {
    backgroundColor = Colors.blue;
  }

  /// 🔵 FAR ZOOM → نقطة فقط
  if (isFar) {
    return Transform.scale(
      scale: zoomScale,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
        ),
      
    );
  }

  /// 🟡 MEDIUM ZOOM → سعر صغير
  if (isMedium) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        price,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 🔴 CLOSE ZOOM → كامل
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Text(
          price,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
      ),
    ],
  );
}
}