// ignore_for_file: inference_failure_on_instance_creation, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:market_world/features/admin/admin_listings_page.dart';
import 'package:market_world/features/admin/admin_properties_page.dart';
import 'package:market_world/features/admin/admin_users_page.dart';
import 'package:market_world/shared/widgets/app_app_bar.dart';



class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: const AppAppBar(
    title: 'Admin Dashboard',
    isAdmin: true,
    showBack: false,
  ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: const [
            _AdminCard(
              icon: Icons.people_outline,
              title: 'Users',
              page: AdminUsersPage(),
            ),
            _AdminCard(
              icon: Icons.storefront_outlined,
              title: 'Listings',
              page: AdminListingsPage(),
            ),
            _AdminCard(
              icon: Icons.home_work_outlined,
              title: 'Properties',
              page: AdminPropertiesPage(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.page,
  });
  final IconData icon;
  final String title;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      hoverColor: Theme.of(context).primaryColor.withOpacity(0.08),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

