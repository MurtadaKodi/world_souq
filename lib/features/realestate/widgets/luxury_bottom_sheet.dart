import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import 'property_details_sheet.dart';

class LuxuryBottomSheet extends StatelessWidget {
  final PropertyModel property;

  const LuxuryBottomSheet({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Glass Blur Background
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(color: Colors.black.withOpacity(0.2)),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 20),
            width: width > 900 ? width * 0.7 : width * 0.95,
            height: width > 900 ? 420 : 500,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 30,
                ),
              ],
            ),
            child: PropertyDetailsSheet(
              property: property,
              onBook: () {},
            ),
          ),
        ),
      ],
    );
  }
}