// ignore_for_file: deprecated_member_use, dead_null_aware_expression, avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:market_world/core/constants/enums.dart';
import 'package:market_world/features/entry/entry_gate_page.dart';
import 'package:market_world/features/realestate/models/property_model.dart';
import 'package:market_world/features/realestate/pages/property_details_page.dart';
import 'package:market_world/features/realestate/services/favorites_service.dart';
import 'package:market_world/features/realestate/services/property_service.dart';
import 'package:market_world/features/realestate/widgets/luxury_marker.dart';
import 'package:market_world/features/realestate/widgets/marker_generator.dart';
import 'package:market_world/features/realestate/widgets/ultra_property_card.dart';
import 'package:market_world/features/storage/firebase_storage_service.dart';
import 'package:market_world/map/cluster_marker.dart';
import 'package:market_world/map/smart_cluster_engine.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertiesMapPage extends StatefulWidget {
  const PropertiesMapPage({
    super.key,
    this.focusPropertyId,
    required int initialIndex,
    required UserRole role,
  });
  final String? focusPropertyId;

  @override
  State<PropertiesMapPage> createState() => _PropertiesMapPageState();
}

class _PropertiesMapPageState extends State<PropertiesMapPage> with TickerProviderStateMixin {
  late final AnimationController _floatingController;
  late final AnimationController _bounceController;
  final Set<String> _favoriteIds = {};
  double _bounceValue = 1;
  double _floatingValue = 0;
  final PropertyService _service = PropertyService();
  PropertyModel? _selectedProperty;
  GoogleMapController? _controller;
  LatLngBounds? _visibleRegion;
  List<PropertyModel> _properties = [];
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  List<PropertyModel> _visibleProperties() {
    if (_visibleRegion == null) return _properties;

    return _properties.where((p) {
      if (p.lat == null || p.lng == null) return false;

      return p.lat! >= _visibleRegion!.southwest.latitude &&
          p.lat! <= _visibleRegion!.northeast.latitude &&
          p.lng! >= _visibleRegion!.southwest.longitude &&
          p.lng! <= _visibleRegion!.northeast.longitude;
    }).toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();

    _floatingController.dispose();
    _bounceController.dispose();

    super.dispose();
  }

  double _getDynamicRadius() {
    if (_currentZoom >= 16) return 800;
    if (_currentZoom >= 14) return 2000;
    if (_currentZoom >= 12) return 5000;
    return 12000;
  }

  final Map<String, BitmapDescriptor> _markerCache = {};

  Position? _currentPosition;
  double _currentZoom = 12;
  // ignore: unused_field
  final double _radiusMeters = 5000;

  String? _selectedId;
  bool _isHighlighting = false;
  bool _isSheetOpen = false;

  Timer? _debounce;

  final FavoritesService _favoritesService = FavoritesService();
  // =========================
  // INIT
  // =========================
  @override
  void initState() {
    _favoritesService.getFavorites().listen((ids) {
      setState(() {
        _favoriteIds
          ..clear()
          ..addAll(ids);
      });
    });
    super.initState();

    // =========================
    // FLOATING
    // =========================

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )
      ..repeat(reverse: true)
      ..addListener(() async {
        _floatingValue = Tween(begin: -4.0, end: 4.0).transform(_floatingController.value);
      });

    // =========================
    // BOUNCE
    // =========================

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..addListener(() async {
        _bounceValue = TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 1.0, end: 1.28).chain(CurveTween(curve: Curves.easeOut)),
            weight: 40,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 1.28, end: .92).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: Tween(begin: .92, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
            weight: 30,
          ),
        ]).transform(_bounceController.value);
      });

    _listenProperties();
  }

  void _listenProperties() {
    _service.streamAllProperties().listen((data) async {
      if (!mounted) return;

      _properties = data;

      await _rebuild();

      if (!mounted) return;

      _handleInitialFocus();
    });
  }

  Future<void> _handleInitialFocus() async {
    if (widget.focusPropertyId == null) return;

    final list = _properties.where((p) => p.id == widget.focusPropertyId).toList();

    if (list.isEmpty) return;

    final property = list.first;

    await _highlightProperty(property);
    setState(() {
      _selectedId = property.id;
    });

    await Future.delayed(const Duration(milliseconds: 150));
  }

  // =========================
  // REBUILD (HYBRID LOGIC)
  // =========================
  Future<void> _rebuild() async {
    if (_currentZoom < 9) {
      _buildHeatmap();
      return;
    }

    await _buildClusters();
  }

  // =========================
  // HEATMAP
  // =========================
  void _buildHeatmap() {
    final clusters = generateClusters(_properties, 9);

    final circles = <Circle>{};

    for (final cluster in clusters) {
      final count = cluster.properties.length;
      if (count < 2) continue;

      circles.add(
        Circle(
          circleId: CircleId('heat_${cluster.position}'),
          center: cluster.position,
          radius: 800 + (count * 40),
          fillColor: Colors.red.withOpacity(0.3),
          strokeWidth: 0,
        ),
      );
    }
    if (!mounted) return;

    setState(() {
      _markers = {};
      _circles = circles;
    });
  }

  // =========================
  // CLUSTERS + MARKERS (FINAL)
  // =========================
  Future<void> _buildClusters() async {
    if (!mounted) return;
    final clusters = generateClusters(_visibleProperties(), _currentZoom);

    final markers = <Marker>{};

    for (final cluster in clusters) {
      // =========================
      // 🔴 CLUSTER MODE
      // =========================
      if (cluster.properties.length > 1) {
        final count = cluster.properties.length;

        // ignore: unused_local_variable
        final color = count > 20
            ? Colors.red
            : count > 10
                ? Colors.orange
                : Colors.blue;

        if (cluster.properties.length > 1) {
          final icon = await markerFromWidget(
            ClusterMarker(count: cluster.properties.length, zoom: _currentZoom),
          );

          markers.add(
            Marker(
              markerId: MarkerId('cluster_${cluster.position}'),
              position: cluster.position,
              icon: icon,
              onTap: () {
                _controller?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: cluster.position, zoom: (_currentZoom + 4).clamp(0, 20)),
                  ),
                );
              },
            ),
          );

          continue;
        }
      }
      // =========================
      // 💰 SINGLE PROPERTY
      // =========================
      final property = cluster.properties.first;

      final zoomBucket_ = (_currentZoom / 2).floor();

      final cacheKey = '${property.id}_$zoomBucket_${property.id == _selectedId}';

      BitmapDescriptor icon;

      if (_markerCache.containsKey(cacheKey)) {
        icon = _markerCache[cacheKey]!;
      } else {
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
        icon = await createLuxuryMarker(
          price: isArabic ? '${property.price.toInt()} ر.ق' : '${property.price.toInt()} QAR',
          zoom: _currentZoom,
          selected: property.id == _selectedId,
          floatingOffset: property.id == _selectedId ? _floatingValue * 1.8 : _floatingValue,
          bounceScale: property.id == _selectedId ? _bounceValue : 1,
        );
        _markerCache[cacheKey] = icon;
      }

      markers.add(
        Marker(
          markerId: MarkerId(property.id),
          position: cluster.position,
          icon: icon,
          onTap: () async {
            if (_isHighlighting) return;

            setState(() {
              _selectedId = property.id;
            });

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) {
                return UltraPropertyCard(
                  property: property,
                  onClose: () {
                    Navigator.pop(context);
                  },
                  onDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailsFullScreen(
                          property: property,
                          onClose: () => Navigator.pop(context),
                          onBook: () {},
                        ),
                      ),
                    );
                  },
                  onCall: () async {},
                  onWhatsApp: () async {},
                  onFavorite: () async {},
                  isFavorite: _favoriteIds.contains(property.id),
                );
              },
            );
            _bounceController.forward(from: 0);
            await _controller?.animateCamera(
              CameraUpdate.newLatLngZoom(LatLng(property.lat!, property.lng!), 15),
            );
          },
        ),
      );
    }

    setState(() {
      _markers = markers;
      _circles = {};
    });
  }

  // =========================
  // FILTER
  // =========================
  // ignore: unused_element
  List<PropertyModel> _filteredProperties() {
    if (_currentPosition == null) return _properties;

    return _properties.where((p) {
      if (p.lat == null || p.lng == null) return false;

      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        p.lat!,
        p.lng!,
      );

      return distance <= _getDynamicRadius();
    }).toList();
  }

  // =========================
  // HIGHLIGHT
  // =========================
  Future<void> _highlightProperty(PropertyModel property) async {
    if (_isHighlighting) return;

    _isHighlighting = true;
    setState(() {
      _selectedId = property.id;
    });

    await _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(property.lat!, property.lng!), zoom: 16),
      ),
    );
    if (!mounted) return;
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 600));

    // 🔥 ألغِ التحديد بعد الحركة
    _selectedId = null;
    _isHighlighting = false;
  }

  // =========================
  // LOCATION
  // =========================
  Future<void> _goToCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      final latLng = LatLng(
        position.latitude,
        position.longitude,
      );

      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 15),
      );
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final isStandalone = Navigator.of(context).canPop();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: isStandalone
          ? AppBar(
              title: isArabic ? const Text('الخريطة') : const Text('Map'),
              leading: IconButton(
                icon: const Icon(Icons.home_rounded, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EntryGatePage(),
                    ),
                    (route) => false,
                  );
                },
              ),
            )
          : null,
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isSheetOpen,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(25.2854, 51.5310),
                zoom: 12,
              ),
              markers: _markers,
              circles: _circles,
              onMapCreated: (controller) {
                _controller = controller;
              },
              onCameraMove: (pos) => _currentZoom = pos.zoom,
              onCameraIdle: () async {
                _visibleRegion = await _controller?.getVisibleRegion();

                _debounce?.cancel();

                _debounce = Timer(
                  const Duration(milliseconds: 700),
                  () async {
                    if (!mounted) return;

                    await _rebuild();
                  },
                );
              },
            ),
          ),
          // DARK OVERLAY
          AnimatedOpacity(
            opacity: _selectedProperty != null ? 1 : 0,
            duration: const Duration(milliseconds: 350),
            // child: Container(
            //   color: Colors.black.withOpacity(.38),
            // ),
          ),
          // INFO CARD
          // if (_selectedProperty != null)
          //   UltraPropertyCard(
          //     key: ValueKey(
          //       '${_selectedProperty!.id}_${_favoriteIds.contains(_selectedProperty!.id)}',
          //     ),
          //     onCall: () async {
          //       final phone = _selectedProperty?.ownerPhone.replaceAll(RegExp(r'[^0-9]'), '') ?? '';

          //       if (phone.isEmpty) return;

          //       await launchUrl(
          //         Uri.parse('tel:$phone'),
          //       );
          //     },
          //     onWhatsApp: () async {
          //       var phone = _selectedProperty?.ownerPhone.replaceAll(RegExp(r'[^0-9]'), '') ?? '';

          //       if (phone.isEmpty) return;

          //       if (phone.length == 8) {
          //         phone = '974$phone';
          //       }

          //       final msg = Uri.encodeComponent(
          //         'مرحباً، أنا مهتم بالعقار: ${_selectedProperty?.title}',
          //       );

          //       await launchUrl(
          //         Uri.parse(
          //           'https://wa.me/$phone?text=$msg',
          //         ),
          //         mode: LaunchMode.externalApplication,
          //       );
          //     },
          //     onFavorite: () async {
          //       final id = _selectedProperty!.id;

          //       if (_favoriteIds.contains(id)) {
          //         await _favoritesService.removeFromFavorites(id);
          //       } else {
          //         await _favoritesService.addToFavorites(id);
          //       }
          //     },
          //     property: _selectedProperty!,
          //     onClose: () {
          //       setState(() {
          //         _selectedProperty = null;
          //         _selectedId = null;
          //       });
          //       _rebuild();
          //     },
          //     onDetails: () {
          //       showModalBottomSheet(
          //         context: context,
          //         isScrollControlled: true,
          //         builder: (_) => PropertyDetailsFullScreen(
          //           property: _selectedProperty!,
          //           onClose: () => Navigator.pop(context),
          //           onBook: () {},
          //         ),
          //       );
          //     },
          //     isFavorite: _favoriteIds.contains(
          //       _selectedProperty!.id,
          //     ),
          //   ),
          Positioned(
            bottom: 25,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.my_location, color: Colors.black),
                onPressed: _goToCurrentLocation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  PropertyModel? _getNearestProperty() {
    if (_currentPosition == null || _properties.isEmpty) return null;

    PropertyModel? nearest;
    var minDistance = double.infinity;

    for (final p in _properties) {
      if (p.lat == null || p.lng == null) continue;

      final d = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        p.lat!,
        p.lng!,
      );

      if (d < minDistance) {
        minDistance = d;
        nearest = p;
      }
    }

    return nearest;
  }
}

// ignore: unused_element
class _MarkerInfoCard extends StatelessWidget {
  const _MarkerInfoCard({
    required this.property,
    required this.onClose,
    required this.onDetails,
  });

  final PropertyModel property;
  final VoidCallback onClose;
  final VoidCallback onDetails;

  Future<void> _call() async {
    final phone = property.ownerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.isEmpty) return;
    await launchUrl(Uri.parse('tel:$phone'));
  }

  Future<void> _whatsapp() async {
    var phone = property.ownerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.isEmpty) return;

    if (phone.length == 8) {
      phone = '974$phone';
    }

    final msg = Uri.encodeComponent('مرحباً، أنا مهتم بالعقار: ${property.title}');

    await launchUrl(
      Uri.parse('https://wa.me/$phone?text=$msg'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                FutureBuilder<String>(
                  future: FirebaseStorageService().resolveDownloadUrl(property.mediaPaths.first),
                  builder: (context, snap) {
                    final url = snap.data ?? '';

                    if (url.isEmpty) {
                      return const Icon(Icons.home_work);
                    }

                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.home_rounded, color: Colors.indigo, size: 26),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        '${property.price.toStringAsFixed(0)} ${property.currency}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      if (property.ownerName.isNotEmpty)
                        Text(
                          property.ownerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: property.ownerPhone.isEmpty ? null : _call,
                    icon: const Icon(Icons.call, size: 18),
                    label: Text(isArabic ? 'اتصال' : 'Call'),
                  ),
                ),
                const SizedBox(width: 10),
                if (property.ownerPhone.isNotEmpty) ...[
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: InkWell(
                      onTap: _whatsapp,
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.08), // خلفية نظيفة
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 1.5,
                          ),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.black.withOpacity(0.1), // Shadow ناعم بدل الأخضر
                          //     blurRadius: 6,
                          //     offset: Offset(0, 3),
                          //   ),
                          // ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/icons/whatsapp.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                    child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: () {},
                  child: Text(isArabic ? 'التفاصيل' : 'Details'),
                )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
