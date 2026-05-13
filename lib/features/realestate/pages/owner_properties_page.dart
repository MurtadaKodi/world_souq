import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:market_world/features/realestate/models/property_model.dart';
import 'package:market_world/features/realestate/pages/property_form_page.dart';
import 'package:market_world/features/realestate/services/property_storage_service.dart';

class OwnerPropertiesPage extends StatelessWidget {
  const OwnerPropertiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final service = PropertyStorageService();

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('يجب تسجيل الدخول')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('عقاراتي')),
      body: StreamBuilder<List<PropertyModel>>(
        stream: service.streamMyProperties(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('لا توجد عقارات بعد'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final p = items[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(
                    p.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${p.city} - ${p.area}\n${p.price.toStringAsFixed(0)} ${p.currency}'),
                  isThreeLine: true,
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PropertyFormPage(property: p),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('حذف العقار'),
                              content: const Text('هل أنت متأكد من حذف هذا العقار؟'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('إلغاء'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('حذف'),
                                ),
                              ],
                            ),
                          );

                          if (ok == true) {
                            await service.deleteProperty(p.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}