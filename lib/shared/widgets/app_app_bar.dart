import 'package:flutter/material.dart';
import 'package:market_world/core/providers/language_provider.dart';
import 'package:provider/provider.dart';


class AppAppBar extends StatelessWidget implements PreferredSizeWidget {

  const AppAppBar({
    required this.title, super.key,
    this.showBack = true,
    this.isAdmin = false,
    this.onBack,
  });
  final String title;
  final bool showBack;
  final bool isAdmin;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isArabic = lang.isArabic;

    return AppBar(
      backgroundColor:
          isAdmin ? Colors.redAccent : Theme.of(context).primaryColor,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack ?? () => Navigator.pop(context),
            )
          : null,
      title: Text(title),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: lang.toggleLanguage,
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language),
              const SizedBox(width: 4),
              Text(
                isArabic ? 'EN' : 'ع',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
