import 'package:supabase_flutter/supabase_flutter.dart';

class GameRecordService {
  final _supabase = Supabase.instance.client;

  Future<String?> saveGameRecord({
    required bool hasTimedModeEnabled,
    required String difficulty,
    required int points,
    required int words,
    required int timePlaying,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return 'User not authenticated';
      }

      // Get username from user metadata
      final username = _supabase.auth.currentUser?.userMetadata?['username'] as String? ?? 'Player';

      await _supabase.from('game_records').insert({
        'username': username,
        'has_timed_mode_enabled': hasTimedModeEnabled,
        'difficulty': difficulty,
        'points': points,
        'words': words,
        'time_playing': timePlaying,
      });

      return null; // Success
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getUserGameRecords() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final response = await _supabase
          .from('game_records')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllGameRecords({int limit = 100}) async {
    try {
      final response = await _supabase
          .from('game_records')
          .select()
          .order('points', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}

