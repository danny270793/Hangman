import '../repositories/game_records_repository.dart';

class SaveGameRecordUsecase {
  final GameRecordsRepository _repository;

  const SaveGameRecordUsecase(this._repository);

  Future<void> call({
    required bool hasTimedModeEnabled,
    required String difficulty,
    required int points,
    required int words,
    required int timePlaying,
  }) => _repository.saveGameRecord(
    hasTimedModeEnabled: hasTimedModeEnabled,
    difficulty: difficulty,
    points: points,
    words: words,
    timePlaying: timePlaying,
  );
}
