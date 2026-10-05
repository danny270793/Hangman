import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/core/difficulty/app_difficulty_controller.dart';
import 'package:hangman/core/locale/app_locale_controller.dart';
import 'package:hangman/core/theme/app_theme_controller.dart';
import 'package:hangman/core/timed_mode/app_timed_mode_controller.dart';
import 'package:hangman/features/game/domain/entities/word_entity.dart';
import 'package:hangman/features/game/domain/usecases/pick_random_word_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('preference controllers', () {
    test('read values stored by previous app versions', () async {
      SharedPreferences.setMockInitialValues({
        'app_locale': 'es',
        'app_theme_mode': 'AppThemeMode.dark',
        'game_difficulty': 'GameDifficulty.hard',
        'timed_mode_enabled': true,
      });

      final locale = AppLocaleController();
      final theme = AppThemeController();
      final difficulty = AppDifficultyController();
      final timed = AppTimedModeController();
      await locale.load();
      await theme.load();
      await difficulty.load();
      await timed.load();

      expect(locale.preference, AppLanguagePreference.es);
      expect(theme.preference, AppThemePreference.dark);
      expect(difficulty.difficulty, GameDifficulty.hard);
      expect(timed.enabled, isTrue);
    });

    test('default to system / medium / untimed', () async {
      SharedPreferences.setMockInitialValues({});

      final locale = AppLocaleController();
      final theme = AppThemeController();
      final difficulty = AppDifficultyController();
      final timed = AppTimedModeController();
      await locale.load();
      await theme.load();
      await difficulty.load();
      await timed.load();

      expect(locale.preference, AppLanguagePreference.system);
      expect(theme.preference, AppThemePreference.system);
      expect(difficulty.difficulty, GameDifficulty.medium);
      expect(timed.enabled, isFalse);
    });
  });

  group('PickRandomWordUsecase', () {
    const pick = PickRandomWordUsecase();

    test('picks a word within the difficulty range', () {
      for (var i = 0; i < 20; i++) {
        final word = pick(kFallbackWords, GameDifficulty.easy);
        expect(word.difficultyValue, inInclusiveRange(1, 50));
      }
    });

    test('falls back to any word when no word matches', () {
      final word = pick(kFallbackWords, GameDifficulty.hard);
      expect(kFallbackWords, contains(word));
    });
  });
}
