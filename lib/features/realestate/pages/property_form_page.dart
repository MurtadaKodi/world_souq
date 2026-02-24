// ignore_for_file: deprecated_member_use

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:market_world/features/realestate/services/reverse_geocoding_service.dart';
import 'package:market_world/features/realestate/widgets/location_picker_map.dart';
import 'package:market_world/features/realestate/widgets/map_card.dart';
import 'package:market_world/features/storage/firebase_storage_service.dart';

import '../models/property_model.dart';
import '../services/property_storage_service.dart';

String? address;
bool loadingAddress = false;

/// ================= SEARCH KEYWORDS =================
List<String> buildSearchKeywords(String text) {
  final lower = text.toLowerCase().trim();
  final words = lower.split(RegExp(r'\s+'));

  final Set<String> keywords = {};

  for (final word in words) {
    for (int i = 1; i <= word.length; i++) {
      keywords.add(word.substring(0, i));
    }
  }

  return keywords.toList();
}

/// ================= PAGE =================
class PropertyFormPage extends StatefulWidget {
  final PropertyModel? property; // null = إضافة | not null = تعديل
  final double? lat;
  final double? lng;

  const PropertyFormPage({
    super.key,
    this.property,
    this.lat,
    this.lng,
  });

  @override
  State<PropertyFormPage> createState() => _PropertyFormPageState();
}

class _PropertyFormPageState extends State<PropertyFormPage> {
  final _formKey = GlobalKey<FormState>();

  double? lat;
  double? lng;

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final areaCtrl = TextEditingController();

  String type = 'apartment';
  String purpose = 'rent';

  bool saving = false;

  final picker = ImagePicker();
  final List<XFile> pickedImages = [];

  final storageService = FirebaseStorageService();
  final propertyService = PropertyStorageService();

  @override
  void initState() {
    lat = widget.property?.lat ?? widget.lat;
    lng = widget.property?.lng ?? widget.lng;

    super.initState();

    if (widget.property != null) {
      final p = widget.property!;
      titleCtrl.text = p.title;
      descCtrl.text = p.description;
      priceCtrl.text = p.price.toString();
      cityCtrl.text = p.city;
      areaCtrl.text = p.area;
      type = p.type;
      purpose = p.purpose;
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    cityCtrl.dispose();
    areaCtrl.dispose();
    super.dispose();
  }

  // ================= PICK IMAGES =================
  Future<void> _pickImages() async {
    final files = await picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;

    setState(() {
      pickedImages.addAll(files);
    });
  }

  // ================= SAVE =================
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (pickedImages.isEmpty && widget.property == null) {
      _show('أضف صورة واحدة على الأقل');
      return;
    }

    setState(() => saving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final propertyId = widget.property?.id ?? propertyService.newPropertyId();

      final List<String> uploadedPaths = [];

      for (final img in pickedImages) {
        final path = await storageService.uploadImage(
          localPathOrUrl: img.path,
          folder: 'properties/$propertyId',
          fileName: img.name,
        );
        uploadedPaths.add(path);
      }

      final keywords = buildSearchKeywords(titleCtrl.text);

      final property = PropertyModel(
        id: propertyId,
        ownerId: uid,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        price: double.parse(priceCtrl.text),
        type: type,
        purpose: purpose,
        city: cityCtrl.text.trim(),
        area: areaCtrl.text.trim(),
        mediaPaths: widget.property?.mediaPaths ?? uploadedPaths,
        mainImage: uploadedPaths.isNotEmpty
            ? uploadedPaths.first
            : widget.property?.mainImage,
        searchKeywords: keywords,
        createdAt: widget.property?.createdAt,
        updatedAt: Timestamp.now(),
        lat: lat,
        lng: lng, favoritesCount: 0,
      );

      if (widget.property == null) {
        await propertyService.createProperty(property);
      } else {
        await propertyService.updateProperty(property);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    // ignore: unused_catch_stack
    } catch (e, stack) {
      _show('Error: $e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title:
                Text(widget.property == null ? 'إضافة عقار' : 'تعديل العقار'),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _input(titleCtrl, 'العنوان'),
                _input(descCtrl, 'الوصف', maxLines: 4),
                _input(priceCtrl, 'السعر', keyboard: TextInputType.number),
                _input(cityCtrl, 'المدينة'),
                _input(areaCtrl, 'المنطقة'),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(child: _dropdownType()),
                    const SizedBox(width: 12),
                    Expanded(child: _dropdownPurpose()),
                  ],
                ),

                const SizedBox(height: 20),

                // 🖼 Preview
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...pickedImages.map(
                      (x) => FutureBuilder<Uint8List>(
                        future: x.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Image.memory(
                              snapshot.data!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            );
                          }
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'اختيار الموقع',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),
                MapCard(
                    title: 'الموقع',
                    child: LocationPickerMap(
                      initialLat: lat,
                      initialLng: lng,
                      onPicked: (point) async {
  setState(() {
    lat = point.latitude;
    lng = point.longitude;
    loadingAddress = true;
  });

  final addr = await ReverseGeocodingService.getAddress(
    lat: lat!,
    lng: lng!,
  );

  setState(() {
    address = addr;
    loadingAddress = false;
  });
},


                    )),
                const SizedBox(height: 24),
              if (loadingAddress)
  const Padding(
    padding: EdgeInsets.only(top: 8),
    child: LinearProgressIndicator(),
  )
else if (address != null)
  Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.place, size: 18, color: Colors.red),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            address!,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    ),
  ),
                const SizedBox(height: 24),

                FilledButton(
                  onPressed: saving ? null : _save,
                  child: const Text('حفظ'),
                ),
              ],
            ),
          ),
        ),
        if (saving)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  // ================= Widgets =================
  Widget _input(TextEditingController c, String label,
      {int maxLines = 1, TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _dropdownType() {
    return DropdownButtonFormField<String>(
      value: type,
      items: const [
        DropdownMenuItem(value: 'apartment', child: Text('شقة')),
        DropdownMenuItem(value: 'villa', child: Text('فيلا')),
        DropdownMenuItem(value: 'land', child: Text('أرض')),
      ],
      onChanged: (v) => setState(() => type = v!),
      decoration: const InputDecoration(labelText: 'النوع'),
    );
  }

  Widget _dropdownPurpose() {
    return DropdownButtonFormField<String>(
      value: purpose,
      items: const [
        DropdownMenuItem(value: 'rent', child: Text('إيجار')),
        DropdownMenuItem(value: 'sale', child: Text('بيع')),
      ],
      onChanged: (v) => setState(() => purpose = v!),
      decoration: const InputDecoration(labelText: 'الغرض'),
    );
  }
}
