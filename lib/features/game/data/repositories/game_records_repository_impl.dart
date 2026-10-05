import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/game_record_entity.dart';
import '../../domain/repositories/game_records_repository.dart';
import '../datasources/game_records_remote_datasource.dart';

class GameRecordsRepositoryImpl implements GameRecordsRepository {
  final GameRecordsRemoteDatasource _datasource;

  const GameRecordsRepositoryImpl(this._datasource);

  @override
  Future<void> saveGameRecord({
    required bool hasTimedModeEnabled,
    required String difficulty,
    required int points,
    required int words,
    required int timePlaying,
  }) => _datasource.saveGameRecord(
    hasTimedModeEnabled: hasTimedModeEnabled,
    difficulty: difficulty,
    points: points,
    words: words,
    timePlaying: timePlaying,
  );

  @override
  Future<List<GameRecordEntity>> getGameRecords({
    required int limit,
    required int offset,
  }) async {
    try {
      return await _datasource.getGameRecords(limit: limit, offset: offset);
    } catch (e, s) {
      AppLogger.error('failed to load game records', e, s);
      return const [];
    }
  }
}
