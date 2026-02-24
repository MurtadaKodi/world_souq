// ignore_for_file: unused_local_variable, unused_element, use_build_context_synchronously
import 'dart:async';
// ignore: library_prefixes
import 'dart:math' as Math;
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:market_world/features/realestate/pages/property_details_page.dart';
import 'package:market_world/map/cluster_bubble_widget.dart';
import 'package:market_world/map/smart_cluster_engine.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';
import '../widgets/price_marker.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class PropertiesMapPage extends StatefulWidget {
  final String? focusPropertyId;
  final DateTime? focusDate;
  final String? focusTime;
  // ignore: prefer_final_fields, unused_field
  double _currentZoom = 14;
  // ignore: unused_field, prefer_final_fields
  bool _isZooming = false;

  PropertiesMapPage({
    super.key,
    this.focusPropertyId,
    this.focusDate,
    this.focusTime,
  });

  @override
  State<PropertiesMapPage> createState() => _PropertiesMapPageState();
}

class _PropertiesMapPageState extends State<PropertiesMapPage> {
  final PropertyService _propertyService = PropertyService();
  final String? _currentUid = FirebaseAuth.instance.currentUser?.uid;
  Future<void> _openInGoogleMapsSimple(PropertyModel property) async {
    if (property.lat == null || property.lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الموقع غير متوفر لهذا العقار')),
      );
      return;
    }

    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${property.lat},${property.lng}',
    );

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      // ignore: duplicate_ignore
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح Google Maps')),
      );
    }
  }

  Future<void> _openInGoogleMaps(PropertyModel property) async {
    if (property.lat == null || property.lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الموقع غير متوفر لهذا العقار')),
      );
      return;
    }

    final double lat = property.lat!;
    final double lng = property.lng!;

    // 📍 رابط خاص بتطبيق Google Maps
    final Uri googleMapsAppUri = Uri.parse('comgooglemaps://?q=$lat,$lng');

    // 🌐 رابط ويب احتياطي
    final Uri googleMapsWebUri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    try {
      // 🔵 نحاول فتح التطبيق أولاً
      if (await canLaunchUrl(googleMapsAppUri)) {
        await launchUrl(
          googleMapsAppUri,
          mode: LaunchMode.externalApplication,
        );
      }
      // 🌐 إذا لم يوجد التطبيق → افتح المتصفح
      else if (await canLaunchUrl(googleMapsWebUri)) {
        await launchUrl(
          googleMapsWebUri,
          mode: LaunchMode.externalApplication,
        );
      }
      // ❌ في حال فشل الاثنين
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح Google Maps')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء فتح الخريطة')),
      );
    }
  }

  String? _darkMapStyle;
  String? _lightMapStyle;

  double _getZoomScale(double zoom) {
    if (zoom < 9) return 0.7;
    if (zoom < 11) return 0.85;
    if (zoom < 13) return 1.0;
    if (zoom < 15) return 1.15;
    return 1.3;
  }

  LatLng? _expandedClusterPosition;
  Set<Circle> _heatCircles = {};
  bool get _isHeatmapMode => _currentZoom < 9;

  Color _getHeatColor(int count) {
    if (count < 5) return Colors.green;
    if (count < 15) return Colors.orange;
    if (count < 30) return Colors.red;
    return Colors.deepPurple;
  }

  List<Marker> _radialMarkers = [];
  bool _isRadialAnimating = false;
  List<Marker> _createRadialSpread(SmartCluster cluster) {
    final markers = <Marker>[];

    final center = cluster.position;
    final count = cluster.properties.length;

    const double radius = 0.0006; // مسافة التفكك

    for (int i = 0; i < count; i++) {
      final angle = (2 * 3.1415926 * i) / count;

      final offsetLat = center.latitude + radius * Math.cos(angle);
      final offsetLng = center.longitude + radius * Math.sin(angle);

      final property = cluster.properties[i];

      markers.add(
        Marker(
          markerId: MarkerId('radial_${property.id}'),
          position: LatLng(offsetLat, offsetLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    return markers;
  }

  void _showPropertySheet(PropertyModel property) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true, // 👈 مهم جداً
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Theme.of(context).cardColor,
      builder: (_) {
        return PropertyDetailsFullScreen(
          property: property,
          onClose: () => Navigator.pop(context),
          onNavigate: () => _openInGoogleMaps(property),
          onBook: () {
            Navigator.pop(context);
            Navigator.pushNamed(
              context,
              '/booking',
              arguments: property.id,
            );
          },
        );
      },
    );
  }

  Future<void> _buildHeatmap() async {
    final clusters = generateClusters(_properties, 9); // grid ثابت

    final newCircles = <Circle>{};

    for (final cluster in clusters) {
      final count = cluster.properties.length;

      if (count < 2) continue;

      final color = _getHeatColor(count);

      newCircles.add(
        Circle(
          circleId: CircleId('heat_${cluster.position}'),
          center: cluster.position,
          radius: 800 + (count * 40),
          fillColor: color.withOpacity(0.35),
          strokeWidth: 0,
        ),
      );
    }

    setState(() {
      _heatCircles = newCircles;
    });
  }

  Future<BitmapDescriptor> _createClusterBitmap(
    int count,
    LatLng position,
  ) async {
    final repaintKey = GlobalKey();

    final isHighlighted = _expandedClusterPosition == position;

    final widget = RepaintBoundary(
      key: repaintKey,
      child: Material(
        color: Colors.transparent,
        child: ClusterBubbleWidget(
          count: count,
          highlight: isHighlighted,
          zoom: _currentZoom,
        ),
      ),
    );

    return await _widgetToBitmap(widget, repaintKey);
  }

  GoogleMapController? _mapController;
  StreamSubscription<List<PropertyModel>>? _subscription;

  List<PropertyModel> _properties = [];
  Set<Marker> _markers = {};

  Position? _currentPosition;
  Circle? _userRadiusCircle;

  double _radiusInMeters = 5000;
  String? _selectedId;
  bool _showList = false;

  final Map<String, BitmapDescriptor> _markerCache = {};

  double _currentZoom = 12;
// ignore: unused_field
  final bool _isZooming = false;

  get myLocationEnabled => null;

  // ignore: unused_field
  final double _lastClusterZoom = 0;

  // ignore: unused_field
  final Map<int, BitmapDescriptor> _clusterBitmapCache = {};
  List<SmartCluster>? _cachedClusters;
  double _cachedZoom = 0;

  Timer? _cameraDebounce;

  @override
  void initState() {
    super.initState();
    _loadMapStyles();

    _subscription = _propertyService.streamAllProperties().listen((data) async {
  _properties = data;

  await _recluster();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _fitMapToBounds();

    if (widget.focusPropertyId != null) {
      final property = _properties.firstWhere(
        (p) => p.id == widget.focusPropertyId,
        orElse: () => _properties.first,
      );
      await _focusProperty(property);
    }
  });
});

  }

  // ================================
  // BUILD MARKERS (WITH RADIUS FILTER)
  // ================================
  Future<void> _buildMarkers() async {
    if (!mounted) return;

    final newMarkers = <Marker>{};

    final sourceList =
        _currentPosition != null ? _getPropertiesInsideRadius() : _properties;

    // 🔥 احسب الـ clusters مرة واحدة فقط
    List<SmartCluster> clusters;

    if (_cachedClusters != null && (_cachedZoom - _currentZoom).abs() < 0.5) {
      clusters = _cachedClusters!;
    } else {
      clusters = generateClusters(sourceList, _currentZoom);
      _cachedClusters = clusters;
      _cachedZoom = _currentZoom;
    }
    for (final cluster in clusters) {
      // ===============================
      // 🟢 Single Property
      // ===============================
      if (cluster.properties.length == 1) {
        final property = cluster.properties.first;

        final icon = await _createPriceMarkerBitmap(
          property: property,
          selected: property.id == _selectedId,
        );

        newMarkers.add(
          Marker(
            markerId: MarkerId(property.id),
            position: cluster.position,
            icon: icon,
            onTap: () async {
              await _focusProperty(property);
              _showPropertySheet(property);
            },
          ),
        );
      }

      // ===============================
      // 🔴 Cluster Marker
      // ===============================
      else {
        final icon = await _createClusterBitmap(
          cluster.properties.length,
          cluster.position,
        );

        newMarkers.add(
          Marker(
            markerId: MarkerId('cluster_${cluster.position}'),
            position: cluster.position,
            icon: icon,
            onTap: () async {
              if (_isRadialAnimating) return;

              setState(() {
                _isRadialAnimating = true;
                _radialMarkers = _createRadialSpread(cluster);
              });

              // 🎬 1️⃣ Tilt + Zoom أولي
              await _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: cluster.position,
                    zoom: _currentZoom + 1.5,
                    tilt: 45, // 👈 الميلان
                    bearing: 0,
                  ),
                ),
              );

              await Future.delayed(const Duration(milliseconds: 300));
              await _buildMarkers();

              // 🎬 2️⃣ Zoom أعمق
              await _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: cluster.position,
                    zoom: _currentZoom + 2.5,
                    tilt: 30,
                    bearing: 0,
                  ),
                ),
              );

              await Future.delayed(const Duration(milliseconds: 400));

              // 🎬 3️⃣ رجوع تدريجي للوضع الطبيعي
              await _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: cluster.position,
                    zoom: _currentZoom + 2.5,
                    tilt: 0,
                    bearing: 0,
                  ),
                ),
              );

              if (mounted) {
                setState(() {
                  _radialMarkers = [];
                  _isRadialAnimating = false;
                });
              }
            },
          ),
        );
      }
    }

    setState(() {
      _markers = {
        ...newMarkers,
        ..._radialMarkers,
      };
    });
  }

  // ================================
  // FILTER PROPERTIES INSIDE RADIUS
  // ================================
  List<PropertyModel> _getPropertiesInsideRadius() {
    if (_currentPosition == null) return _properties;

    return _properties.where((property) {
      if (property.lat == null || property.lng == null) return false;

      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        property.lat!,
        property.lng!,
      );

      return distance <= _radiusInMeters;
    }).toList();
  }

  // ================================
  // CURRENT LOCATION
  // ================================
  Future<void> _goToCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();

    _currentPosition = position;

    final userLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _userRadiusCircle = Circle(
        circleId: const CircleId('user_radius'),
        center: userLatLng,
        radius: _radiusInMeters,
        fillColor: Colors.blue.withOpacity(0.15),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      );
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(userLatLng, 14),
    );

    await _buildMarkers();
  }

  // ================================
  // UPDATE RADIUS
  // ================================
  Future<void> _updateRadius(double value) async {
    _radiusInMeters = value;

    if (_currentPosition == null) return;

    final userLatLng = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    setState(() {
      _userRadiusCircle = Circle(
        circleId: const CircleId('user_radius'),
        center: userLatLng,
        radius: _radiusInMeters,
        fillColor: Colors.blue.withOpacity(0.15),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      );
    });

    await _buildMarkers();
  }

  // ================================
  // AUTO FIT BOUNDS
  // ================================
  Future<void> _fitMapToBounds() async {
    if (_mapController == null || _properties.isEmpty) return;

    final valid =
        _properties.where((p) => p.lat != null && p.lng != null).toList();

    if (valid.isEmpty) return;

    double minLat = valid.first.lat!;
    double maxLat = valid.first.lat!;
    double minLng = valid.first.lng!;
    double maxLng = valid.first.lng!;

    for (final p in valid) {
      if (p.lat! < minLat) minLat = p.lat!;
      if (p.lat! > maxLat) maxLat = p.lat!;
      if (p.lng! < minLng) minLng = p.lng!;
      if (p.lng! > maxLng) maxLng = p.lng!;
    }

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80,
      ),
    );
  }

  // ================================
  // PRICE MARKER
  // ================================
  Future<BitmapDescriptor> _createPriceMarkerBitmap({
    required PropertyModel property,
    required bool selected,
  }) async {
    final isOwner = property.ownerId == _currentUid;

    bool isInsideRadius = true;
    String? distanceText;

    if (_currentPosition != null &&
        property.lat != null &&
        property.lng != null) {
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        property.lat!,
        property.lng!,
      );

      isInsideRadius = distance <= _radiusInMeters;

      final km = distance / 1000;
      distanceText = km < 1
          ? '${distance.toStringAsFixed(0)} m'
          : '${km.toStringAsFixed(1)} km';
    }

    final key =
        '${property.id}-$selected-$isOwner-$isInsideRadius-$distanceText';

    if (_markerCache.containsKey(key)) {
      return _markerCache[key]!;
    }

    final repaintKey = GlobalKey();

    final widget = RepaintBoundary(
      key: repaintKey,
      child: Material(
        color: Colors.transparent,
        child: PriceMarker(
          price: '${property.price.toStringAsFixed(0)} ${property.currency}',
          selected: selected,
          isOwner: isOwner,
          isInsideRadius: isInsideRadius,
          zoom: _currentZoom, // 👈 مهم جداً
        ),
      ),
    );

    final bitmap = await _widgetToBitmap(widget, repaintKey);

    _markerCache[key] = bitmap;

    return bitmap;
  }

  Future<BitmapDescriptor> _widgetToBitmap(
      Widget widget, GlobalKey repaintKey) async {
    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (_) => Positioned(top: -1000, child: widget),
    );

    overlay.insert(entry);

    await Future.delayed(const Duration(milliseconds: 40));

    final boundary =
        repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    entry.remove();

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  // ================================
  // FOCUS PROPERTY
  // ================================
  Future<void> _focusProperty(PropertyModel property) async {
    setState(() {
      _selectedId = property.id;
      _showList = false;
    });

    await _buildMarkers();

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(property.lat ?? 0, property.lng ?? 0),
      ),
    );
  }

  Future<void> _recluster() async {
    final sourceList =
        _currentPosition != null ? _getPropertiesInsideRadius() : _properties;

    final clusters = generateClusters(sourceList, _currentZoom);

    final markers = await _buildMarkersFromClusters(clusters);

    if (!mounted) return;

    setState(() {
      _markers = markers;
    });
  }

  Future<Set<Marker>> _buildMarkersFromClusters(
    List<SmartCluster> clusters,
  ) async {
    final newMarkers = <Marker>{};

    for (final cluster in clusters) {
      if (cluster.properties.length == 1) {
        final property = cluster.properties.first;

        final icon = await _createPriceMarkerBitmap(
          property: property,
          selected: property.id == _selectedId,
        );

        newMarkers.add(
          Marker(
            markerId: MarkerId(property.id),
            position: cluster.position,
            icon: icon,
            onTap: () async {
              await _focusProperty(property);
              _showPropertySheet(property);
            },
          ),
        );
      } else {
        final icon = await _createClusterBitmap(
          cluster.properties.length,
          cluster.position,
        );

        newMarkers.add(
          Marker(
            markerId: MarkerId('cluster_${cluster.position}'),
            position: cluster.position,
            icon: icon,
          ),
        );
      }
    }

    return newMarkers;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // ================================
  // UI
  // ================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (!_showList)
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(25.2854, 51.5310),
                zoom: 12,
              ),
              onCameraMove: (position) {
                _currentZoom = position.zoom;

                _cameraDebounce?.cancel();
                _cameraDebounce = Timer(
                  const Duration(milliseconds: 250),
                  () {
                    if (mounted) {
                      setState(() {});
                    }
                  },
                );
              },
              onCameraIdle: () {
                _cameraDebounce?.cancel();

                _cameraDebounce = Timer(
                  const Duration(milliseconds: 250),
                  () async {
                    if (!mounted) return;

                    if (_isHeatmapMode) {
                      await _buildHeatmap();
                    } else {
                      _heatCircles = {};
                      await _recluster();
                    }
                  },
                );
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
                final isDark = Theme.of(context).brightness == Brightness.dark;

                _mapController?.setMapStyle(
                  isDark ? _darkMapStyle : _lightMapStyle,
                );
              },
              markers: _markers,
              circles: {
                if (_userRadiusCircle != null) _userRadiusCircle!,
                ..._heatCircles,
              },
            ),
          if (_currentPosition != null)
            Positioned(
              bottom: 170,
              left: 20,
              right: 20,
              child: Card(
                child: Slider(
                  value: _radiusInMeters,
                  min: 1000,
                  max: 20000,
                  divisions: 19,
                  label: '${(_radiusInMeters / 1000).toStringAsFixed(0)} km',
                  onChanged: _updateRadius,
                ),
              ),
            ),
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadMapStyles() async {
    _darkMapStyle = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style_dark.json');
    _lightMapStyle =
        // ignore: duplicate_ignore
        // ignore: use_build_context_synchronously
        await DefaultAssetBundle.of(context)
            .loadString('assets/map_style_light.json');
  }
}

class _PropertyDetailsSheet extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onClose;
  final VoidCallback onNavigate;
  final VoidCallback onBook;

  const _PropertyDetailsSheet({
    required this.property,
    required this.onClose,
    required this.onNavigate,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // صورة
          Hero(
            tag: 'property_${property.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: property.mainImage != null
                  ? Image.network(
                      property.mainImage!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 60),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // العنوان والسعر
          Text(
            property.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '${property.price.toStringAsFixed(0)} ${property.currency}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.redAccent,
            ),
          ),

          const SizedBox(height: 6),

          Text(property.address ?? ''),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onNavigate,
                  icon: const Icon(Icons.navigation),
                  label: const Text('Google Map'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onBook,
                  icon: const Icon(Icons.event),
                  label: const Text('حجز موعد'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          TextButton(
            onPressed: onClose,
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
