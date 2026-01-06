import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:hangman/services/words_service.dart';
import 'package:hangman/services/difficulty_service.dart';
import 'package:hangman/services/timed_mode_service.dart';
import 'package:provider/provider.dart';

class GamePage extends StatefulWidget {
  static const String routeName = '/game';

  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final WordsService _wordsService = WordsService();
  late Word _currentWord;
  late String _word;
  final Set<String> _guessedLetters = {};
  int _wrongGuesses = 0;
  final int _maxWrongGuesses = 6;
  bool _isLoading = true;
  bool _hasLoadedWords = false;
  
  // Timer related
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _isTimedOut = false;
  
  // Score
  int _totalScore = 0;
  int _lastRoundPoints = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedWords) {
      _loadAndStartGame();
      _hasLoadedWords = true;
    }
  }

  Future<void> _loadAndStartGame() async {
    final locale = Localizations.localeOf(context).languageCode;
    final difficultyService = context.read<DifficultyService>();
    final difficulty = _getDifficultyString(difficultyService.difficulty);
    
    await _wordsService.loadWords(locale: locale);
    setState(() {
      _currentWord = _wordsService.getRandomWordByDifficulty(difficulty);
      _word = _currentWord.word.toUpperCase();
      _isLoading = false;
    });
    
    // Start timer if timed mode is enabled
    final timedModeService = context.read<TimedModeService>();
    if (timedModeService.isEnabled) {
      _startTimer();
    }
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _isTimedOut = false;
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isTimedOut = true;
          timer.cancel();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getDifficultyString(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 'easy';
      case GameDifficulty.medium:
        return 'medium';
      case GameDifficulty.hard:
        return 'hard';
    }
  }

  bool get _isGameWon {
    return _word.split('').every((letter) => _guessedLetters.contains(letter));
  }

  bool get _isGameLost {
    return _wrongGuesses >= _maxWrongGuesses || _isTimedOut;
  }

  /// Calculate points based on time remaining and wrong guesses
  /// More time left = more points (up to 60 points from time)
  /// Fewer mistakes = more points (up to 60 points from accuracy)
  int _calculatePoints() {
    final timedModeService = context.read<TimedModeService>();
    
    // Time bonus: 1 point per second remaining (0-60 points)
    int timeBonus = 0;
    if (timedModeService.isEnabled) {
      timeBonus = _remainingSeconds;
    }
    
    // Accuracy bonus: max 60 points, reduced by 10 per wrong guess
    int accuracyBonus = 60 - (_wrongGuesses * 10);
    if (accuracyBonus < 0) accuracyBonus = 0;
    
    // Base points for completing the word
    int basePoints = 20;
    
    return basePoints + timeBonus + accuracyBonus;
  }

  void _guessLetter(String letter) {
    if (_isGameWon || _isGameLost || _guessedLetters.contains(letter)) {
      return;
    }

    setState(() {
      _guessedLetters.add(letter);
      if (!_word.contains(letter)) {
        _wrongGuesses++;
      }
    });
    
    // Check if game ended after this guess
    if (_isGameWon) {
      _stopTimer();
      // Add points for winning
      setState(() {
        _lastRoundPoints = _calculatePoints();
        _totalScore += _lastRoundPoints;
      });
    } else if (_isGameLost) {
      _stopTimer();
    }
  }

  void _resetGame() {
    final difficultyService = context.read<DifficultyService>();
    final difficulty = _getDifficultyString(difficultyService.difficulty);
    final timedModeService = context.read<TimedModeService>();
    
    setState(() {
      _currentWord = _wordsService.getRandomWordByDifficulty(difficulty);
      _word = _currentWord.word.toUpperCase();
      _guessedLetters.clear();
      _wrongGuesses = 0;
      _isTimedOut = false;
    });
    
    // Restart timer if timed mode is enabled
    if (timedModeService.isEnabled) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timedModeService = context.watch<TimedModeService>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.hangmanGame),
            Text(
              '${l10n.score}: $_totalScore',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Score Cards
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildScoreCard(
                          l10n.guessesLeft,
                          '${_maxWrongGuesses - _wrongGuesses}',
                          Icons.favorite,
                          Colors.red,
                        ),
                        if (timedModeService.isEnabled)
                          _buildScoreCard(
                            l10n.time,
                            '${_remainingSeconds}s',
                            Icons.timer,
                            _remainingSeconds <= 10
                                ? Colors.red
                                : Colors.orange,
                          ),
                        _buildScoreCard(
                          l10n.lettersUsed,
                          '${_guessedLetters.length}',
                          Icons.text_fields,
                          Colors.blue,
                        ),
                      ],
                    ),
                  ),

                  // Hangman Drawing
                  Expanded(
                    flex: 3,
                    child: Center(child: _buildHangmanDrawing()),
                  ),

                  // Word Display
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: _buildWordDisplay(),
                    ),
                  ),

                  // Hint Display
                  if (!_isGameWon && !_isGameLost)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: _buildHintDisplay(),
                    ),

                  // Game Status Message
                  if (_isGameWon || _isGameLost)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Text(
                            _isGameWon ? l10n.youWon : l10n.gameOver,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _isGameWon ? Colors.green : Colors.red,
                            ),
                          ),
                          if (_isGameWon) ...[
                            const SizedBox(height: 8),
                            Text(
                              '+$_lastRoundPoints ${l10n.points}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _resetGame,
                            icon: Icon(_isGameWon ? Icons.arrow_forward : Icons.refresh),
                            label: Text(_isGameWon ? l10n.nextWord : l10n.playAgain),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Keyboard
                  Expanded(
                    flex: 2,
                    child: _buildKeyboard(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildScoreCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHangmanDrawing() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(
          painter: HangmanPainter(_wrongGuesses, Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildWordDisplay() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: _word.split('').map((letter) {
        final isGuessed = _guessedLetters.contains(letter);
        final shouldReveal = isGuessed || _isGameLost;
        return Container(
          width: 40,
          height: 50,
          decoration: BoxDecoration(
            color: shouldReveal
                ? (_isGameLost && !isGuessed
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.primaryContainer)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              shouldReveal ? letter : '',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHintDisplay() {
    final l10n = AppLocalizations.of(context)!;
    final randomTag = _currentWord.tags.isNotEmpty 
        ? _currentWord.tags[0] 
        : '';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Theme.of(context).colorScheme.onTertiaryContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${l10n.hint}: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
          ),
          Flexible(
            child: Text(
              randomTag,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboard() {
    const letters = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: letters.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((letter) {
                final isGuessed = _guessedLetters.contains(letter);
                final isCorrect = _word.contains(letter);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: ElevatedButton(
                    onPressed: isGuessed || _isGameWon || _isGameLost
                        ? null
                        : () => _guessLetter(letter),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isGuessed
                          ? (isCorrect
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      foregroundColor: isGuessed
                          ? (isCorrect
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onError)
                          : Theme.of(context).colorScheme.onSurface,
                      minimumSize: const Size(32, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class HangmanPainter extends CustomPainter {
  final int wrongGuesses;
  final Color color;

  HangmanPainter(this.wrongGuesses, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Base
    if (wrongGuesses > 0) {
      canvas.drawLine(
        Offset(size.width * 0.1, size.height * 0.9),
        Offset(size.width * 0.5, size.height * 0.9),
        paint,
      );
    }

    // Pole
    if (wrongGuesses > 1) {
      canvas.drawLine(
        Offset(size.width * 0.2, size.height * 0.9),
        Offset(size.width * 0.2, size.height * 0.1),
        paint,
      );
    }

    // Top bar
    if (wrongGuesses > 2) {
      canvas.drawLine(
        Offset(size.width * 0.2, size.height * 0.1),
        Offset(size.width * 0.6, size.height * 0.1),
        paint,
      );
    }

    // Rope
    if (wrongGuesses > 3) {
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.1),
        Offset(size.width * 0.6, size.height * 0.2),
        paint,
      );
    }

    // Head
    if (wrongGuesses > 4) {
      canvas.drawCircle(
        Offset(size.width * 0.6, size.height * 0.25),
        size.width * 0.05,
        paint,
      );
    }

    // Body
    if (wrongGuesses > 5) {
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.3),
        Offset(size.width * 0.6, size.height * 0.5),
        paint,
      );

      // Left arm
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.35),
        Offset(size.width * 0.5, size.height * 0.4),
        paint,
      );

      // Right arm
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.35),
        Offset(size.width * 0.7, size.height * 0.4),
        paint,
      );

      // Left leg
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.5),
        Offset(size.width * 0.5, size.height * 0.65),
        paint,
      );

      // Right leg
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.5),
        Offset(size.width * 0.7, size.height * 0.65),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(HangmanPainter oldDelegate) {
    return oldDelegate.wrongGuesses != wrongGuesses;
  }
}

