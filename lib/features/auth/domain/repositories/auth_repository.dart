import '../entities/user_entity.dart';

abstract class AuthRepository {
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
