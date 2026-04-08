// ignore_for_file: unused_field, prefer_single_quotes

import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:market_world/features/realestate/models/property_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:market_world/features/realestate/services/favorites_service.dart';
import 'package:market_world/features/storage/firebase_storage_service.dart';


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
  List<String> _resolvedImages = [];
  bool _loadingImages = true;
  final FavoritesService _favoritesService = FavoritesService();
  final PageController _controller = PageController();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  late final Set<Polyline> polylines;
  final Set<Circle> circles = {};
  String? _distanceText;
  LatLng? _userLatLng;

  int _currentIndex = 0;
  double _dragOffset = 0;
  final double _dragThreshold = 120; // مقدار السحب للإغلاق

  @override
  void initState() {
    super.initState();
    _initLocationData();
    _loadImages(); // 👈 جديد
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
  Future<void> _loadImages() async {
    final images = _images;

    final urls = await Future.wait(
      images.map((e) => _storageService.resolveDownloadUrl(e)),
    );

    setState(() {
      _resolvedImages = urls;
      _loadingImages = false;
    });
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
        polylines = {
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

        polylines = {
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

  // ignore: unused_element
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
                  child: CustomScrollView(
                slivers: [
                  /// ================= IMAGE (PARALLAX) =================
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    backgroundColor: Colors.black,
                    leading: const SizedBox(), // نستخدم زرنا الخاص

                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          /// IMAGE SLIDER
                          _loadingImages
                              ? const Center(child: CircularProgressIndicator())
                              : PageView.builder(
                                  controller: _controller,
                                  itemCount: _resolvedImages.length,
                                  physics:
                                      const NeverScrollableScrollPhysics(), // 🔥 يسمح بالسحب مهم جداً
                                  onPageChanged: (i) =>
                                      setState(() => _currentIndex = i),
                                  itemBuilder: (_, index) {
                                    final image = _resolvedImages[index];

                                    return Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        /// 🖼️ IMAGE
                                        Hero(
                                          tag: image,
                                          child: Image.network(
                                            image,
                                            fit: BoxFit.cover,
                                          ),
                                        ),

                                        /// 🔍 BUTTON (الحل الاحترافي)
                                        Positioned(
                                          right: 16,
                                          bottom: 16,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      FullScreenGallery(
                                                    images: _resolvedImages,
                                                    initialIndex: index,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.fullscreen,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                          /// GRADIENT
                          Container(
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

                          /// TITLE (يظهر مع collapse)
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Text(
                              widget.property.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          /// FAVORITE + SHARE
                          Positioned(
                            top: 60,
                            left: 20,
                            right: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// BACK
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    child: Icon(Icons.arrow_back,
                                        color: Colors.white),
                                  ),
                                ),

                                Row(
                                  children: [
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
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isFav
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isFav
                                                  ? Colors.red
                                                  : Colors.black,
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    /// FAVORITE (نفس كودك)
                                    // انسخ نفس StreamBuilder هنا

                                    const SizedBox(width: 10),

                                    /// SHARE
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.share),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// ================= DETAILS =================
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// PRICE
                          Text(
                            '${widget.property.price.toStringAsFixed(0)} ${widget.property.currency}',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.redAccent),
                          ),

                          const SizedBox(height: 10),

                          /// DISTANCE
                          if (_distanceText != null)
                            Text(
                              'يبعد $_distanceText عنك',
                              style: const TextStyle(color: Colors.blue),
                            ),

                          const SizedBox(height: 10),

                          /// LOCATION
                          Text(
                            '${widget.property.city} - ${widget.property.area}',
                            style: const TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 20),

                          /// DESCRIPTION
                          const Text(
                            'الوصف',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(widget.property.description),

                          const SizedBox(height: 30),

                          /// MINI MAP (نضيفه في الخطوة القادمة 👇)
                        ],
                      ),
                    ),
                  ),
                ],
              )),

              /// CLOSE BUTTON

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

class _FavoriteButton extends StatelessWidget {
  final String propertyId;
  final FavoritesService service;

  const _FavoriteButton({
    required this.propertyId,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: service.isFavorite(propertyId),
      builder: (_, snapshot) {
        final isFav = snapshot.data ?? false;

        return _CircleButton(
          icon: isFav ? Icons.favorite : Icons.favorite_border,
          onTap: () {
            isFav
                ? service.removeFromFavorites(propertyId)
                : service.addToFavorites(propertyId);
          },
        );
      },
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: Colors.black54,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

// ignore: unused_element
class _HeaderSliver extends StatelessWidget {
  final List<String> images;
  final bool loading;
  final PageController controller;
  final int currentIndex;
  final Function(int) onPageChanged;
  final PropertyModel property;
  final FavoritesService favoritesService;

  const _HeaderSliver({
    required this.images,
    required this.loading,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
    required this.property,
    required this.favoritesService,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            /// IMAGES
            loading
                ? const Center(child: CircularProgressIndicator())
                : PageView.builder(
                    physics: const BouncingScrollPhysics(),
                    controller: controller,
                    itemCount: images.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (_, index) {
                      final image = images[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullScreenGallery(
                                images: images,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: image,
                          child: Image.network(
                            image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),

            /// GRADIENT
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),

            /// TOP ACTIONS
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      _FavoriteButton(
                        propertyId: property.id,
                        service: favoritesService,
                      ),
                      const SizedBox(width: 10),
                      const _CircleButton(icon: Icons.share),
                    ],
                  ),
                ],
              ),
            ),

            /// DOTS
            Positioned(
              bottom: 10,
              child: Row(
                children: List.generate(
                  images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: currentIndex == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentIndex == i ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: widget.initialIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            itemBuilder: (_, index) {
              final image = widget.images[index];

              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Hero(
                    tag: image,
                    child: Image.network(image),
                  ),
                ),
              );
            },
          ),

          /// CLOSE
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
