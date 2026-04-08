import 'package:flutter/material.dart';
import 'package:market_world/features/realestate/navigation/tenant_bottom_nav.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';
import './property_details_page.dart';

class PropertiesListPage extends StatelessWidget {
  const PropertiesListPage({super.key});

@override
Widget build(BuildContext context) {
  final service = PropertyService();
  return Scaffold(
      appBar: AppBar(
        title: const Text('العقارات'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<PropertyModel>>(
        stream: service.streamAllProperties(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final properties = snapshot.data!;

          if (properties.isEmpty) {
            return const Center(child: Text('لا توجد عقارات حالياً'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return _PropertyCard(property: property);
            },
          );
        },
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final PropertyModel property;

  const _PropertyCard({required this.property});

  /// 🔹 Method لفتح شاشة التفاصيل
  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailsFullScreen(
          property: property,

          // 🔥 إغلاق التفاصيل
          onClose: () {
            Navigator.pop(context);
          },

          // 🔥 الانتقال إلى الخريطة مع تركيز
          onNavigate: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => TenantBottomNav(
                  initialIndex: 0,
                  focusPropertyId: property.id,
                ),
              ),
              (route) => false,
            );
          },

          // 🔥 الانتقال إلى صفحة الحجز
          onBook: () {
            Navigator.pushNamed(
              context,
              '/booking',
              arguments: property.id,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openDetails(context), // 👈 استخدام الميثود
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
ClipRRect(
  borderRadius: const BorderRadius.vertical(
    top: Radius.circular(16),
  ),
  child: Image.network(
    (property.imageUrls?.isNotEmpty ?? false)
        ? property.imageUrls!.first
        : (property.mainImage ?? ''),
    height: 180,
    width: double.infinity,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) =>
        const Center(child: Icon(Icons.image)),
  ),
),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    property.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${property.price} ر.ق',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${property.city} - ${property.area}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
