import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const _key = 'app_language';

  Locale _locale = const Locale('en');
  TextDirection _direction = TextDirection.ltr;

  Locale get locale => _locale;
  TextDirection get textDirection => _direction;
  bool get isArabic => _locale.languageCode == 'ar';

  LanguageProvider() {
    _loadLanguage();
  }

  /// 🔁 Toggle language
  Future<void> toggleLanguage() async {
    if (isArabic) {
      await setEnglish();
    } else {
      await setArabic();
    }
  }

  /// 🇸🇦 Arabic
  Future<void> setArabic() async {
    _locale = const Locale('ar');
    _direction = TextDirection.rtl;
    await _save('ar');
    notifyListeners();
  }

  /// 🇺🇸 English
  Future<void> setEnglish() async {
    _locale = const Locale('en');
    _direction = TextDirection.ltr;
    await _save('en');
    notifyListeners();
  }

  /// 💾 Save to local storage
  Future<void> _save(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }

  /// 📥 Load on app start
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';

    if (code == 'ar') {
      _locale = const Locale('ar');
      _direction = TextDirection.rtl;
    } else {
      _locale = const Locale('en');
      _direction = TextDirection.ltr;
    }

    notifyListeners();
  }
}
