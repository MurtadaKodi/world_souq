import 'package:flutter/material.dart';

class PropertySkeleton extends StatelessWidget {
  const PropertySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // TITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              height: 14,
              width: double.infinity,
              color: Colors.grey.shade300,
            ),
          ),

          const SizedBox(height: 6),

          // PRICE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              height: 12,
              width: 80,
              color: Colors.grey.shade300,
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
