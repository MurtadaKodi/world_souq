// // lib/shared/utils/image_url_helper.dart

// String resolveImageUrl(String path) {
//   if (path.isEmpty) return '';

//   // توافق مع البيانات القديمة فقط
//   if (path.startsWith('http')) {
//     return path;
//   }

//   // ✅ المسار عبر Firebase Hosting (NO CORS)
//   return '/images/$path';
// }
