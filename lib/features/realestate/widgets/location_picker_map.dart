// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerMap extends StatefulWidget {

  const LocationPickerMap({
    required this.onPicked, super.key,
    this.initialLat,
    this.initialLng,
  });
  final double? initialLat;
  final double? initialLng;
  final void Function(LatLng point) onPicked;

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  late final MapController _controller;
  LatLng? selected;
  double zoom = 13;

  static const LatLng _doha = LatLng(25.2854, 51.5310);

  @override
  void initState() {
    super.initState();
    _controller = MapController();

    if (widget.initialLat != null && widget.initialLng != null) {
      selected = LatLng(widget.initialLat!, widget.initialLng!);
    }
  }

  // 📍 GPS
  Future<void> _goToMyLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final point = LatLng(pos.latitude, pos.longitude);

    setState(() {
      selected = point;
      zoom = 15;
    });

    _controller.move(point, zoom);
    widget.onPicked(point);
  }

  // 🔄 Recenter
  void _recenter() {
    if (selected != null) {
      _controller.move(selected!, zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 280,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _controller,
                options: MapOptions(
                  initialCenter: selected ?? _doha,
                  initialZoom: zoom,
                  onTap: (_, point) {
                    setState(() => selected = point);
                    widget.onPicked(point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.marketworld.app',
                  ),
                  if (selected != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selected!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // 🧭 Controls
              Positioned(
                right: 10,
                top: 10,
                child: Column(
                  children: [
                    _mapBtn(
                      icon: Icons.my_location,
                      onTap: _goToMyLocation,
                      tooltip: 'موقعي الحالي',
                    ),
                    const SizedBox(height: 8),
                    _mapBtn(
                      icon: Icons.add,
                      onTap: () {
                        zoom++;
                                                    _controller.move(
                              selected ?? _doha,
                              zoom,
                            );
                          },
                          tooltip: 'تكبير',
                        ),
                        const SizedBox(height: 8),
                        _mapBtn(
                          icon: Icons.remove,
                          onTap: () {
                            zoom--;
                            _controller.move(
                              selected ?? _doha,
                              zoom,
                            );
                          },
                          tooltip: 'تصغير',
                        ),
                        const SizedBox(height: 8),
                        _mapBtn(
                          icon: Icons.center_focus_strong,
                          onTap: _recenter,
                          tooltip: 'إعادة التمركز',
                        ),
                      ],
                    ),
                  ),

                  // 📝 Hint
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'اضغط على الخريطة لتحديد موقع العقار',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      Widget _mapBtn({
        required IconData icon,
        required VoidCallback onTap,
        required String tooltip,
      }) {
        return Tooltip(
          message: tooltip,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(icon, size: 22),
              ),
            ),
          ),
        );
      }
    }


