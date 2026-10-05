import '../../../../core/difficulty/app_difficulty_controller.dart';
import '../entities/word_entity.dart';

/// Picks a random word filtered by difficulty category.
/// Easy: 1-50, Medium: 51-60, Hard: 61-100
class PickRandomWordUsecase {
  const PickRandomWordUsecase();

  WordEntity call(List<WordEntity> words, GameDifficulty difficulty) {
    final allWords = words.isEmpty ? kFallbackWords : words;

    final (minDifficulty, maxDifficulty) = switch (difficulty) {
      GameDifficulty.easy => (1, 50),
      GameDifficulty.medium => (51, 60),
      GameDifficulty.hard => (61, 100),
    };

    final filteredWords = allWords
        .where(
          (word) =>
              word.difficultyValue >= minDifficulty &&
              word.difficultyValue <= maxDifficulty,
        )
        .toList();

    // If no words match the difficulty, fall back to all words
    if (filteredWords.isEmpty) {
      final random = allWords.toList()..shuffle();
      return random.first;
    }

    filteredWords.shuffle();
    return filteredWords.first;
  }
}
