import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/difficulty/app_difficulty_controller.dart';
import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/word_entity.dart';
import '../../domain/usecases/get_words_usecase.dart';
import '../../domain/usecases/pick_random_word_usecase.dart';
import '../../domain/usecases/save_game_record_usecase.dart';
import 'game_state.dart';

/// Loads the word list for a game session, picks words and saves records.
///
/// Turn-by-turn gameplay (guesses, timer, score) lives in the game page.
class GameCubit extends Cubit<GameState> {
  final GetWordsUsecase _getWords;
  final PickRandomWordUsecase _pickRandomWord;
  final SaveGameRecordUsecase _saveGameRecord;

  GameCubit({
    required this._getWords,
    required this._pickRandomWord,
    required this._saveGameRecord,
  }) : super(const GameLoading());

  Future<void> loadWords({required String locale}) async {
    emit(const GameLoading());
    final words = await _getWords(locale: locale);
    if (isClosed) return;
    emit(GameReady(words));
  }

  WordEntity pickWord(GameDifficulty difficulty) {
    final current = state;
    final words = current is GameReady ? current.words : kFallbackWords;
    return _pickRandomWord(words, difficulty);
  }

  /// Returns `null` on success or an error description.
  Future<String?> saveGameRecord({
    required bool hasTimedModeEnabled,
    required GameDifficulty difficulty,
    required int points,
    required int words,
    required int timePlaying,
  }) async {
    try {
      await _saveGameRecord(
        hasTimedModeEnabled: hasTimedModeEnabled,
        difficulty: difficulty.apiValue,
        points: points,
        words: words,
        timePlaying: timePlaying,
      );
      return null;
    } catch (e, s) {
      AppLogger.error('failed to save game record', e, s);
      return e.toString();
    }
  }
}
