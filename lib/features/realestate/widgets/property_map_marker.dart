// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

enum PropertyStatus { sale, rent, sold }

class RealEstateMapMarker extends StatelessWidget {

  const RealEstateMapMarker({
    required this.price, required this.imageUrl, required this.status, super.key,
    this.selected = false,
  });
  final String price;
  final String imageUrl;
  final PropertyStatus status;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = selected
        ? theme.primaryColor
        : (isDark ? Colors.grey.shade900 : Colors.white);

    final textColor = selected
        ? Colors.white
        : (isDark ? Colors.white : Colors.black87);

    return AnimatedScale(
      scale: selected ? 1.18 : 1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🏷 Status Badge
          _buildStatusBadge(),

          const SizedBox(height: 4),

          // 🏠 Main Bubble
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                      selected ? 0.35 : 0.18,),
                  blurRadius: selected ? 22 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🖼 Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 8),

                // 💰 Price
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),

          // 🔻 Pointer
          CustomPaint(
            size: const Size(20, 12),
            painter: _TrianglePainter(color: bgColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;

    switch (status) {
      case PropertyStatus.sale:
        color = Colors.green;
        label = 'For Sale';
      case PropertyStatus.rent:
        color = Colors.blue;
        label = 'For Rent';
      case PropertyStatus.sold:
        color = Colors.red;
        label = 'Sold';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 3,),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {

  _TrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawShadow(path, Colors.black26, 4, true);

    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}