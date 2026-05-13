// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:market_world/features/realestate/models/property_model.dart';
import 'dart:ui';

class UltraPropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onClose;
  final VoidCallback onDetails;
  final VoidCallback? onFavorite;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsApp;
  final bool isFavorite;

  const UltraPropertyCard({
    super.key,
    required this.property,
    required this.onClose,
    required this.onDetails,
    this.onFavorite,
    this.onCall,
    this.onWhatsApp,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .92, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return AnimatedSlide(
          offset: Offset(0, (1 - value) * 20),
          duration: const Duration(milliseconds: 320),
          child: AnimatedOpacity(
            opacity: value,
            duration: const Duration(milliseconds: 320),
            child: AnimatedScale(
              scale: value,
              duration: const Duration(milliseconds: 320),
              child: child,
            ),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 190,
              maxHeight: 230,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(.15),
                  Colors.black.withOpacity(.45),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(.25),
                width: 1.5,
              ),
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(.42),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(.05),
                  blurRadius: 50,
                  spreadRadius: 1,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  // =========================
                  // 💎 PRICE BADGE
                  // =========================

                  Positioned(
                    top: 18,
                    left: 18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.95),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        '${property.price.toStringAsFixed(0)} ${property.currency}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // =========================
                  // ❌ CLOSE
                  // =========================

                  Positioned(
                    right: 18,
                    top: 18,
                    child: GestureDetector(
                      onTap: onClose,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  // =========================
                  // 🧊 BOTTOM INFO
                  // =========================

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TITLE

                          Text(
                            property.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 15),

                          // LOCATION

                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white70,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${property.city} • ${property.area}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // BUTTONS

                          Row(
                            children: [
                              // =========================
                              // 📞 CALL
                              // =========================

                              _LuxuryActionButton(
                                icon: Icons.call_rounded,
                                onTap: onCall,
                              ),

                              const SizedBox(width: 10),

                              // =========================
                              // 💬 WHATSAPP
                              // =========================

                              _LuxuryActionButton(
                                icon: Icons.chat_rounded,
                                onTap: onWhatsApp,
                              ),

                              const SizedBox(width: 10),

                              // =========================
                              // ❤️ FAVORITE
                              // =========================

                              _LuxuryActionButton(
                                icon: isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFavorite ? Colors.redAccent : Colors.white,
                                onTap: onFavorite,
                              ),

                              const SizedBox(width: 12),

                              // =========================
                              // 🔍 DETAILS
                              // =========================

                              Expanded(
                                child: ElevatedButton(
                                  onPressed: onDetails,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: const Text(
                                    'View Details',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LuxuryActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  const _LuxuryActionButton({
    required this.icon,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Icon(
            icon,
            key: ValueKey(icon),
            color: color ?? Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
