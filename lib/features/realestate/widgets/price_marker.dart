// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class PriceMarker extends StatelessWidget {

  const PriceMarker({
    required this.price, required this.selected, required this.isOwner, required this.isInsideRadius, required this.zoom, super.key,
  });
  final String price;
  final bool selected;
  final bool isOwner;
  final bool isInsideRadius;
  final double zoom;

  @override
Widget build(BuildContext context) {
  final scale = (zoom / 14).clamp(0.85, 1.35);

  final bgColor = selected
      ? Colors.black
      : isOwner
          ? Colors.deepPurple
          : Colors.white;

  final textColor = selected || !isOwner
      ? Colors.white
      : Colors.black;

  final borderColor = selected
      ? Colors.black
      : Colors.grey.shade300;

  return Transform.scale(
    scale: scale,
    child: Stack(
      alignment: Alignment.center,
      children: [
        /// 🔥 Pulse Effect (أنعم)
        if (selected)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.2),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bgColor.withOpacity(0.15),
                  ),
                ),
              );
            },
          ),

        /// 💎 Luxury Marker
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: borderColor,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: selected ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🏠 Icon (اختياري)
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.home_rounded,
                    size: 14,
                    color: textColor,
                  ),
                ),

              /// 💰 Price
              Text(
                price,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: selected ? 15 : 13,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}