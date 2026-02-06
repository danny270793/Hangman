import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  Locale _locale;

  LocaleService({Locale? initialLocale})
      : _locale = initialLocale ?? const Locale('en');

  Locale get locale => _locale;

  /// Load the saved locale from storage, falling back to device locale if not set
  Future<void> loadLocale({Locale? deviceLocale}) async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);

    if (languageCode != null) {
      _locale = Locale(languageCode);
    } else if (deviceLocale != null) {
      // Use device locale if no saved preference exists
      _locale = deviceLocale;
    }
    notifyListeners();
  }

  /// Set the locale and save to storage
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;

    // Save to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);

    notifyListeners();
  }

  /// Set locale from language code string
  Future<void> setLocaleFromLanguageCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }
}
