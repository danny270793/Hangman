import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameDifficulty { easy, medium, hard }

class DifficultyService extends ChangeNotifier {
  static const String _difficultyKey = 'game_difficulty';
  GameDifficulty _difficulty = GameDifficulty.medium;

  GameDifficulty get difficulty => _difficulty;

  /// Load the saved difficulty from storage
  Future<void> loadDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    final difficultyString = prefs.getString(_difficultyKey);

    if (difficultyString != null) {
      _difficulty = GameDifficulty.values.firstWhere(
        (mode) => mode.toString() == difficultyString,
        orElse: () => GameDifficulty.medium,
      );
      notifyListeners();
    }
  }

  /// Set the difficulty and save to storage
  Future<void> setDifficulty(GameDifficulty difficulty) async {
    if (_difficulty == difficulty) return;

    _difficulty = difficulty;

    // Save to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_difficultyKey, difficulty.toString());

    notifyListeners();
  }
}
