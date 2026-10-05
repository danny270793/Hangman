import '../entities/word_entity.dart';

abstract class WordsRepository {
  /// Words for [locale]; falls back to [kFallbackWords] when the backend
  /// fails or returns nothing.
  Future<List<WordEntity>> getWords({required String locale});
}
