// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_world/features/realestate/models/property_model.dart';
import 'package:market_world/features/realestate/services/property_storage_service.dart';
import 'package:market_world/features/realestate/widgets/location_picker_map.dart';
import 'package:market_world/features/storage/firebase_storage_service.dart';
import 'package:market_world/shared/widgets/adaptive_image.dart';

String? address;
bool loadingAddress = false;

/// ================= SEARCH KEYWORDS =================
List<String> buildSearchKeywords(String text) {
  final lower = text.toLowerCase().trim();
  final words = lower.split(RegExp(r'\s+'));

  final keywords = <String>{};

  for (final word in words) {
    for (var i = 1; i <= word.length; i++) {
      keywords.add(word.substring(0, i));
    }
  }

  return keywords.toList();
}

/// ================= PAGE =================
class PropertyFormPage extends StatefulWidget {
  const PropertyFormPage({
    super.key,
    this.property,
    this.lat,
    this.lng,
  });
  final PropertyModel? property; // null = إضافة | not null = تعديل
  final double? lat;
  final double? lng;

  @override
  State<PropertyFormPage> createState() => _PropertyFormPageState();
}

class _PropertyFormPageState extends State<PropertyFormPage> {
  int step = 0;
  final _formKey = GlobalKey<FormState>();

  double? lat;
  double? lng;
  final ownerNameCtrl = TextEditingController();
  final ownerPhoneCtrl = TextEditingController();
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
      ownerNameCtrl.text = p.ownerName;
      ownerPhoneCtrl.text = p.ownerPhone;
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
    ownerNameCtrl.dispose();
    ownerPhoneCtrl.dispose();
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
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _show('يجب تسجيل الدخول أولاً');
        return;
      }

      if (lat == null || lng == null) {
        _show('حدد موقع العقار على الخريطة');
        return;
      }

      final uid = user.uid;
      final propertyId = widget.property?.id ?? propertyService.newPropertyId();
      debugPrint('STEP 1');
      final uploadedPaths = <String>[];

      for (final img in pickedImages) {
        debugPrint('IMAGE PATH: ${img.path}');

        final path = await storageService.uploadImage(
          file: img,
          folder: 'properties/$propertyId',
          fileName: img.name,
        );

        debugPrint('UPLOAD RESULT: $path');

        if (path.isNotEmpty) {
          uploadedPaths.add(path);
        }
      }

      final keywords = buildSearchKeywords(titleCtrl.text);
      debugPrint('FINAL IMAGES: $uploadedPaths');
      debugPrint('STEP 2');
      final property = PropertyModel(
        id: propertyId,
        ownerId: uid,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        price: double.tryParse(
              priceCtrl.text.replaceAll(',', ''),
            ) ??
            0,
        type: type,
        purpose: purpose,
        city: cityCtrl.text.trim(),
        area: areaCtrl.text.trim(),
        mediaPaths: uploadedPaths.isNotEmpty ? uploadedPaths : (widget.property?.mediaPaths ?? []),
        mainImage:
            uploadedPaths.isNotEmpty ? uploadedPaths.first : (widget.property?.mainImage ?? ''),
        searchKeywords: keywords,
        createdAt: widget.property?.createdAt ?? Timestamp.now(),
        updatedAt: Timestamp.now(),
        lat: lat,
        lng: lng,
        favoritesCount: widget.property?.favoritesCount ?? 0,
        ownerName: ownerNameCtrl.text.trim(),
        ownerPhone: ownerPhoneCtrl.text.trim(),
      );

      if (widget.property == null) {
        debugPrint('STEP 4');
        await propertyService.createProperty(property);
        debugPrint('STEP 5 SUCCESS');
      } else {
        debugPrint('STEP 4 UPDATE');
        await propertyService.updateProperty(property);
        debugPrint('STEP 5 UPDATE SUCCESS');
      }

      if (!mounted) return;
      _show(
        Localizations.localeOf(context).languageCode == 'ar'
            ? widget.property == null
                ? '✅ تم إضافة العقار بنجاح'
                : '✅ تم تحديث العقار بنجاح'
            : widget.property == null
                ? '✅ Property added successfully'
                : '✅ Property updated successfully',
      );
      await Future.delayed(
        const Duration(milliseconds: 700),
      );
      Navigator.pop(context, true);
    } catch (e, stack) {
      debugPrint('PROPERTY SAVE ERROR: $e');
      debugPrintStack(stackTrace: stack);

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
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(widget.property == null ? 'إضافة عقار' : 'تعديل العقار'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Progress
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: LinearProgressIndicator(
                              value: (step + 1) / 4,
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: _buildStep(),
                          ),
                          _buildBottomNavigationBar(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (saving)
          const ColoredBox(
            color: Colors.black26,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  // ================= Widgets =================
  Widget _ultraInput(
    TextEditingController c,
    String label, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.red),
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

  Widget _buildStep() {
    switch (step) {
      case 0:
        return _stepBasic();
      case 1:
        return _stepDetails();
      case 2:
        return _stepImages();
      case 3:
        return _stepLocation();
      default:
        return const SizedBox();
    }
  }

  Widget _stepBasic() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _stepTitle('المعلومات الأساسية'),
          _ultraInput(titleCtrl, 'العنوان', icon: Icons.home),
          _ultraInput(descCtrl, 'الوصف', maxLines: 3),
          _ultraInput(ownerNameCtrl, 'اسم المالك', icon: Icons.person),
          _ultraInput(
            ownerPhoneCtrl,
            'هاتف المالك',
            icon: Icons.phone,
            keyboard: TextInputType.phone,
          ),
          _ultraInput(priceCtrl, 'السعر', icon: Icons.attach_money, keyboard: TextInputType.number),
        ],
      ),
    );
  }

  Widget _stepDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ultraInput(priceCtrl, 'السعر', keyboard: TextInputType.number),
          _ultraInput(cityCtrl, 'المدينة'),
          _ultraInput(areaCtrl, 'المنطقة'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _dropdownType()),
              const SizedBox(width: 12),
              Expanded(child: _dropdownPurpose()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepImages() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...pickedImages.map(
            (x) => ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 80,
                height: 80,
                child: AdaptiveImage(
                  path: x.path,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepLocation() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          height: 400,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // 🗺️ MAP FULL
                Positioned.fill(
                  child: LocationPickerMap(
                    initialLat: lat,
                    initialLng: lng,
                    onPicked: (point) {
                      setState(() {
                        lat = point.latitude;
                        lng = point.longitude;
                      });
                    },
                  ),
                ),

                // 🌑 Overlay
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'اضغط على الخريطة لتحديد الموقع',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // 📍 Title فوق
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '📍 الموقع',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 10,
      ),
      child: Row(
        children: [
          if (step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => step--),
                child: const Text('رجوع'),
              ),
            ),
          if (step > 0) const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (step < 3) {
                  setState(() => step++);
                } else {
                  _save();
                }
              },
              child: Text(step == 3 ? 'حفظ' : 'التالي'),
            ),
          ),
        ],
      ),
    );
  }
}
