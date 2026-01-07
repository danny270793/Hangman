import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static const String _authKey = 'is_authenticated';
  bool isAuthenticated = false;

  Future<void> loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final auth = prefs.getBool(_authKey);
    if (auth != null) {
      isAuthenticated = auth;
    } else {
      await prefs.setBool(_authKey, false);
    }
    notifyListeners();
  }

  Future<void> login() async {
    isAuthenticated = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, true);
    notifyListeners();
  }

  Future<void> logout() async {
    isAuthenticated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, false);
    notifyListeners();
  }
}
