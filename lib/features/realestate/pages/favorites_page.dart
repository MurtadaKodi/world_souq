import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../services/property_service.dart';

class FavoritesPage extends StatelessWidget {
  final FavoritesService _favoritesService = FavoritesService();
  final PropertyService _propertyService = PropertyService();

  FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: StreamBuilder<List<String>>(
        stream: _favoritesService.getFavorites(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteIds = snapshot.data!;

          if (favoriteIds.isEmpty) {
            return const Center(
              child: Text('لا توجد عناصر في المفضلة'),
            );
          }

          return StreamBuilder(
            stream: _propertyService
                .getPropertiesByIds(favoriteIds),
            builder: (context, propertySnapshot) {
              if (!propertySnapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator());
              }

              final properties = propertySnapshot.data!;

              return ListView.builder(
                itemCount: properties.length,
                itemBuilder: (_, index) {
                  final property = properties[index];

                  return ListTile(
                    title: Text(property.title),
                    subtitle: Text(
                        '${property.price} ${property.currency}'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}