// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool primary;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onPressed,
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: primary
              ? const LinearGradient(
                  colors: [
                    Color(0xFF2196F3),
                    Color(0xFF0D47A1),
                  ],
                )
              : null,
          color: primary ? null : Colors.white.withOpacity(0.08),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ]
              : [],
          border: Border.all(
            color: Colors.white.withOpacity(primary ? 0.0 : 0.25),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: primary ? Colors.white : Colors.white10,
              fontSize: primary ? 16 : 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
