// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



Future<BitmapDescriptor> createLuxuryMarker({
  required String price,
  required double zoom,
  bool selected = false,
  double floatingOffset = 0,
  double bounceScale = 1,
}) async {
  // =========================
  // Canvas Setup
  // =========================

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  const width = 170.0;
  const height = 120.0;

  final scale =
    ((zoom / 15).clamp(0.75, 1.18)) * bounceScale;

  // =========================
  // Dynamic Colors
  // =========================

  final bgGradient = selected
      ? const LinearGradient(
          colors: [
            Color(0xFF111111),
            Color(0xFF2B2B2B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [
            Color(0xFF6A11CB),
            Color(0xFF2575FC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  // =========================
  // Shadow
  // =========================

  final shadowPaint = Paint()
    ..color = Colors.black.withOpacity(.28)
    ..maskFilter = const MaskFilter.blur(
      BlurStyle.normal,
      22,
    );

  // =========================
  // Main Bubble
  // =========================

  final bubbleRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(15, 15, width - 30, 58),
    const Radius.circular(28),
  );

  // Shadow
  canvas.drawRRect(
    bubbleRect.shift(
  Offset(0, 8 + floatingOffset),
),
    shadowPaint,
  );

  // Main Paint
  final mainPaint = Paint()
    ..shader = bgGradient.createShader(
      const Rect.fromLTWH(0, 0, width, height),
    );

  canvas.drawRRect(bubbleRect, mainPaint);

  // =========================
  // Glass Highlight
  // =========================

  final glassPaint = Paint()
    ..color = Colors.white.withOpacity(.12);

  final glassRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(22, 22, width - 44, 20),
    const Radius.circular(18),
  );

  canvas.drawRRect(glassRect.shift(Offset(0, floatingOffset)), glassPaint);

  // =========================
  // Tail
  // =========================

  final tailPath = Path();

  tailPath.moveTo(width / 2 - 12, 70);
  tailPath.lineTo(width / 2 + 12, 70);
  tailPath.lineTo(width / 2, 96);
  tailPath.close();

  canvas.drawPath(tailPath, mainPaint);

  // =========================
  // Glow Ring (Selected)
  // =========================

  if (selected) {
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(.10)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        30,
      );

    canvas.drawCircle(
      const Offset(width / 2, 44),
      42,
      glowPaint,
    );
  }

  // =========================
  // Price Text
  // =========================

  final textPainter = TextPainter(
    text: TextSpan(
      text: price,
      style: TextStyle(
        color: Colors.white,
        fontSize: selected ? 20 : 17,
        fontWeight: FontWeight.w800,
        letterSpacing: -.2,
      ),
    ),
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();

  textPainter.paint(
    canvas,
    Offset(
      (width - textPainter.width) / 2,
      29,
    ),
  );

  // =========================
  // Selected Dot
  // =========================

  if (selected) {
    final dotPaint = Paint()
      ..color = Colors.white;

    canvas.drawCircle(
      const Offset(width / 2, 103),
      4.5,
      dotPaint,
    );
  }

  // =========================
  // Convert To Image
  // =========================

  final picture = recorder.endRecording();

  final image = await picture.toImage(
    (width * scale).toInt(),
    (height * scale).toInt(),
  );

  final bytes = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );

  return BitmapDescriptor.fromBytes(
    bytes!.buffer.asUint8List(),
  );
}