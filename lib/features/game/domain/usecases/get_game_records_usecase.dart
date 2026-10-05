import '../entities/game_record_entity.dart';
import '../repositories/game_records_repository.dart';

class GetGameRecordsUsecase {
  final GameRecordsRepository _repository;

  const GetGameRecordsUsecase(this._repository);

  Future<List<GameRecordEntity>> call({int limit = 20, int offset = 0}) =>
      _repository.getGameRecords(limit: limit, offset: offset);
}
