<!-- # 🎯 خطوات سريعة لتشغيل Google Maps

## ⚡️ الخطوات الأساسية (3 دقائق):

### 1️⃣ احصل على Google Maps API Key

1. اذهب إلى: https://console.cloud.google.com/
2. أنشئ مشروع أو اختر مشروع موجود
3. فعّل APIs التالية:
   - ✅ **Maps SDK for Android**
   - ✅ **Maps SDK for iOS**
4. اذهب إلى: **APIs & Services → Credentials**
5. اضغط **Create Credentials → API Key**
6. انسخ الـ API Key

---

### 2️⃣ أضف API Key للأندرويد

**افتح:** `android/app/src/main/AndroidManifest.xml`

**ابحث عن السطر:**
```xml
android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

**استبدله بـ:**
```xml
android:value="AIzaSy...المفتاح-الذي-حصلت-عليه"/>
```

---

### 3️⃣ أضف API Key للـ iOS

**افتح:** `ios/Runner/AppDelegate.swift`

**في بداية الملف أضف:**
```swift
import GoogleMaps
```

**داخل دالة `application` أضف قبل `return`:**
```swift
GMSServices.provideAPIKey("AIzaSy...المفتاح-الذي-حصلت-عليه")
```

مثال كامل:
```swift
import UIKit
import Flutter
import GoogleMaps  // ← أضف هنا

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSy...المفتاح")  // ← أضف هنا
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

### 4️⃣ للـ iOS فقط: تثبيت Pods

```bash
cd ios
pod install
cd ..
```

---

### 5️⃣ جرّب التطبيق!

```bash
# Android
flutter run

# iOS
flutter run -d "اسم-الجهاز"
```

---

## ✨ ما تم إضافته:

1. ✅ **في صفحة إضافة العقار:**
   - زر "تحديد موقع العقار على الخريطة"
   - يفتح خريطة تفاعلية
   - يمكن الضغط على أي مكان أو سحب العلامة
   - زر للحصول على الموقع الحالي

2. ✅ **في صفحة تفاصيل العقار:**
   - خريطة مدمجة تعرض الموقع
   - زر "فتح الخريطة" يفتح Google Maps
   - عرض الإحداثيات الدقيقة
   - أيقونة Location في القائمة للعقارات التي لها موقع

3. ✅ **الإحداثيات:**
   - يتم حفظها تلقائياً في Hive مع العقار
   - يمكن إضافتها أو حذفها في أي وقت

---

## 🔧 إعدادات إضافية (اختياري):

### لجعل API Key أكثر أماناً:

في Google Cloud Console:
1. اضغط على API Key
2. اختر **Application restrictions**:
   - **Android:** أضف Package Name + SHA-1
   - **iOS:** أضف Bundle ID
3. **API restrictions:** اختر فقط:
   - Maps SDK for Android
   - Maps SDK for iOS

### للحصول على SHA-1 (Android):

```bash
cd android
./gradlew signingReport
```

---

## 🐛 حل المشاكل:

### الخريطة رمادية أو لا تظهر:
- ❌ API Key خاطئ
- ❌ لم يتم تفعيل APIs
- ✅ تحقق من Console في Android Studio / Xcode

### لا يمكن الحصول على الموقع:
- ❌ لم يتم منح صلاحيات الموقع
- ❌ GPS مغلق
- ✅ امنح الصلاحيات عند الطلب

### Google Maps لا يفتح:
- ❌ تطبيق Google Maps غير مثبت
- ✅ ثبّت Google Maps من Play Store / App Store

---

## 📂 الملفات التي تم إنشاؤها/تعديلها:

### ملفات جديدة:
- ✅ `lib/shared/widgets/location_picker_widget.dart`
- ✅ `lib/features/realestate/pages/property_detail_page.dart`
- ✅ `GOOGLE_MAPS_SETUP.md` (دليل مفصّل)

### ملفات محدّثة:
- ✅ `pubspec.yaml`
- ✅ `lib/features/realestate/models/property_model.dart`
- ✅ `lib/features/realestate/pages/property_add_page.dart`
- ✅ `lib/features/realestate/pages/property_search_page.dart`
- ✅ `lib/features/realestate/pages/my_properties_page.dart`
- ✅ `android/app/src/main/AndroidManifest.xml`
- ✅ `ios/Runner/Info.plist`

---

## 📱 اختبر الميزات:

1. **أضف عقار جديد** مع موقع
2. **شاهد العقار** في قائمة البحث (أيقونة Location)
3. **اضغط على العقار** لفتح التفاصيل
4. **شاهد الخريطة** في صفحة التفاصيل
5. **اضغط "فتح الخريطة"** لفتح Google Maps

---

**🚀 جاهز للاستخدام بعد إضافة API Key!**

للمزيد من التفاصيل: راجع `GOOGLE_MAPS_SETUP.md` -->
