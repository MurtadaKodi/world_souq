// ignore_for_file: deprecated_member_use, dead_null_aware_expression, avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:market_world/core/constants/enums.dart';
import 'package:market_world/features/realestate/models/property_model.dart';
import 'package:market_world/features/realestate/pages/property_details_page.dart';
import 'package:market_world/features/realestate/services/property_service.dart';
import 'package:market_world/features/realestate/widgets/luxury_marker.dart';
import 'package:market_world/features/realestate/widgets/marker_generator.dart';
import 'package:market_world/map/cluster_marker.dart';
import 'package:market_world/map/smart_cluster_engine.dart';

class PropertiesMapPage extends StatefulWidget {

  const PropertiesMapPage({
    super.key,
    this.focusPropertyId, required int initialIndex, required UserRole role,
  });
  final String? focusPropertyId;

  @override
  State<PropertiesMapPage> createState() => _PropertiesMapPageState();
}

class _PropertiesMapPageState extends State<PropertiesMapPage> {
  final PropertyService _service = PropertyService();

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

  // =========================
  // INIT
  // =========================
  @override
  void initState() {
    super.initState();
    _listenProperties();
  }

  void _listenProperties() {
    _service.streamAllProperties().listen((data) async {
      _properties = data;
      await _rebuild();
      _handleInitialFocus();
    });
  }

  Future<void> _handleInitialFocus() async {
    if (widget.focusPropertyId == null) return;

    final list =
        _properties.where((p) => p.id == widget.focusPropertyId).toList();

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

    setState(() {
      _markers = {};
      _circles = circles;
    });
  }

  // =========================
  // CLUSTERS + MARKERS (FINAL)
  // =========================
  Future<void> _buildClusters() async {
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
    ClusterMarker(
      count: cluster.properties.length,
      zoom: _currentZoom,
    ),
  );

        markers.add(
          Marker(
            markerId: MarkerId('cluster_${cluster.position}'),
            position: cluster.position,
            icon: icon,
            onTap: () {
              _controller?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: cluster.position,
                    zoom: _currentZoom + 2,
                  ),
                ),
              );
            },
          ),
        );

        continue;
      }}

      print('Properties count: ${cluster.properties.length}');
// =========================
// 💰 SINGLE PROPERTY
// =========================
      final property = cluster.properties.first;

      final zoomBucket_ = (_currentZoom / 2).floor();

      final cacheKey =
          '${property.id}_$zoomBucket_${property.id == _selectedId}';

      BitmapDescriptor icon;

      if (_markerCache.containsKey(cacheKey)) {
        icon = _markerCache[cacheKey]!;
      } else {
        icon = await createLuxuryMarker(
          price: '${property.price.toInt() ?? 0} QAR',
          zoom: _currentZoom,
          selected: property.id == _selectedId,
        );
      }

      markers.add(
        Marker(
            markerId: MarkerId(property.id),
            position: cluster.position,
            icon: icon,
            onTap: () async {
              // ❌ منع الفتح التلقائي أثناء الـ highlight
              if (_isHighlighting) return;

              await _highlightProperty(property);

              if (!mounted) return;
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) {
                  return PropertyDetailsFullScreen(
                    property: property,
                    onClose: () => Navigator.pop(context),
                    onBook: () {},
                  );
                },
              );

              setState(() => _isSheetOpen = false);
            },),
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
        CameraPosition(
          target: LatLng(property.lat!, property.lng!),
          zoom: 16,
        ),
      ),
    );

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
    final pos = await Geolocator.getCurrentPosition();
    _currentPosition = pos;

    final latLng = LatLng(pos.latitude, pos.longitude);

    setState(() {
      _circles.add(
        Circle(
          circleId: const CircleId('radius'),
          center: latLng,
          radius: _getDynamicRadius(),
          fillColor: Colors.blue.withOpacity(0.15),
          strokeColor: Colors.blue,
        ),
      );
    });

    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 18),
    );

    await _rebuild();
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
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
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
                print('Map created ✅');
                print('Properties count: ${_properties.length}');
              },
              onCameraMove: (pos) => _currentZoom = pos.zoom,
              onCameraIdle: () async {
                _visibleRegion = await _controller?.getVisibleRegion();

                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), _rebuild);
              },
            ),
          ),
          Positioned(
            bottom: 190,
            right: 10,
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
