<!-- # 🗺️ دليل إعداد Google Maps في التطبيق

تم إضافة ميزة Google Maps بنجاح لتطبيق العقارات! 

## ✅ ما تم إنجازه:

### 1️⃣ إضافة المكتبات المطلوبة
- ✅ `google_maps_flutter` - لعرض الخرائط
- ✅ `url_launcher` - لفتح Google Maps
- ✅ `geolocator` - لتحديد الموقع الحالي
- ✅ `permission_handler` - لإدارة الصلاحيات

### 2️⃣ تحديث نموذج البيانات
- ✅ إضافة `latitude` و `longitude` إلى `PropertyModel`
- ✅ يتم حفظ الإحداثيات تلقائياً في Hive

### 3️⃣ واجهة اختيار الموقع
- ✅ صفحة خريطة تفاعلية لاختيار الموقع
- ✅ زر للحصول على الموقع الحالي
- ✅ إمكانية النقر على الخريطة أو سحب العلامة

### 4️⃣ صفحة تفاصيل العقار
- ✅ عرض الموقع على خريطة مدمجة
- ✅ زر لفتح الموقع في تطبيق Google Maps
- ✅ عرض الإحداثيات الدقيقة

### 5️⃣ التكوينات
- ✅ Android: Permissions و Manifest
- ✅ iOS: Info.plist configurations

---

## 🔧 الخطوات المتبقية (مهم جداً):

### 1. الحصول على Google Maps API Key

#### لنظام Android:
1. اذهب إلى [Google Cloud Console](https://console.cloud.google.com/)
2. أنشئ مشروع جديد أو اختر مشروع موجود
3. فعّل **Maps SDK for Android**
4. اذهب إلى **APIs & Services > Credentials**
5. أنشئ **API Key** جديدة
6. قيّد الـ API Key لتطبيق Android فقط (للأمان)
7. انسخ الـ API Key

**افتح الملف:**
```
android/app/src/main/AndroidManifest.xml
```

**استبدل هذا السطر:**
```xml
android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

**بـ:**
```xml
android:value="AIzaSy...your-actual-key-here"/>
```

#### لنظام iOS:
1. في نفس Google Cloud Console
2. فعّل **Maps SDK for iOS**
3. استخدم نفس API Key أو أنشئ واحدة جديدة للـ iOS
4. قيّد الـ API Key لتطبيق iOS (Bundle ID)

**افتح الملف:**
```
ios/Runner/AppDelegate.swift
```

**أضف في بداية الملف:**
```swift
import GoogleMaps
```

**وداخل دالة `application` أضف:**
```swift
GMSServices.provideAPIKey("YOUR_IOS_API_KEY_HERE")
```

---

### 2. تثبيت المكتبات
قم بتشغيل هذه الأوامر في Terminal:

```bash
# تثبيت المكتبات
flutter pub get

# للـ iOS فقط:
cd ios
pod install
cd ..
```

---

### 3. ربط صفحة التفاصيل بالتطبيق

الصفحات الموجودة حالياً:
- `property_search_page.dart` - صفحة البحث
- `my_properties_page.dart` - عقاراتي

**يجب إضافة Navigation** عند الضغط على العقار للانتقال إلى صفحة التفاصيل:

```dart
// في property_search_page.dart أو my_properties_page.dart
import '../pages/property_detail_page.dart';

// عند الضغط على العقار:
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PropertyDetailPage(property: property),
    ),
  );
},
```

---

## 🎯 كيفية الاستخدام:

### للمستخدم:
1. **إضافة عقار جديد:**
   - افتح صفحة "إضافة عقار"
   - اضغط على "تحديد موقع العقار على الخريطة"
   - اضغط على أيقونة الموقع للحصول على موقعك الحالي
   - أو اضغط على أي مكان في الخريطة
   - يمكن سحب العلامة الحمراء لتعديل الموقع
   - اضغط "تأكيد الموقع"

2. **عرض تفاصيل العقار:**
   - اضغط على أي عقار من القائمة
   - شاهد الموقع على الخريطة المدمجة
   - اضغط "فتح الخريطة" أو أيقونة الاتجاهات
   - سيفتح تطبيق Google Maps مباشرة

---

## 🔒 ملاحظات الأمان:

1. **لا تنشر API Keys في Git:**
   - أضف `.env` file للـ keys
   - استخدم `flutter_dotenv` لقراءتها
   - أضف `.env` إلى `.gitignore`

2. **قيّد API Keys:**
   - قيّد Android Key بـ Package Name و SHA-1
   - قيّد iOS Key بـ Bundle ID
   - هذا يمنع استخدامها من تطبيقات أخرى

---

## 🧪 الاختبار:

### على Emulator:
- **Android Emulator:** يدعم Google Maps بشكل كامل
- **iOS Simulator:** يدعم Maps ولكن قد لا يدعم الموقع الحالي

### على جهاز حقيقي:
- تأكد من تفعيل GPS
- امنح التطبيق صلاحيات الموقع
- يُفضل الاختبار على جهاز حقيقي للحصول على أفضل نتائج

---

## 🐛 حل المشاكل الشائعة:

### 1. الخريطة لا تظهر (Android):
- تأكد من إضافة API Key الصحيحة
- تأكد من تفعيل Maps SDK for Android
- تحقق من أن API Key غير مقيدة بشكل خاطئ

### 2. الخريطة رمادية:
- مشكلة في API Key
- تحقق من Console Logs
- تأكد من تفعيل Billing في Google Cloud

### 3. لا يمكن الحصول على الموقع الحالي:
- تأكد من منح صلاحيات الموقع
- تحقق من تفعيل GPS
- على iOS: تأكد من إضافة Usage Descriptions

### 4. Google Maps لا يفتح:
- تأكد من تثبيت تطبيق Google Maps
- على iOS: تأكد من إضافة URL Schemes

---

## 📱 متطلبات إضافية (اختيارية):

### لتحسين الأداء:
```yaml
# في pubspec.yaml، يمكن إضافة:
google_maps_flutter_web: ^0.5.4  # للدعم على الويب
location: ^5.0.0                 # بديل للـ geolocator
geocoding: ^2.1.1                # لتحويل الإحداثيات إلى عناوين
```

### للحصول على عنوان من الإحداثيات:
```dart
import 'package:geocoding/geocoding.dart';

Future<String> getAddressFromCoordinates(double lat, double lng) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      return "${place.street}, ${place.locality}, ${place.country}";
    }
  } catch (e) {
    print("Error: $e");
  }
  return "عنوان غير معروف";
}
```

---

## ✨ الميزات المضافة:

- ✅ اختيار الموقع من الخريطة بالنقر
- ✅ الحصول على الموقع الحالي تلقائياً
- ✅ سحب العلامة لتعديل الموقع
- ✅ عرض الإحداثيات بشكل واضح
- ✅ خريطة مدمجة في صفحة التفاصيل
- ✅ زر لفتح Google Maps مباشرة
- ✅ حفظ الإحداثيات في Hive
- ✅ دعم RTL كامل

---

## 🚀 الخطوات التالية الموصى بها:

1. احصل على Google Maps API Key (ضروري)
2. قم بتشغيل `flutter pub get`
3. أضف Navigation لصفحة التفاصيل
4. اختبر على جهاز حقيقي
5. (اختياري) أضف مكتبة `geocoding` لعرض العناوين

---

**تم بناء الميزة بالكامل وجاهزة للاستخدام! 🎉**

فقط أضف API Key وقم بتشغيل التطبيق. -->
