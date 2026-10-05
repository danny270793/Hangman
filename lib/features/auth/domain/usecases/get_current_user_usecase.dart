import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  final AuthRepository _repository;

  const GetCurrentUserUsecase(this._repository);

  UserEntity? call() => _repository.currentUser;
}
