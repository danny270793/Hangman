import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/user_entity.dart';

/// Thrown when the current password supplied to change the password is wrong.
class InvalidCurrentPasswordException implements Exception {
  const InvalidCurrentPasswordException();
}

abstract class AuthRemoteDatasource {
  UserEntity? get currentUser;
  Stream<void> get authStateChanges;
  Future<UserEntity> signIn({required String email, required String password});
  Future<void> signUp({
    required String email,
    required String password,
    String? username,
  });
  Future<void> signOut();
  Future<void> updateEmail({required String newEmail});
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> updateUsername({required String newUsername});
}

class AuthSupabaseDatasource implements AuthRemoteDatasource {
  final SupabaseClient _client;

  const AuthSupabaseDatasource(this._client);

  static UserEntity _toEntity(User user) => UserEntity(
    id: user.id,
    email: user.email ?? '',
    username: user.userMetadata?['username'] as String?,
  );

  @override
  UserEntity? get currentUser {
    final user = _client.auth.currentUser;
    return user == null ? null : _toEntity(user);
  }

  @override
  Stream<void> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    AppLogger.debug('signIn called');
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) throw Exception();
    return _toEntity(user);
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    AppLogger.debug('signUp called');
    await _client.auth.signUp(
      email: email,
      password: password,
      data: username != null ? {'username': username} : null,
    );
  }

  @override
  Future<void> signOut() {
    AppLogger.debug('signOut called');
    return _client.auth.signOut();
  }

  @override
  Future<void> updateEmail({required String newEmail}) async {
    AppLogger.debug('updateEmail called');
    await _client.auth.updateUser(UserAttributes(email: newEmail));
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    AppLogger.debug('updatePassword called');
    final email = _client.auth.currentUser?.email;
    if (email == null) throw const InvalidCurrentPasswordException();
    // Verify the current password by signing in again before changing it.
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
    } on AuthException {
      throw const InvalidCurrentPasswordException();
    }
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<void> updateUsername({required String newUsername}) async {
    AppLogger.debug('updateUsername called');
    await _client.auth.updateUser(
      UserAttributes(data: {'username': newUsername}),
    );
  }
}
