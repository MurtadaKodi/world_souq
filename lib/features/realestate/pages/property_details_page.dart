// ignore_for_file: duplicate_ignore, deprecated_member_use, unused_field, prefer_single_quotes

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:market_world/features/realestate/models/property_model.dart';
import 'package:market_world/features/realestate/services/favorites_service.dart';
import 'package:market_world/features/realestate/widgets/booking_dialog.dart';
import 'package:market_world/features/realestate/widgets/property_mini_map_ultra.dart';
import 'package:market_world/features/realestate/widgets/simple_photo_view.dart';
import 'package:market_world/features/storage/firebase_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyDetailsFullScreen extends StatefulWidget {
  const PropertyDetailsFullScreen({
    required this.property,
    required this.onBook,
    required this.onClose,
    super.key,
    this.onNavigate,
  });
  final PropertyModel property;
  final VoidCallback? onNavigate;
  final VoidCallback onClose;
  final VoidCallback onBook;

  @override
  State<PropertyDetailsFullScreen> createState() => _PropertyDetailsFullScreenState();
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
  TapDownDetails? _doubleTapDetails;
  final TransformationController transformationController = TransformationController();
  bool _isZoomed = false;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _initLocationData();
    _loadImages();

    _startAutoSlide();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startAutoSlide();
    } else if (state == AppLifecycleState.paused) {
      _autoSlideTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    transformationController.dispose(); // 🔥 مهم جداً
    super.dispose();
  }

  List<String> get _images {
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

  Future<void> _loadImages() async {
    final images = _images;

    final urls = await Future.wait(
      images.map(_storageService.resolveDownloadUrl),
    );
    for (final url in urls) {
      // ignore: use_build_context_synchronously
      precacheImage(NetworkImage(url), context);
    }
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
        _distanceText =
            km < 1 ? '${distanceInMeters.toStringAsFixed(0)} متر' : '${km.toStringAsFixed(1)} كم';

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
    final screenHeight = MediaQuery.of(context).size.height;

    // نسبة السحب (0 → 1)
    final dragPercent = (_dragOffset / screenHeight).clamp(0.0, 1.0);

    // تصغير الصفحة تدريجيًا
    final scale = 1 - (dragPercent * 0.12);

    // شفافية الخلفية

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        // ❌ تجاهل إذا zoom
        if (_isZoomed) return;
        // 🔥 إذا السحب أفقي → تجاهله (خلي PageView يشتغل)
        if (details.delta.dx.abs() > details.delta.dy.abs()) {
          return;
        }

        // 🔥 إذا المستخدم يكبر الصورة → تجاهل
        if (_controller.hasClients &&
            _controller.page != null &&
            (_controller.page! - _currentIndex).abs() > 0.01) {
          return;
        }
        if (_isZoomed) return;

        // ✅ سحب عمودي فقط
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
        child: ClipRRect(
           borderRadius: BorderRadius.circular(28),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                /// =========================
                /// BACKGROUND BLUR
                /// =========================
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.25),
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
                              /// ================= IMAGES =================
                              if (_loadingImages)
                                const Center(child: CircularProgressIndicator())
                              else
                                PageView.builder(
                                  controller: _controller,
                                  itemCount: _resolvedImages.length,
                                  physics: _isZoomed
                                      ? const NeverScrollableScrollPhysics()
                                      : const BouncingScrollPhysics(),
                                  onPageChanged: (i) {
                                    setState(() {
                                      _currentIndex = i;
                                      _isZoomed = false;
                                      transformationController.value = Matrix4.identity();
                                    });
          
                                    _autoSlideTimer?.cancel();
                                    _startAutoSlide();
                                  },
                                  itemBuilder: (_, index) {
                                    final image = _resolvedImages[index];
                                    return Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        /// 🖼️ IMAGE (FIXED)
                                        Hero(
                                          tag: image,
                                          child: GestureDetector(
                                            child: Image.network(
                                              image,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
          
                                        /// 🔍 FULLSCREEN BUTTON
                                        Positioned(
                                          right: 16,
                                          bottom: 16,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => SimplePhotoView(
                                                    images: _resolvedImages,
                                                    initialIndex: index,
                                                  ),
                                                ),
                                              );
                                            },
                                            // child: Container(
                                            //   padding: const EdgeInsets.all(10),
                                            //   decoration: BoxDecoration(
                                            //     color: Colors.black
                                            //         .withOpacity(0.6),
                                            //     shape: BoxShape.circle,
                                            //   ),
                                            //   child: const Icon(
                                            //     Icons.fullscreen,
                                            //     color: Colors.white,
                                            //   ),
                                            // ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
          
                              /// ================= DOTS =================
                              if (_resolvedImages.length > 1)
                                Positioned(
                                  bottom: 12,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      _resolvedImages.length,
                                      (i) => AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        width: _currentIndex == i ? 20 : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _currentIndex == i ? Colors.white : Colors.white54,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
          
                              /// ================= GRADIENT =================
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
                            ],
                          ),
                        ),
                      ),
          
                      /// ================= DETAILS =================
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// DISTANCE
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (_distanceText != null)
                                    Text(
                                      Localizations.localeOf(context).languageCode == 'ar'
                                          ? 'يبعد $_distanceText عنك'
                                          : '$_distanceText away from you',
                                      style: const TextStyle(color: Colors.white),
                                    ),
          
                                  const SizedBox(width: 120),
          
                                  /// LOCATION
                                  Text(
                                    '${widget.property.city} - ${widget.property.area}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
          
                                  const SizedBox(height: 20),
                                ],
                              ),
          
                              /// DESCRIPTION
                              Center(
                                child: Text(
                                  Localizations.localeOf(context).languageCode == 'ar'
                                      ? 'الوصف'
                                      : 'Description',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Center(
                                  child: Text(
                                widget.property.description,
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                              )),
          
                              const SizedBox(height: 30),
          
                              /// 👤 OWNER INFO
                              if (widget.property.ownerName.isNotEmpty ||
                                  widget.property.ownerPhone.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Localizations.localeOf(context).languageCode == 'ar'
                                            ? 'معلومات المالك'
                                            : 'Owner Info',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
          
                                      const SizedBox(height: 10),
          
                                      /// 👤 Name
                                      if (widget.property.ownerName.isNotEmpty)
                                        Row(
                                          children: [
                                            const Icon(Icons.person, size: 18, color: Colors.white),
                                            const SizedBox(width: 6),
                                            Text(widget.property.ownerName, style: const TextStyle(color: Colors.white)),
                                          ],
                                        ),
          
                                      const SizedBox(height: 8),
          
                                      /// 📞 Phone
                                      if (widget.property.ownerPhone.isNotEmpty)
                                        Row(
                                          children: [
                                            const Icon(Icons.phone, size: 18, color: Colors.green),
                                            const SizedBox(width: 6),
                                            Text(widget.property.ownerPhone,
                                                style: const TextStyle(color: Colors.green)),
                                          ],
                                        ),
          
                                      const SizedBox(height: 12),
          
                                      /// ☎️ Call Button
                                      if (widget.property.ownerPhone.isNotEmpty)
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              final uri =
                                                  Uri.parse('tel:${widget.property.ownerPhone}');
                                              // ignore: use_build_context_synchronously
                                              await launchUrl(uri);
                                            },
                                            icon: const Icon(Icons.call),
                                            label: Text(
                                              Localizations.localeOf(context).languageCode == 'ar'
                                                  ? 'اتصال مباشر'
                                                  : 'Call Now',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                side: const BorderSide(color: Colors.white30),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                      if (widget.property.ownerPhone.isNotEmpty)
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: () async {
                                              var phone = widget.property.ownerPhone
                                                  .replaceAll(RegExp(r'[^0-9]'), '');
          
                                              // قطر: إذا الرقم 8 أرقام نضيف 974
                                              if (phone.length == 8) {
                                                phone = '974$phone';
                                              }
          
                                              final message = Uri.encodeComponent(
                                                'مرحباً، أنا مهتم بالعقار: ${widget.property.title}',
                                              );
          
                                              final uri =
                                                  Uri.parse('https://wa.me/$phone?text=$message');
          
                                              await launchUrl(
                                                uri,
                                                mode: LaunchMode.externalApplication,
                                              );
                                            },
                                            icon: const Icon(Icons.chat),
                                            label: Text(
                                              Localizations.localeOf(context).languageCode == 'ar'
                                                  ? 'تواصل واتساب'
                                                  : 'WhatsApp',
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.green,
                                              side: const BorderSide(color: Colors.white30),
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
          
                              /// MINI MAP (👇)
                              if (widget.property.lat != null && widget.property.lng != null)
                                PropertyMiniMapUltra(
                                  const SizedBox(),
                                  lat: widget.property.lat!,
                                  lng: widget.property.lng!,
                                  title:
                                      // ignore: dead_null_aware_expression
                                      widget.property.title ?? 'Property Location',
                                ),
                                                                const SizedBox(height: 90),
          
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          
                /// CLOSE BUTTON
                Positioned(
                  top: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: widget.onClose,
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
                          blurRadius: 1,
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
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                Localizations.localeOf(context).languageCode == 'ar'
                                    ? 'السعر الإجمالي'
                                    : 'Total Price',
                                style: const TextStyle(
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
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => BookingDialog(
                                  property: widget.property,
                                  propertyId: widget.property.id,
                                  propertyName: widget.property.title,
                                  ownerId: widget.property.ownerId,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              Localizations.localeOf(context).languageCode == 'ar'
                                  ? 'حجز موعد'
                                  : 'Book Appointment',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        if (_isZoomed || _resolvedImages.isEmpty) return;

        final next = (_currentIndex + 1) % _resolvedImages.length;

        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.propertyId,
    required this.service,
  });
  final String propertyId;
  final FavoritesService service;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: service.isFavorite(propertyId),
      builder: (_, snapshot) {
        final isFav = snapshot.data ?? false;

        return _CircleButton(
          icon: isFav ? Icons.favorite : Icons.favorite_border,
          onTap: () {
            isFav ? service.removeFromFavorites(propertyId) : service.addToFavorites(propertyId);
          },
        );
      },
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: .92, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return AnimatedSlide(
          offset: Offset(0, (1 - value) * .08),
          duration: const Duration(milliseconds: 420),
          child: AnimatedOpacity(
            opacity: value as double,
            duration: const Duration(milliseconds: 420),
            child: Transform.scale(
              scale: value,
              child: GestureDetector(
                onTap: onTap,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(icon, color: Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}
// ignore: unused_element
class _HeaderSliver extends StatelessWidget {
  const _HeaderSliver({
    required this.images,
    required this.loading,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
    required this.property,
    required this.favoritesService,
    required this.transformationController,
    required this.isZoomed,
  });
  final List<String> images;
  final bool loading;
  final PageController controller;
  final int currentIndex;
  final Function(int) onPageChanged;
  final PropertyModel property;
  final FavoritesService favoritesService;
  final TransformationController transformationController;
  final bool isZoomed;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.25,
      pinned: true,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            /// IMAGE SLIDER
            if (loading)
              const Center(child: CircularProgressIndicator())
            else
              PageView.builder(
                allowImplicitScrolling: true,
                physics:
                    isZoomed ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                controller: controller,
                itemCount: images.length,
                onPageChanged: onPageChanged,
                itemBuilder: (_, index) {
                  final image = images[index];

                  return Hero(
                    tag: image,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SimplePhotoView(
                              images: images, // نفس الصور المستخدمة في slider
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
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
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            /// TITLE
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Text(
                property.title,
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
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),

                  Row(
                    children: [
                      _FavoriteButton(
                        propertyId: property.id,
                        service: favoritesService,
                      ),

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
    );
  }
}
