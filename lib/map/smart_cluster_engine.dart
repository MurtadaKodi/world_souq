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
bool isHeatmap(double zoom) => zoom < 9;
bool isCluster(double zoom) => zoom >= 9 && zoom < 15;
bool isIndividual(double zoom) => zoom >= 15;

double getGridSize(double zoom) {
  if (zoom < 9) return 0.1;   // Heatmap zone
  if (zoom < 11) return 0.06;
  if (zoom < 13) return 0.03;
  if (zoom < 15) return 0.015;
  return 0.0; // individual mode
}

List<SmartCluster> generateClusters(
  
  List<PropertyModel> properties,
  double zoom,
) {
  final gridSize = getGridSize(zoom);

  // 🟢 Individual mode (zoom قريب)
  if (properties.isEmpty || gridSize == 0.0) {
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