import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {

  const ProfilePage({
    required this.isLandlord, super.key,
  });
  final bool isLandlord;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  bool get isArabic => Localizations.localeOf(context).languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: isArabic ? const Text('الحساب') : const Text('Profile')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: Localizations.localeOf(context).languageCode == 'ar' ? 'الاسم' : 'Name',
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: Localizations.localeOf(context).languageCode == 'ar' ? 'رقم الهاتف' : 'Phone Number',
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: Localizations.localeOf(context).languageCode == 'ar' ? 'البريد الإلكتروني' : 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveUser,
                    child: isArabic ? const Text('حفظ التعديلات') : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      setState(() => isLoading = false); // 🔥 مهم
      return;
    }

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final data = doc.data();

      if (data != null) {
        nameCtrl.text = (data['name'] as String?) ?? '';
        phoneCtrl.text = (data['phone'] as String?) ?? '';
        emailCtrl.text = (data['email'] as String?) ?? '';
      }
    } catch (e) {
      debugPrint('Profile load error: $e');
    }

    setState(() => isLoading = false); // 🔥 مهم
  }

  Future<void> _saveUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': nameCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
    }, SetOptions(merge: true),);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ البيانات')),
    );
    @override
    // ignore: unused_element
    void dispose() {
      nameCtrl.dispose();
      phoneCtrl.dispose();
      emailCtrl.dispose();
      super.dispose();
    }
  }
}
