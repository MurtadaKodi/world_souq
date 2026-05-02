// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> createLuxuryMarker({
  required String price,
  required double zoom,
  bool selected = false,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  const width = 180.0;
  const height = 175.0;

  final scale = (zoom / 14).clamp(0.7, 1.1);

  const rect = Rect.fromLTWH(0, 0, width, height);

  // 🎨 Gradient
  final paint = Paint()
    ..shader = const LinearGradient(
      colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
    ).createShader(rect);

  // 🟣 Shadow
  final shadowPaint = Paint()
    ..color = Colors.black.withOpacity(0.3)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

  final rrect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(10, 10, width - 20, height - 40),
    const Radius.circular(30),
  );

  // Shadow
  canvas.drawRRect(rrect.shift(const Offset(0, 4)), shadowPaint);

  // Bubble
  canvas.drawRRect(rrect, paint);

  // 🔻 Tail
  final path = Path();
  path.moveTo(width / 2 - 10, height - 40);
  path.lineTo(width / 2 + 10, height - 40);
  path.lineTo(width / 2, height - 10);
  path.close();

  canvas.drawPath(path, paint);

  // 💰 Text
  final textPainter = TextPainter(
    text: TextSpan(
      text: price,
      style: TextStyle(
        color: Colors.white,
        fontSize: selected ? 24 : 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();

  textPainter.paint(
    canvas,
    Offset(
      (width - textPainter.width) / 2,
      (height - 40 - textPainter.height) / 2,
    ),
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(
    (width * scale).toInt(),
    (height * scale).toInt(),
  );

  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
}