import 'package:equatable/equatable.dart';

import '../../domain/entities/word_entity.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameLoading extends GameState {
  const GameLoading();
}

class GameReady extends GameState {
  final List<WordEntity> words;

  const GameReady(this.words);

  @override
  List<Object?> get props => [words];
}
