import 'package:supabase_flutter/supabase_flutter.dart';

class Word {
  final int id;
  final String word;
  final int difficultyValue;
  final String locale;
  final List<String> tags;

  Word({
    required this.id,
    required this.word,
    required this.difficultyValue,
    required this.locale,
    required this.tags,
  });

  /// Remove accents from a string, but keep Ñ/ñ
  /// Example: "café" -> "cafe", "árbol" -> "arbol", "niño" -> "niño"
  static String _removeAccents(String text) {
    const withAccents = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿ';
    const withoutAccents =
        'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeCcIIIIiiiiUUUUuuuuy';

    String result = text;
    for (int i = 0; i < withAccents.length; i++) {
      result = result.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return result;
  }

  factory Word.fromJson(Map<String, dynamic> json) {
    final originalWord = json['word'] as String;
    final wordWithoutAccents = _removeAccents(originalWord);

    // Parse tags array from JSON
    final tagsList = json['tags'] as List<dynamic>?;
    final tags = tagsList?.map((e) => e as String).toList() ?? [];

    return Word(
      id: json['id'] as int,
      word: wordWithoutAccents,
      difficultyValue: json['difficulty_value'] as int,
      locale: json['locale'] as String,
      tags: tags,
    );
  }
}

class WordsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Word>? _words;
  bool _isLoaded = false;
  String _currentLocale = 'en';

  Future<void> loadWords({String locale = 'en'}) async {
    // Reload if locale changed
    if (_isLoaded && _currentLocale == locale) return;

    try {
      // Query words for the specified locale
      final wordsResponse = await _supabase
          .from('words')
          .select('id, word, difficulty_value, locale')
          .eq('locale', locale);

      final List<Word> loadedWords = [];

      // For each word, fetch its tags
      for (final wordJson in wordsResponse as List<dynamic>) {
        final wordId = wordJson['id'] as int;

        // Query tags through the junction table
        final tagsResponse = await _supabase
            .from('word_tags')
            .select('tag_id, tags(tag)')
            .eq('word_id', wordId);

        final tags = <String>[];
        for (final tagData in tagsResponse as List<dynamic>) {
          final tagInfo = tagData['tags'] as Map<String, dynamic>?;
          if (tagInfo != null && tagInfo['tag'] != null) {
            tags.add(tagInfo['tag'] as String);
          }
        }

        // Add tags to word data
        wordJson['tags'] = tags;
        loadedWords.add(Word.fromJson(wordJson as Map<String, dynamic>));
      }

      _words = loadedWords.isEmpty ? _getFallbackWords() : loadedWords;
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

  /// Get a random word filtered by difficulty category
  /// Easy: 1-33, Medium: 34-66, Hard: 67-100
  Word getRandomWordByDifficulty(String difficultyCategory) {
    final allWords = getAllWords();
    
    // Convert category to difficulty range
    int minDifficulty, maxDifficulty;
    switch (difficultyCategory.toLowerCase()) {
      case 'easy':
        minDifficulty = 1;
        maxDifficulty = 33;
        break;
      case 'medium':
        minDifficulty = 34;
        maxDifficulty = 66;
        break;
      case 'hard':
        minDifficulty = 67;
        maxDifficulty = 100;
        break;
      default:
        minDifficulty = 1;
        maxDifficulty = 100;
    }

    final filteredWords = allWords
        .where(
          (word) => word.difficultyValue >= minDifficulty && 
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

  // Fallback words in case database loading fails
  List<Word> _getFallbackWords() {
    return [
      Word(
        id: 1,
        word: 'piano',
        difficultyValue: 45,
        locale: 'en',
        tags: [
          'musical instrument',
          'keyboard instrument',
          'instrument played by beethoven',
          'has 88 keys',
          'classical music',
        ],
      ),
      Word(
        id: 2,
        word: 'guitar',
        difficultyValue: 40,
        locale: 'en',
        tags: [
          'musical instrument',
          'string instrument',
          'has six strings',
          'used in rock music',
          'acoustic or electric',
        ],
      ),
      Word(
        id: 3,
        word: 'elephant',
        difficultyValue: 60,
        locale: 'en',
        tags: [
          'large mammal',
          'has a trunk',
          'largest land animal',
          'lives in africa and asia',
          'never forgets',
        ],
      ),
      Word(
        id: 4,
        word: 'dolphin',
        difficultyValue: 55,
        locale: 'en',
        tags: [
          'marine mammal',
          'intelligent creature',
          'lives in ocean',
          'playful animal',
          'uses echolocation',
        ],
      ),
      Word(
        id: 5,
        word: 'apple',
        difficultyValue: 25,
        locale: 'en',
        tags: [
          'fruit',
          'grows on trees',
          'red green or yellow',
          'keeps the doctor away',
          'crispy and sweet',
        ],
      ),
      Word(
        id: 6,
        word: 'banana',
        difficultyValue: 30,
        locale: 'en',
        tags: [
          'tropical fruit',
          'yellow when ripe',
          'high in potassium',
          'grows in bunches',
          'monkeys favorite',
        ],
      ),
      Word(
        id: 7,
        word: 'doctor',
        difficultyValue: 40,
        locale: 'en',
        tags: [
          'medical professional',
          'treats patients',
          'works in hospital',
          'helps sick people',
          'wears white coat',
        ],
      ),
      Word(
        id: 8,
        word: 'teacher',
        difficultyValue: 50,
        locale: 'en',
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
