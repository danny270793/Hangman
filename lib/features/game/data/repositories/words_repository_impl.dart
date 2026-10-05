import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/word_entity.dart';
import '../../domain/repositories/words_repository.dart';
import '../datasources/words_remote_datasource.dart';

class WordsRepositoryImpl implements WordsRepository {
  final WordsRemoteDatasource _datasource;

  const WordsRepositoryImpl(this._datasource);

  @override
  Future<List<WordEntity>> getWords({required String locale}) async {
    try {
      final words = await _datasource.getWords(locale: locale);
      return words.isEmpty ? kFallbackWords : words;
    } catch (e, s) {
      // If loading fails, use fallback words
      AppLogger.error('failed to load words, using fallback', e, s);
      return kFallbackWords;
    }
  }
}
