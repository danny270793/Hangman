import 'package:equatable/equatable.dart';

class GameRecordEntity extends Equatable {
  final String username;
  final int points;
  final int words;
  final int timePlaying;
  final String difficulty;
  final bool hasTimedModeEnabled;

  const GameRecordEntity({
    required this.username,
    required this.points,
    required this.words,
    required this.timePlaying,
    required this.difficulty,
    required this.hasTimedModeEnabled,
  });

  @override
  List<Object?> get props => [
    username,
    points,
    words,
    timePlaying,
    difficulty,
    hasTimedModeEnabled,
  ];
}
