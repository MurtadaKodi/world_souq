import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:market_world/features/realestate/pages/property_details_page.dart';
import 'package:market_world/map/cluster_marker.dart';
import 'package:market_world/map/smart_cluster_engine.dart';

import '../models/property_model.dart';
import '../services/property_service.dart';
import '../widgets/price_marker.dart';
import '../widgets/marker_generator.dart';

class PropertiesMapPage extends StatefulWidget {
  final String? focusPropertyId;

  const PropertiesMapPage({
    super.key,
    this.focusPropertyId,
  });

  @override
  State<PropertiesMapPage> createState() => _PropertiesMapPageState();
}

class _PropertiesMapPageState extends State<PropertiesMapPage> {
  final PropertyService _service = PropertyService();

  GoogleMapController? _controller;

  List<PropertyModel> _properties = [];
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  final Map<String, BitmapDescriptor> _markerCache = {};

  Position? _currentPosition;
  double _currentZoom = 12;
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

  void _handleInitialFocus() {
    if (widget.focusPropertyId == null) return;

    final property =
        _properties.where((p) => p.id == widget.focusPropertyId).firstOrNull;

    if (property != null) {
      _highlightProperty(property);
    }
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
    final clusters = generateClusters(_filteredProperties(), _currentZoom);

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
                    tilt: 0,
                    bearing: 0,
                  ),
                ),
              );
            },
          ),
        );

        continue;
      }

      // =========================
      // 💰 SINGLE PROPERTY
      // =========================
      final property = cluster.properties.first;

      final cacheKey =
          '${property.id}_${_currentZoom.toStringAsFixed(1)}_${property.id == _selectedId}';

      BitmapDescriptor icon;

      if (_markerCache.containsKey(cacheKey)) {
        icon = _markerCache[cacheKey]!;
      } else {
        icon = await markerFromWidget(
          PriceMarker(
            price: '${property.price.toInt()}',
            selected: property.id == _selectedId,
            isOwner: false,
            isInsideRadius: true,
            zoom: _currentZoom,
          ),
        );

        _markerCache[cacheKey] = icon;
      }

      markers.add(
        Marker(
          markerId: MarkerId(property.id),
          position: cluster.position,
          icon: icon,
          onTap: () async {
            await _highlightProperty(property);

            if (!mounted) return;

            await Navigator.push(
  context,
  PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, animation, __) {
      return FadeTransition(
        opacity: animation,
        child: PropertyDetailsFullScreen(
          property: property,
          onClose: () => Navigator.pop(context),
          onBook: () {},
        ),
      );
    },
  ),
);

            setState(() => _isSheetOpen = false);
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

      return distance <= _radiusMeters;
    }).toList();
  }

  // =========================
  // HIGHLIGHT
  // =========================
  Future<void> _highlightProperty(PropertyModel property) async {
    if (_isHighlighting) return;

    _isHighlighting = true;
    _selectedId = property.id;

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
          radius: _radiusMeters,
          fillColor: Colors.blue.withOpacity(0.15),
          strokeColor: Colors.blue,
        ),
      );
    });

    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 14),
    );

    await _rebuild();
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              myLocationEnabled: false,
              onMapCreated: (c) => _controller = c,
              onCameraMove: (pos) => _currentZoom = pos.zoom,
              onCameraIdle: () {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), _rebuild);
              },
            ),
          ),
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
