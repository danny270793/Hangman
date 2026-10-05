import 'package:equatable/equatable.dart';

class WordEntity extends Equatable {
  final int id;
  final String word;
  final int difficultyValue;
  final String locale;
  final List<String> tags;

  const WordEntity({
    required this.id,
    required this.word,
    required this.difficultyValue,
    required this.locale,
    required this.tags,
  });

  @override
  List<Object?> get props => [id, word, difficultyValue, locale, tags];
}

/// Fallback words used when the words database cannot be loaded.
const List<WordEntity> kFallbackWords = [
  WordEntity(
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
  WordEntity(
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
  WordEntity(
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
  WordEntity(
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
  WordEntity(
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
  WordEntity(
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
  WordEntity(
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
  WordEntity(
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
