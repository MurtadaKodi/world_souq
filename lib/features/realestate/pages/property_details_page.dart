// ignore_for_file: unused_field, prefer_single_quotes

import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:market_world/features/realestate/models/property_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:market_world/features/realestate/services/favorites_service.dart';
import 'package:market_world/features/realestate/widgets/google_map.dart';
import 'package:market_world/features/storage/firebase_storage_service.dart';
import 'package:flutter/foundation.dart';

class PropertyDetailsFullScreen extends StatefulWidget {
  final PropertyModel property;
  final VoidCallback? onNavigate;
  final VoidCallback onClose;

  final VoidCallback onBook;

  const PropertyDetailsFullScreen({
    super.key,
    required this.property,
    this.onNavigate,
    required this.onBook,
    required this.onClose,
  });

  @override
  State<PropertyDetailsFullScreen> createState() =>
      _PropertyDetailsFullScreenState();
}

class _PropertyDetailsFullScreenState extends State<PropertyDetailsFullScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final PageController _controller = PageController();
  final FirebaseStorageService _storageService = FirebaseStorageService();

  String? _distanceText;
  LatLng? _userLatLng;
  Set<Polyline> _polylines = {};
  int _currentIndex = 0;
  double _dragOffset = 0;
  final double _dragThreshold = 120; // مقدار السحب للإغلاق

  @override
  void initState() {
    super.initState();
    _initLocationData();
  }

  List<String> get _images {
    // ignore: duplicate_ignore
    // ignore: prefer_single_quotes
    debugPrint("MEDIA PATHS FROM FIRESTORE:");
    debugPrint(widget.property.mediaPaths.toString());
    debugPrint("MAIN IMAGE:");
    debugPrint(widget.property.mainImage.toString());

    if (widget.property.mediaPaths.isNotEmpty) {
      return widget.property.mediaPaths;
    }
    debugPrint('IMAGE URL: ${widget.property.mainImage}');
    if (widget.property.mainImage?.isNotEmpty == true) {
      return [widget.property.mainImage!];
    }

    return const [];
  }

  // ignore: unused_element
  Future<void> _loadRoutePreview() async {
    if (widget.property.lat == null || widget.property.lng == null) {
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();

      final user = LatLng(position.latitude, position.longitude);

      final property = LatLng(widget.property.lat!, widget.property.lng!);

      setState(() {
        _userLatLng = user;
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [user, property],
            color: Colors.blue,
            width: 4,
          ),
        };
      });
    } catch (_) {}
  }

  Future<void> _initLocationData() async {
    if (widget.property.lat == null || widget.property.lng == null) return;

    try {
      final position = await Geolocator.getCurrentPosition();

      final user = LatLng(position.latitude, position.longitude);
      final property = LatLng(widget.property.lat!, widget.property.lng!);

      final distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.property.lat!,
        widget.property.lng!,
      );

      final km = distanceInMeters / 1000;

      setState(() {
        _userLatLng = user;
        _distanceText = km < 1
            ? '${distanceInMeters.toStringAsFixed(0)} متر'
            : '${km.toStringAsFixed(1)} كم';

        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [user, property],
            color: Colors.blue,
            width: 4,
          ),
        };
      });
    } catch (_) {}
  }

  GestureTapCallback? get _shareProperty => null;

  // // ignore: unused_field
  // double _dragOffset = 0;
  // const double _dragThreshold = 140;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    // نسبة السحب (0 → 1)
    final double dragPercent = (_dragOffset / screenHeight).clamp(0.0, 1.0);

    // تصغير الصفحة تدريجيًا
    final double scale = 1 - (dragPercent * 0.08);

    // شفافية الخلفية
    final double backgroundOpacity = 0.6 - (dragPercent * 0.5);

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta != null && details.primaryDelta! > 0) {
          setState(() {
            _dragOffset += details.primaryDelta!;
          });
        }
      },
      onVerticalDragEnd: (_) {
        if (_dragOffset > _dragThreshold) {
          Navigator.pop(context);
        } else {
          setState(() => _dragOffset = 0);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..translate(0.0, _dragOffset)
          ..scale(scale),
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(backgroundOpacity),
          body: Stack(
            children: [
              /// =========================
              /// BACKGROUND BLUR
              /// =========================
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),

              /// =========================
              /// CONTENT
              /// =========================
              SafeArea(
                child: Column(
                  children: [
                    /// IMAGE CAROUSEL
                    SizedBox(
                      height: 280,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned(
                            bottom: 20,
                            left: 50,
                            right: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // ❤️ Favorite
                                StreamBuilder<bool>(
                                  stream: _favoritesService
                                      .isFavorite(widget.property.id),
                                  builder: (context, snapshot) {
                                    final isFav = snapshot.data ?? false;

                                    return GestureDetector(
                                      onTap: () async {
                                        if (isFav) {
                                          await _favoritesService
                                              .removeFromFavorites(
                                                  widget.property.id);
                                        } else {
                                          await _favoritesService
                                              .addToFavorites(
                                                  widget.property.id);
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          shape: BoxShape.circle,
                                        ),
                                        child: AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          transitionBuilder:
                                              (child, animation) {
                                            return ScaleTransition(
                                              scale: CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutBack,
                                              ),
                                              child: child,
                                            );
                                          },
                                          child: Icon(
                                            isFav
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            key: ValueKey(isFav),
                                            color: isFav
                                                ? Colors.red
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // 🔗 Share
                                GestureDetector(
                                  onTap: _shareProperty,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.share),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 340,
                            child: PageView.builder(
                              controller: _controller,
                              itemCount: _images.length,
                              onPageChanged: (i) =>
                                  setState(() => _currentIndex = i),
                              itemBuilder: (_, index) {
                                final path = _images[index];

                                return FutureBuilder<String>(
                                  future:
                                      _storageService.resolveDownloadUrl(path),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    final downloadUrl = snapshot.data!;

                                    return Hero(
                                      tag: downloadUrl,
                                      child: Image.network(
                                        downloadUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                                child: Icon(Icons.error)),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),

                          /// Gradient Overlay
                          Container(
                            height: 100,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black54,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          /// Dots
                          Positioned(
                            bottom: 15,
                            child: Row(
                              children: List.generate(
                                _images.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentIndex == index ? 18 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentIndex == index
                                        ? Colors.white
                                        : Colors.white54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// DETAILS
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.property.title,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.property.price.toStringAsFixed(0)} ${widget.property.currency}',
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.redAccent),
                                  ),
                                  const SizedBox(height: 6),
                                  _distanceText != null
                                      ? Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 16,
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'يبعد $_distanceText عنك',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.blue,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${widget.property.city} - ${widget.property.area}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'الوصف',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(widget.property.description),
                              const SizedBox(height: 24),
                              if (!kIsWeb &&
                                  widget.property.lat != null &&
                                  widget.property.lng != null) ...[
                                const Text(
                                  'الموقع',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: SizedBox(
                                    height: 180,
                                    child: Stack(
                                      children: [
                                        const SizedBox(height: 24),

                                        if (widget.property.lat != null &&
                                            widget.property.lng != null) ...[
                                          const Text(
                                            'الاتجاه إلى الموقع',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: SizedBox(
                                              height: 180,
                                              child: Stack(
                                                children: [
                                                  // Google Map
                                                  PropertyGoogleMap(
                                                    initialCameraPosition:
                                                        CameraPosition(
                                                      target: LatLng(
                                                          widget.property.lat!,
                                                          widget.property.lng!),
                                                      zoom: 15,
                                                    ),
                                                    property: widget.property,
                                                    userLatLng: _userLatLng,
                                                    polylines: _polylines,
                                                  ),
                                                  Positioned.fill(
                                                    child: GestureDetector(
                                                      onTap: widget.onNavigate,
                                                      child: Container(
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],

                                        // 👇 طبقة شفافة للضغط
                                        Positioned.fill(
                                          child: GestureDetector(
                                            onTap: widget.onNavigate,
                                            child: Container(
                                                color: Colors.transparent),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// CLOSE BUTTON
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 💰 السعر
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.property.price.toStringAsFixed(0)} ${widget.property.currency}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'السعر الإجمالي',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 📅 زر الحجز
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: widget.onBook,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'حجز موعد',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: imageUrl,
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
