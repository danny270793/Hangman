import '../entities/word_entity.dart';
import '../repositories/words_repository.dart';

class GetWordsUsecase {
  final WordsRepository _repository;

  const GetWordsUsecase(this._repository);

  Future<List<WordEntity>> call({required String locale}) =>
      _repository.getWords(locale: locale);
}
