import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../features/realestate/models/property_model.dart';

class SmartCluster {
  final LatLng position;
  final List<PropertyModel> properties;

  SmartCluster({
    required this.position,
    required this.properties,
  });
}

double getGridSize(double zoom) {
  if (zoom < 10) return 0.08;
  if (zoom < 13) return 0.04;
  if (zoom < 15) return 0.02;
  return 0.0; // individual mode
}

List<SmartCluster> generateClusters(
  List<PropertyModel> properties,
  double zoom,
) {
  final gridSize = getGridSize(zoom);

  // 🟢 Individual mode (zoom قريب)
  if (gridSize == 0) {
    return properties
        .where((p) => p.lat != null && p.lng != null)
        .map((p) => SmartCluster(
              position: LatLng(p.lat!, p.lng!),
              properties: [p],
            ))
        .toList();
  }

  final Map<String, List<PropertyModel>> grid = {};

  for (var p in properties) {
    if (p.lat == null || p.lng == null) continue;

    final latIndex = (p.lat! / gridSize).floor();
    final lngIndex = (p.lng! / gridSize).floor();
    final key = '$latIndex-$lngIndex';

    grid.putIfAbsent(key, () => []).add(p);
  }

  return grid.values.map((group) {
    final avgLat =
        group.map((e) => e.lat!).reduce((a, b) => a + b) / group.length;

    final avgLng =
        group.map((e) => e.lng!).reduce((a, b) => a + b) / group.length;

    return SmartCluster(
      position: LatLng(avgLat, avgLng),
      properties: group,
    );
  }).toList();
}