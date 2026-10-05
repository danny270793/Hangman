import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  const AuthRepositoryImpl(this._datasource);

  @override
  UserEntity? get currentUser => _datasource.currentUser;

  @override
  Stream<void> get authStateChanges => _datasource.authStateChanges;

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) => _datasource.signIn(email: email, password: password);

  @override
  Future<void> signUp({
    required String email,
    required String password,
    String? username,
  }) =>
      _datasource.signUp(email: email, password: password, username: username);

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Future<void> updateEmail({required String newEmail}) =>
      _datasource.updateEmail(newEmail: newEmail);

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) => _datasource.updatePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );

  @override
  Future<void> updateUsername({required String newUsername}) =>
      _datasource.updateUsername(newUsername: newUsername);
}
