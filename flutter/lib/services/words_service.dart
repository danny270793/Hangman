import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Word {
  final String word;
  final List<String> tags;

  Word({required this.word, required this.tags});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }
}

class WordsService {
  List<Word>? _words;
  bool _isLoaded = false;
  String _currentLocale = 'en';

  Future<void> loadWords({String locale = 'en'}) async {
    // Reload if locale changed
    if (_isLoaded && _currentLocale == locale) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/words_$locale.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> wordsJson = jsonData['words'] as List<dynamic>;

      _words = wordsJson
          .map((wordJson) => Word.fromJson(wordJson as Map<String, dynamic>))
          .toList();
      _currentLocale = locale;
      _isLoaded = true;
    } catch (e) {
      // If loading fails, use fallback words
      _words = _getFallbackWords();
      _isLoaded = true;
    }
  }

  List<Word> getAllWords() {
    return _words ?? _getFallbackWords();
  }

  Word getRandomWord() {
    final words = getAllWords();
    final random = words.toList()..shuffle();
    return random.first;
  }

  List<Word> searchByTag(String tag) {
    final words = getAllWords();
    return words
        .where(
          (word) =>
              word.tags.any((t) => t.toLowerCase().contains(tag.toLowerCase())),
        )
        .toList();
  }

  List<Word> getWordsByDifficulty(int minLength, int maxLength) {
    final words = getAllWords();
    return words
        .where(
          (word) =>
              word.word.length >= minLength && word.word.length <= maxLength,
        )
        .toList();
  }

  /// Calculate the difficulty of a word based on the number of unique letters
  /// Returns a value from 0.0 (easiest) to 1.0 (hardest)
  /// More unique letters = harder to guess
  double getWordDifficulty(String word) {
    final uniqueLetters = word.toUpperCase().split('').toSet().length;
    final totalLetters = word.length;
    
    // Normalize to 0.0 - 1.0 range
    // Words with all unique letters are hardest (ratio = 1.0)
    // Words with many repeated letters are easier (ratio closer to 0)
    return uniqueLetters / totalLetters;
  }

  /// Get the difficulty category based on unique letter ratio
  /// Easy: < 0.65 (many repeated letters)
  /// Medium: 0.65 - 0.85 (some repeated letters)
  /// Hard: > 0.85 (mostly unique letters)
  String getWordDifficultyCategory(String word) {
    final difficulty = getWordDifficulty(word);
    
    if (difficulty < 0.65) {
      return 'easy';
    } else if (difficulty < 0.85) {
      return 'medium';
    } else {
      return 'hard';
    }
  }

  /// Get the count of unique letters in a word
  int getUniqueLetterCount(String word) {
    return word.toUpperCase().split('').toSet().length;
  }

  // Fallback words in case JSON fails to load
  List<Word> _getFallbackWords() {
    return [
      Word(
        word: 'piano',
        tags: [
          'musical instrument',
          'keyboard instrument',
          'instrument played by beethoven',
          'has 88 keys',
          'classical music',
        ],
      ),
      Word(
        word: 'guitar',
        tags: [
          'musical instrument',
          'string instrument',
          'has six strings',
          'used in rock music',
          'acoustic or electric',
        ],
      ),
      Word(
        word: 'elephant',
        tags: [
          'large mammal',
          'has a trunk',
          'largest land animal',
          'lives in africa and asia',
          'never forgets',
        ],
      ),
      Word(
        word: 'dolphin',
        tags: [
          'marine mammal',
          'intelligent creature',
          'lives in ocean',
          'playful animal',
          'uses echolocation',
        ],
      ),
      Word(
        word: 'apple',
        tags: [
          'fruit',
          'grows on trees',
          'red green or yellow',
          'keeps the doctor away',
          'crispy and sweet',
        ],
      ),
      Word(
        word: 'banana',
        tags: [
          'tropical fruit',
          'yellow when ripe',
          'high in potassium',
          'grows in bunches',
          'monkeys favorite',
        ],
      ),
      Word(
        word: 'doctor',
        tags: [
          'medical professional',
          'treats patients',
          'works in hospital',
          'helps sick people',
          'wears white coat',
        ],
      ),
      Word(
        word: 'teacher',
        tags: [
          'educator',
          'works in school',
          'teaches students',
          'shares knowledge',
          'grades homework',
        ],
      ),
    ];
  }
}
