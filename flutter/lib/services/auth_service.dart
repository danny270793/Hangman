import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  bool get isAuthenticated =>
      Supabase.instance.client.auth.currentSession != null;

  User? get currentUser => Supabase.instance.client.auth.currentUser;

  Future<void> loadAuth() async {
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
    notifyListeners();
  }

  Future<String?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return null; // Success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: username != null ? {'username': username} : null,
      );
      notifyListeners();
      return null; // Success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    notifyListeners();
  }

  String? get userEmail => currentUser?.email;

  String? get userName {
    final metadata = currentUser?.userMetadata;
    return metadata?['username'] as String?;
  }
}
