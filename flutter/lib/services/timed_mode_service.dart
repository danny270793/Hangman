import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimedModeService extends ChangeNotifier {
  static const String _timedModeKey = 'timed_mode_enabled';
  bool _isEnabled = false;

  bool get isEnabled => _isEnabled;

  /// Load the saved timed mode setting from storage
  Future<void> loadTimedMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_timedModeKey) ?? false;
    notifyListeners();
  }

  /// Set the timed mode and save to storage
  Future<void> setTimedMode(bool enabled) async {
    if (_isEnabled == enabled) return;

    _isEnabled = enabled;

    // Save to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_timedModeKey, enabled);

    notifyListeners();
  }
}
