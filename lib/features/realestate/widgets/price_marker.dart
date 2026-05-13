// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';

class PriceMarker extends StatelessWidget {
  final String price;
  final bool selected;
  final bool isOwner;
  final bool isInsideRadius;
  final double zoom;

  const PriceMarker({
    super.key,
    required this.price,
    required this.selected,
    required this.isOwner,
    required this.isInsideRadius,
    required this.zoom,
  });

  @override
  Widget build(BuildContext context) {
    // =========================
    // Zoom Adaptive Scale
    // =========================

    final scale = (zoom / 14.5).clamp(0.72, 1.18);

    // =========================
    // Dynamic Sizes
    // =========================

    final horizontalPadding = selected ? 14.0 : 11.0;
    final verticalPadding = selected ? 8.0 : 6.0;

    final fontSize = selected ? 13.5 : 11.5;

    // =========================
    // Colors
    // =========================

    final Color backgroundColor = selected
        ? Colors.black
        : isOwner
            ? const Color(0xFF5B3FFF)
            : Colors.white;

    final Color textColor = selected || !isOwner
        ? Colors.white
        : Colors.black;

    final Color borderColor = selected
        ? Colors.white.withOpacity(.15)
        : Colors.black.withOpacity(.06);

    // =========================
    // Glow
    // =========================

    final glowColor = selected
        ? Colors.black.withOpacity(.22)
        : Colors.black.withOpacity(.10);

    return Transform.scale(
      scale: scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // =========================
          // 🔥 Pulse Glow
          // =========================

          if (selected)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: .95, end: 1.18),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(.08),
                    ),
                  ),
                );
              },
            ),

          // =========================
          // 💎 Luxury Marker
          // =========================

          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(.96),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: selected ? 22 : 10,
                  spreadRadius: selected ? 1 : 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 8,
                  sigmaY: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // =========================
                    // 🏠 Icon
                    // =========================

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: selected
                          ? Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.home_rounded,
                                key: const ValueKey('icon'),
                                size: 14,
                                color: textColor,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // =========================
                    // 💰 Price
                    // =========================

                    Text(
                      price,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: fontSize,
                        letterSpacing: .15,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // =========================
          // 📍 Outside Radius Fade
          // =========================

          if (!isInsideRadius)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: Colors.white.withOpacity(.55),
                ),
              ),
            ),
        ],
      ),
    );
  }
}