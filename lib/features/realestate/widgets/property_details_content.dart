import 'package:flutter/material.dart';
import '../models/property_model.dart';

class PropertyDetailsContent extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onBook;

  const PropertyDetailsContent({
    super.key,
    required this.property,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            property.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${property.price.toStringAsFixed(0)} ${property.currency}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${property.city} - ${property.area}',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'الوصف',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(property.description),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: onBook,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('حجز موعد'),
          ),
        ],
      ),
    );
  }
}