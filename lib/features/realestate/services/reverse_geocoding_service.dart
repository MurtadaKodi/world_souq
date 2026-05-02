import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ReverseGeocodingService {
  static Future<String?> getAddress({
    required double lat,
    required double lng,
  }) async {

    // 🚫 لا نحاول Reverse Geocoding على Web
    if (kIsWeb) {
      debugPrint('⚠ Reverse geocoding disabled on Web');
      return null;
    }

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json&lat=$lat&lon=$lng',
      );

      final res = await http.get(
        uri,
        headers: {
          'User-Agent': 'market-world-app',
        },
      );

      if (res.statusCode != 200) return null;

      final data = json.decode(res.body) as Map<String, dynamic>;

      return data['display_name'] as String?;
    } catch (e) {
      debugPrint('Reverse geocoding failed: $e');
      return null;
    }
  }
}
