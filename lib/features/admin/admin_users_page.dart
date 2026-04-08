// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/language_provider.dart';
import '../../shared/widgets/app_app_bar.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isArabic = lang.isArabic;

    return Scaffold(
      appBar: const AppAppBar(
        title: 'Users',
        isAdmin: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inbox_outlined,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    isArabic ? 'لا توجد بيانات بعد' : 'No users found',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final bool isActive = data['active'] != false;
              final bool isAdmin = data['isAdmin'] == true;
              final String role = data['role'] ?? 'unknown';
              final String email =
                  (data['email'] as String?) ??
                  (isArabic ? 'مستخدم بدون بريد' : 'Anonymous user');

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isAdmin ? Colors.redAccent : Colors.blueAccent,
                  child: Icon(
                    isAdmin
                        ? Icons.admin_panel_settings
                        : Icons.person,
                    color: Colors.white,
                  ),
                ),
                title: Text(email),
                subtitle: Text(
                  isArabic ? 'الدور: $role' : 'Role: $role',
                ),
                trailing: isAdmin
                    ? Chip(
                        label: Text(
                          isArabic ? 'مسؤول' : 'Admin',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.redAccent,
                      )
                    : PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'toggle') {
                            await _toggleUserStatus(
                              context,
                              doc.id,
                              isActive,
                            );
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(
                              isActive
                                  ? (isArabic
                                      ? 'تعطيل المستخدم'
                                      : 'Disable user')
                                  : (isArabic
                                      ? 'تفعيل المستخدم'
                                      : 'Enable user'),
                            ),
                          ),
                        ],
                      ),
              );
            },
          );
        },
      ),
    );
  }
}

/// ================= Firestore Action =================

Future<void> _toggleUserStatus(
  BuildContext context,
  String userId,
  bool isActive,
) async {
  final isArabic =
      context.read<LanguageProvider>().isArabic;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'active': !isActive});

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isArabic
            ? 'تم تحديث حالة المستخدم'
            : 'User status updated',
      ),
    ),
  );
}
