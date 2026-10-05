import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/word_entity.dart';

abstract class WordsRemoteDatasource {
  Future<List<WordEntity>> getWords({required String locale});
}

class WordsSupabaseDatasource implements WordsRemoteDatasource {
  final SupabaseClient _client;

  const WordsSupabaseDatasource(this._client);

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

  static WordEntity _fromJson(Map<String, dynamic> json) {
    final tagsList = json['tags'] as List<dynamic>?;
    return WordEntity(
      id: json['id'] as int,
      word: _removeAccents(json['word'] as String),
      difficultyValue: json['difficulty_value'] as int,
      locale: json['locale'] as String,
      tags: tagsList?.map((e) => e as String).toList() ?? const [],
    );
  }

  @override
  Future<List<WordEntity>> getWords({required String locale}) async {
    AppLogger.debug('getWords called for $locale');
    // Query hangman_words_with_tags view for the specified locale (single fetch)
    final response = await _client
        .from('hangman_words_with_tags')
        .select()
        .eq('locale', locale);
    return (response as List<dynamic>)
        .map((json) => _fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
