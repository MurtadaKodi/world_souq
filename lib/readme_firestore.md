<!-- # 🔥 Firestore Queries & Indexes Guide

هذا الملف يوضح **جميع استعلامات Firestore (Queries)** في المشروع، وما إذا كانت تحتاج إلى **Composite Index** أم لا.

---

## 🛒 Marketplace – Items

### 📄 item_storage_service.dart
```dart
.collection('items')
.where('ownerId', isEqualTo: uid)
.orderBy('createdAt', descending: true)
```
**Index مطلوب:**
| Field | Order |
|------|------|
| ownerId | Ascending |
| createdAt | Descending |

---

```dart
.collection('items')
.orderBy('createdAt', descending: true)
```
✅ لا يحتاج Index

---

## ❤️ Favorites

### 📄 item_storage_service.dart
```dart
.collection('users')
.doc(uid)
.collection('favorites')
.orderBy('createdAt', descending: true)
```
✅ لا يحتاج Index (subcollection)

---

## 🏠 Real Estate – Bookings

### 📄 booking_service.dart (Conflict check)
```dart
.collection('bookings')
.where('propertyId', isEqualTo: id)
.where('visitDate', isEqualTo: date)
.where('visitTime', isEqualTo: time)
```
**Index مطلوب:**
| Field | Order |
|------|------|
| propertyId | Ascending |
| visitDate | Ascending |
| visitTime | Ascending |

---

### 📄 bookings_page.dart / admin_bookings_page.dart
```dart
.collection('bookings')
.orderBy('createdAt', descending: true)
```
✅ لا يحتاج Index

---

### 📄 owner_bookings_page.dart
```dart
.collection('bookings')
.where('propertyOwnerId', isEqualTo: uid)
.orderBy('createdAt', descending: true)
```
**Index مطلوب:**
| Field | Order |
|------|------|
| propertyOwnerId | Ascending |
| createdAt | Descending |

---

## 👤 Admin – Users

### 📄 admin_users_page.dart
```dart
.collection('users')
.orderBy('createdAt', descending: true)
```
✅ لا يحتاج Index

---

## 🚨 ملاحظات مهمة
- أي استعلام يحتوي على `where + orderBy` يحتاج **Composite Index**
- Firestore يعطيك رابط مباشر لإنشاء Index عند الخطأ
- بعد إنشاء Index انتظر حتى يصبح **Enabled**

---

## ✅ Checklist قبل التشغيل
- [ ] كل Index في Firebase Console = Enabled
- [ ] لا يوجد Index بحالة Building
- [ ] لا يوجد Page بيضاء عند الفتح

---

✍️ هذا الملف مرجع داخلي للمشروع
 -->
