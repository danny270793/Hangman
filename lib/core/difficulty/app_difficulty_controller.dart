import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameDifficulty {
  easy,
  medium,
  hard;

  /// Value sent to the backend / used to filter words.
  String get apiValue => name;
}

/// Persisted game difficulty.
class AppDifficultyController extends ChangeNotifier {
  AppDifficultyController();

  static const _prefKey = 'game_difficulty';

  GameDifficulty _difficulty = GameDifficulty.medium;

  GameDifficulty get difficulty => _difficulty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw != null) {
      _difficulty = GameDifficulty.values.firstWhere(
        (mode) => mode.toString() == raw,
        orElse: () => GameDifficulty.medium,
      );
    }
    notifyListeners();
  }

  Future<void> setDifficulty(GameDifficulty value) async {
    if (_difficulty == value) return;
    _difficulty = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, value.toString());
  }
}
