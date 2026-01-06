import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get themeMode => _themeMode;

  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  /// Load the saved theme from storage
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey);
    
    if (themeString != null) {
      _themeMode = AppThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeString,
        orElse: () => AppThemeMode.system,
      );
      notifyListeners();
    }
  }

  /// Set the theme and save to storage
  Future<void> setTheme(AppThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    
    // Save to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString());
    
    notifyListeners();
  }
}

