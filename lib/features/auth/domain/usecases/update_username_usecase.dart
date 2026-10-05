import '../repositories/auth_repository.dart';

class UpdateUsernameUsecase {
  final AuthRepository _repository;

  const UpdateUsernameUsecase(this._repository);

  Future<void> call({required String newUsername}) =>
      _repository.updateUsername(newUsername: newUsername.trim());
}
