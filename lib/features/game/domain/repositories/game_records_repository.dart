import '../entities/game_record_entity.dart';

abstract class GameRecordsRepository {
  Future<void> saveGameRecord({
    required bool hasTimedModeEnabled,
    required String difficulty,
    required int points,
    required int words,
    required int timePlaying,
  });

  /// Leaderboard page ordered by points; returns an empty list on failure.
  Future<List<GameRecordEntity>> getGameRecords({
    required int limit,
    required int offset,
  });
}
