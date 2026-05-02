// ignore_for_file: deprecated_member_use, unused_field

import 'package:flutter/material.dart';
import 'package:market_world/features/realestate/models/property_model.dart';
import 'package:market_world/features/realestate/navigation/tenant_bottom_nav.dart';
import 'package:market_world/features/realestate/services/property_storage_service.dart';
import 'package:market_world/features/realestate/widgets/favorite_button.dart';
import 'package:market_world/features/storage/firebase_storage_service.dart';
import 'package:market_world/shared/widgets/property_skeleton.dart';

class PropertiesPage extends StatefulWidget {

  const PropertiesPage({
    super.key,
    this.focusPropertyId,
  });
  final String? focusPropertyId;

  @override
  State<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  final FirebaseStorageService _storage = FirebaseStorageService();
  final PropertyStorageService _service = PropertyStorageService();
  final String _searchText = '';
  String? get focusPropertyId => widget.focusPropertyId;

String? _cover(PropertyModel p) {
  if (p.mediaPaths.isNotEmpty) return p.mediaPaths.first;
  if (p.mainImage != null && p.mainImage!.isNotEmpty) return p.mainImage!;
  return null;
}

  int _crossAxisCount(double width) {
    if (width >= 1400) return 5;
    if (width >= 1100) return 4;
    if (width >= 800) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = _crossAxisCount(width);

    return Scaffold(
      appBar: AppBar(
        title: const Text('العقارات'),
      ),
      body: StreamBuilder<List<PropertyModel>>(
        stream: _service.searchProperties(
          keyword: _searchText.isEmpty ? null : _searchText,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeletonGrid(crossAxisCount);
          }

          final properties = snapshot.data ?? [];

          if (properties.isEmpty) {
            return const Center(child: Text('لا توجد عقارات'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: properties.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final p = properties[index];
              final cover = _cover(p);
              if (cover == null) return const SizedBox();

              return _PropertyGridItem(
                property: p,
                imagePath: cover,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSkeletonGrid(int crossAxisCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (_, __) => const PropertySkeleton(),
    );
  }
}

/// =======================================================
/// ================= PROPERTY CARD ========================
/// =======================================================
class PropertyCard extends StatelessWidget {

  const PropertyCard({required this.onTap, required this.image, required this.overlay, required this.body, super.key,
  });
  final VoidCallback onTap;
  final Widget image;
  final Widget overlay;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: image,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: overlay,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: body,
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// ================= GRID ITEM ============================
/// =======================================================
class _PropertyGridItem extends StatefulWidget {

  const _PropertyGridItem({
    required this.property,
    required this.imagePath,
  });
  final PropertyModel property;
  final String imagePath;

  @override
  State<_PropertyGridItem> createState() => _PropertyGridItemState();
}

class _PropertyGridItemState extends State<_PropertyGridItem> {
  final FirebaseStorageService _storage = FirebaseStorageService();
  String? _url;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final url = await _storage.resolveDownloadUrl(widget.imagePath);

      if (!mounted) return;

      setState(() => _url = url);

      await precacheImage(NetworkImage(url), context);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return PropertyCard(
      onTap: () {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => TenantBottomNav(
        focusPropertyId: widget.property.id,
      ),
    ),
    (route) => false,
  );
},


      image: _url == null
          ? ColoredBox(
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator()),
            )
          : Image.network(
              _url!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image)),
            ),

      overlay: FavoriteButton(propertyId: widget.property.id),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.property.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.property.price.toStringAsFixed(0)} ${widget.property.currency}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
