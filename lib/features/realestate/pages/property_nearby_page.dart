// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/distance_utils.dart';
import '../../storage/firebase_storage_service.dart';
import '../models/property_model.dart';
import '../services/property_storage_service.dart';

class PropertiesNearbyPage extends StatefulWidget {
  const PropertiesNearbyPage({super.key});

  @override
  State<PropertiesNearbyPage> createState() =>
      _PropertiesNearbyPageState();
}

class _PropertiesNearbyPageState
    extends State<PropertiesNearbyPage> {
  final PropertyStorageService _service =
      PropertyStorageService();

  final FirebaseStorageService _storageService =
      FirebaseStorageService();

  double radiusKm = 10;
  Position? userPosition;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // ================= LOCATION =================

  Future<void> _getUserLocation() async {
    final permission =
        await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'يجب السماح بتحديد الموقع لعرض العقارات القريبة'),
        ),
      );
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    if (!mounted) return;

    setState(() => userPosition = pos);
  }

  // ================= GOOGLE NAVIGATION =================

  Future<void> _openInGoogleMaps(
      PropertyModel property) async {
    if (property.lat == null ||
        property.lng == null) {
      return;
    }

    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${property.lat},${property.lng}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri,
          mode: LaunchMode.externalApplication);
    }
  }

  // ================= BOOKING =================

  void _goToBooking(PropertyModel property) {
    Navigator.pop(context);

    Navigator.pushNamed(
      context,
      '/booking',
      arguments: property.id,
    );
  }

  // ================= BOTTOM SHEET =================

  void _showPropertySheet(PropertyModel property) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NearbyPropertySheet(
        property: property,
        storageService: _storageService,
        onNavigate: () =>
            _openInGoogleMaps(property),
        onBook: () => _goToBooking(property),
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    if (userPosition == null) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator()),
      );
    }

    final userLatLng = LatLng(
      userPosition!.latitude,
      userPosition!.longitude,
    );

    return Scaffold(
      appBar:
          AppBar(title: const Text('العقارات القريبة')),
      body: Column(
        children: [
          // ======= RADIUS SLIDER =======

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                    'نطاق البحث: ${radiusKm.toInt()} كم'),
                Slider(
                  value: radiusKm,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label:
                      '${radiusKm.toInt()} كم',
                  onChanged: (v) =>
                      setState(() => radiusKm = v),
                ),
              ],
            ),
          ),

          // ======= MAP =======

          Expanded(
            child: StreamBuilder<List<PropertyModel>>(
              stream:
                  _service.streamAllProperties(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child:
                          CircularProgressIndicator());
                }

                final filtered =
                    snapshot.data!.where((p) {
                  if (p.lat == null ||
                      p.lng == null) {
                    return false;
                  }

                  return distanceInKm(
                        lat1: userPosition!
                            .latitude,
                        lng1: userPosition!
                            .longitude,
                        lat2: p.lat!,
                        lng2: p.lng!,
                      ) <=
                      radiusKm;
                }).toList();

                return Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: userLatLng,
                        initialZoom: 13,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'com.marketworld.app',
                        ),

                        // USER
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: userLatLng,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 36,
                              ),
                            ),
                          ],
                        ),

                        // PROPERTIES
                        MarkerLayer(
                          markers: filtered
                              .map((p) => Marker(
                                    point: LatLng(
                                        p.lat!,
                                        p.lng!),
                                    width: 40,
                                    height: 40,
                                    child:
                                        GestureDetector(
                                      onTap: () =>
                                          _showPropertySheet(
                                              p),
                                      child:
                                          const Icon(
                                        Icons
                                            .location_on,
                                        color:
                                            Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),

                    if (filtered.isEmpty)
                      const Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: _EmptyState(),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================= EMPTY STATE =================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Text(
          'لا توجد عقارات ضمن هذا النطاق.\nجرّب توسيع المسافة.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

// ================= PROPERTY SHEET =================

class _NearbyPropertySheet
    extends StatelessWidget {
  final PropertyModel property;
  final FirebaseStorageService
      storageService;
  final VoidCallback onNavigate;
  final VoidCallback onBook;

  const _NearbyPropertySheet({
    required this.property,
    required this.storageService,
    required this.onNavigate,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath =
        property.mainImage ??
            (property.mediaPaths.isNotEmpty
                ? property.mediaPaths.first
                : null);

    return Container(
      margin: const EdgeInsets.only(top: 80),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius:
            const BorderRadius.vertical(
                top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (imagePath != null)
              FutureBuilder<String>(
                future: storageService
                    .resolveDownloadUrl(
                        imagePath),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const SizedBox(
                      height: 180,
                      child: Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    );
                  }

                  return ClipRRect(
                    borderRadius:
                        BorderRadius.circular(16),
                    child: Image.network(
                      snap.data!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              )
            else
              Container(
                height: 180,
                color: Colors.grey[300],
                child: const Icon(
                    Icons.image,
                    size: 60),
              ),

            const SizedBox(height: 16),

            Text(
              property.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              '${property.price.toStringAsFixed(0)} ${property.currency}',
              style: const TextStyle(
                fontSize: 16,
                color:
                    Colors.redAccent,
              ),
            ),

            const SizedBox(height: 6),

            Text(property.address ?? ''),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        onNavigate,
                    icon: const Icon(
                        Icons.navigation),
                    label:
                        const Text(
                            'Google Map'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed: onBook,
                    icon: const Icon(
                        Icons.event),
                    label:
                        const Text(
                            'حجز موعد'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}