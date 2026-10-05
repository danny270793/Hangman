import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/game_record_entity.dart';

class NotAuthenticatedException implements Exception {
  const NotAuthenticatedException();

  @override
  String toString() => 'User not authenticated';
}

abstract class GameRecordsRemoteDatasource {
  Future<void> saveGameRecord({
    required bool hasTimedModeEnabled,
    required String difficulty,
    required int points,
    required int words,
    required int timePlaying,
  });

  Future<List<GameRecordEntity>> getGameRecords({
    required int limit,
    required int offset,
  });
}

class GameRecordsSupabaseDatasource implements GameRecordsRemoteDatasource {
  final SupabaseClient _client;

  const GameRecordsSupabaseDatasource(this._client);

  @override
  Future<void> saveGameRecord({
    required bool hasTimedModeEnabled,
    required String difficulty,
    required int points,
    required int words,
    required int timePlaying,
  }) async {
    AppLogger.debug('saveGameRecord called');
    if (_client.auth.currentUser?.id == null) {
      throw const NotAuthenticatedException();
    }
    await _client.from('game_records').insert({
      'has_timed_mode_enabled': hasTimedModeEnabled,
      'difficulty': difficulty,
      'points': points,
      'words': words,
      'time_playing': timePlaying,
    });
  }

  @override
  Future<List<GameRecordEntity>> getGameRecords({
    required int limit,
    required int offset,
  }) async {
    AppLogger.debug('getGameRecords called (offset $offset)');
    // Query from the view that joins with auth.users to get usernames
    final response = await _client
        .from('game_records_with_usernames')
        .select()
        .order('points', ascending: false)
        .range(offset, offset + limit - 1);
    return List<Map<String, dynamic>>.from(response)
        .map(
          (record) => GameRecordEntity(
            username: record['username'] as String? ?? 'Player',
            points: record['points'] as int,
            words: record['words'] as int,
            timePlaying: record['time_playing'] as int,
            difficulty: record['difficulty'] as String,
            hasTimedModeEnabled: record['has_timed_mode_enabled'] as bool,
          ),
        )
        .toList();
  }
}
