import '../repositories/auth_repository.dart';

class SignUpUsecase {
  final AuthRepository _repository;

  const SignUpUsecase(this._repository);

  Future<void> call({
    required String email,
    required String password,
    String? username,
  }) =>
      _repository.signUp(email: email, password: password, username: username);
}
