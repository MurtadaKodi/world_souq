
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
class PropertyFullMapPage extends StatefulWidget {

  const PropertyFullMapPage({
    required this.lat, required this.lng, required this.title, super.key,
  });
  final double lat;
  final double lng;
  final String title;

  @override
  State<PropertyFullMapPage> createState() => _PropertyFullMapPageState();
}

class _PropertyFullMapPageState extends State<PropertyFullMapPage> {
  GoogleMapController? mapController;
  Position? userPosition;

  Set<Polyline> polylines = {};
  double? distanceKm;
  int? durationMin;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _getUserLocation();
    _calculateDistance();
    await _getRealRoute();
  }

  // ================= LOCATION =================

  Future<void> _getUserLocation() async {
    final permission =
        await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) return;

    userPosition = await Geolocator.getCurrentPosition();
    setState(() {});
  }
   // ================= ROUTE =================
   Future<void> _getRealRoute() async {
  if (userPosition == null) return;

  final origin =
      '${userPosition!.latitude},${userPosition!.longitude}';
  final destination = '${widget.lat},${widget.lng}';

  final url =
      'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=YOUR_API_KEY';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    final points =
        data['routes'][0]['overview_polyline']['points'] as String;

    final decodedPoints = _decodePolyline(points);

    setState(() {
      polylines = {
        Polyline(
          polylineId: const PolylineId('real_route'),
          points: decodedPoints,
          width: 6,
          color: Colors.blue,
        ),
      };

      // Distance & Duration
      final leg = data['routes'][0]['legs'][0];
      distanceKm = (leg['distance']['value'] as num) / 1000;
      durationMin = ((leg['duration']['value'] as num) / 60).round();
    });
  }
}

  // ================= DISTANCE =================

  void _calculateDistance() {
    if (userPosition == null) return;

    final distance = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      widget.lat,
      widget.lng,
    );

    distanceKm = distance / 1000;

    // ETA بسيط (سرعة 50 كم/ساعة)
    durationMin = ((distanceKm! / 50) * 60).round();
  }

  // ================= ROUTE (Simple Line) =================

  // ignore: unused_element
  void _drawSimpleRoute() {
    if (userPosition == null) return;

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: [
        LatLng(userPosition!.latitude, userPosition!.longitude),
        LatLng(widget.lat, widget.lng),
      ],
      width: 5,
      color: Colors.blue,
    );

    polylines.add(polyline);
  }

  // ================= GOOGLE NAV =================

  Future<void> _startNavigation() async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${widget.lat},${widget.lng}&travelmode=driving';

    await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication,);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final propertyLatLng = LatLng(widget.lat, widget.lng);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: userPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: propertyLatLng,
                    zoom: 13,
                  ),
                  myLocationEnabled: true,
                  polylines: polylines,
                  markers: {
                    Marker(
                      markerId: const MarkerId('property'),
                      position: propertyLatLng,
                    ),
                    Marker(
                      markerId: const MarkerId('user'),
                      position: LatLng(
                        userPosition!.latitude,
                        userPosition!.longitude,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure,),
                    ),
                  },
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                ),

                // 🔥 INFO CARD
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: _buildInfoCard(),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 📏 Distance + ETA
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${distanceKm?.toStringAsFixed(1) ?? '--'} km',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold,),
              ),
              Text('${durationMin ?? '--'} min'),
            ],
          ),

          // 🚀 Navigate Button
          ElevatedButton.icon(
            onPressed: _startNavigation,
            icon: const Icon(Icons.navigation),
            label: const Text('Start'),
          ),
        ],
      ),
    );
  }
  
List<LatLng> _decodePolyline(String encoded) {
  final points = <LatLng>[];
  var index = 0;
  final len = encoded.length;
  var lat = 0;
  var lng = 0;

  while (index < len) {
    int b;
    var shift = 0;
    var result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);

    final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);

    final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    points.add(LatLng(lat / 1E5, lng / 1E5));
  }

  return points;
}
}