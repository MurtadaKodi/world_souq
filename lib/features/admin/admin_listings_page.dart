import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:market_world/core/providers/language_provider.dart';
import 'package:market_world/shared/widgets/app_app_bar.dart';
import 'package:provider/provider.dart';

class AdminListingsPage extends StatelessWidget {
  const AdminListingsPage({super.key});

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
            .collection('items')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                isArabic ? 'لا توجد إعلانات' : 'No listings found',
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data()! as Map<String, dynamic>;

              final title =
                  (data['title'] as String?)?.trim().isNotEmpty == true
                      ? data['title']
                      : '—';

              final type = (data['type'] ?? 'unknown') as String;
              final status = (data['status'] ?? 'active') as String;

              return ListTile(
                leading: Icon(
                  type == 'property'
                      ? Icons.home_outlined
                      : Icons.chair_outlined,
                ),
                title: Text(title),
                subtitle: Text(
                  isArabic
                      ? 'النوع: $type • الحالة: $status'
                      : 'Type: $type • Status: $status',
                  style: TextStyle(
                    color: status == 'hidden' ? Colors.orange : Colors.green,
                  ),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'toggle') {
                      _toggleStatus(doc.id, status);
                    } else if (value == 'delete') {
                      _deleteListing(context, doc.id);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(
                        status == 'active'
                            ? (isArabic ? 'إخفاء' : 'Hide')
                            : (isArabic ? 'إظهار' : 'Show'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        isArabic ? 'حذف' : 'Delete',
                        style: const TextStyle(color: Colors.red),
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

  // ===== Firestore actions =====

  Future<void> _toggleStatus(String id, String current) {
    final newStatus = current == 'active' ? 'hidden' : 'active';

    return FirebaseFirestore.instance
        .collection('items')
        .doc(id)
        .update({'status': newStatus});
  }

  Future<void> _deleteListing(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('items').doc(id).delete();
    }
  }
}
