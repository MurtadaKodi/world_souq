// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:market_world/features/realestate/services/favorites_service.dart';

class FavoriteButton extends StatelessWidget {

  FavoriteButton({required this.propertyId, super.key});
  final String propertyId;

  final FavoritesService _favoritesService =
      FavoritesService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _favoritesService.isFavorite(propertyId),
      builder: (context, snapshot) {
        final isFav = snapshot.data ?? false;

        return GestureDetector(
          onTap: () async {
            if (isFav) {
              await _favoritesService
                  .removeFromFavorites(propertyId);
            } else {
              await _favoritesService
                  .addToFavorites(propertyId);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder:
                  (child, animation) {
                return ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: child,
                );
              },
              child: Icon(
                isFav
                    ? Icons.favorite
                    : Icons.favorite_border,
                key: ValueKey(isFav),
                color:
                    isFav ? Colors.red : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}