import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:hangman/services/words_service.dart';
import 'package:hangman/services/difficulty_service.dart';
import 'package:hangman/services/timed_mode_service.dart';
import 'package:hangman/services/game_record_service.dart';
import 'package:provider/provider.dart';

class GamePage extends StatefulWidget {
  static const String routeName = '/game';

  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final WordsService _wordsService = WordsService();
  final GameRecordService _gameRecordService = GameRecordService();
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
  int _currentWordStartTime = 0; // Tracks seconds elapsed for current word

  // Score
  int _totalScore = 0;
  int _lastRoundPoints = 0;

  // Statistics
  int _totalSecondsPlayed = 0;
  int _wordsSolved = 0;
  bool _hasGameRecordBeenSaved = false;

  // Hint navigation
  int _currentHintIndex = 0;
  final PageController _hintPageController = PageController();

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
      _currentHintIndex = 0; // Reset hint index
    });

    // Start timer if timed mode is enabled
    final timedModeService = context.read<TimedModeService>();
    if (timedModeService.isEnabled) {
      _startTimer();
    } else {
      // Even without timed mode, track time for statistics
      _startPlaytimeTracking();
    }
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _isTimedOut = false;
    _currentWordStartTime = 0;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentWordStartTime++; // Track time for current word
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isTimedOut = true;
          timer.cancel();
        }
      });
    });
  }

  void _startPlaytimeTracking() {
    _currentWordStartTime = 0;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentWordStartTime++; // Track time for current word
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hintPageController.dispose();
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

  Future<void> _saveGameRecordOnGameEnd() async {
    // Only save once per game session
    if (_hasGameRecordBeenSaved) {
      return;
    }

    // Only save if the user has played at least one word
    if (_totalSecondsPlayed == 0 && _wordsSolved == 0) {
      return;
    }

    _hasGameRecordBeenSaved = true;

    final difficultyService = context.read<DifficultyService>();
    final timedModeService = context.read<TimedModeService>();

    final error = await _gameRecordService.saveGameRecord(
      hasTimedModeEnabled: timedModeService.isEnabled,
      difficulty: _getDifficultyString(difficultyService.difficulty),
      points: _totalScore,
      words: _wordsSolved,
      timePlaying: _totalSecondsPlayed,
    );

    if (error != null && mounted) {
      // Optionally show error to user, but don't prevent exit
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save game record: $error'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
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
      // Add points for winning and update statistics
      setState(() {
        _lastRoundPoints = _calculatePoints();
        _totalScore += _lastRoundPoints;
        _wordsSolved++;
        _totalSecondsPlayed += _currentWordStartTime;
      });
      // Show win modal
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameResultModal(true);
      });
    } else if (_isGameLost) {
      _stopTimer();
      // Still track time even if lost
      setState(() {
        _totalSecondsPlayed += _currentWordStartTime;
      });
      // Show lose modal
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameResultModal(false);
      });
    }
  }

  // Continue to next word after winning (preserves statistics)
  void _continueToNextWord() {
    final difficultyService = context.read<DifficultyService>();
    final difficulty = _getDifficultyString(difficultyService.difficulty);
    final timedModeService = context.read<TimedModeService>();

    setState(() {
      _currentWord = _wordsService.getRandomWordByDifficulty(difficulty);
      _word = _currentWord.word.toUpperCase();
      _guessedLetters.clear();
      _wrongGuesses = 0;
      _isTimedOut = false;
      _currentWordStartTime = 0;
      _currentHintIndex = 0; // Reset hint index
      // Statistics are preserved - continue accumulating
    });

    // Reset page controller
    _hintPageController.jumpToPage(0);

    // Restart timer if timed mode is enabled, otherwise track playtime
    if (timedModeService.isEnabled) {
      _startTimer();
    } else {
      _startPlaytimeTracking();
    }
  }

  // Play again after game over (saves record and resets everything)
  Future<void> _playAgainAfterGameOver() async {
    // Save the game record before resetting
    await _saveGameRecordOnGameEnd();

    final difficultyService = context.read<DifficultyService>();
    final difficulty = _getDifficultyString(difficultyService.difficulty);
    final timedModeService = context.read<TimedModeService>();

    setState(() {
      _currentWord = _wordsService.getRandomWordByDifficulty(difficulty);
      _word = _currentWord.word.toUpperCase();
      _guessedLetters.clear();
      _wrongGuesses = 0;
      _isTimedOut = false;
      _currentWordStartTime = 0;
      _currentHintIndex = 0; // Reset hint index

      // Reset all accumulated statistics when starting a new game
      _totalScore = 0;
      _lastRoundPoints = 0;
      _totalSecondsPlayed = 0;
      _wordsSolved = 0;
      _hasGameRecordBeenSaved = false; // Reset save flag for new session
    });

    // Reset page controller
    _hintPageController.jumpToPage(0);

    // Restart timer if timed mode is enabled, otherwise track playtime
    if (timedModeService.isEnabled) {
      _startTimer();
    } else {
      _startPlaytimeTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timedModeService = context.watch<TimedModeService>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final shouldPop = await _showExitConfirmationDialog(context, l10n);
        if (shouldPop == true && context.mounted) {
          // Save record if not already saved (in case user is exiting mid-game)
          if (!_hasGameRecordBeenSaved &&
              (_totalSecondsPlayed > 0 || _wordsSolved > 0)) {
            await _saveGameRecordOnGameEnd();
          }
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldExit = await _showExitConfirmationDialog(
                context,
                l10n,
              );
              if (shouldExit == true && context.mounted) {
                // Save record if not already saved (in case user is exiting mid-game)
                if (!_hasGameRecordBeenSaved &&
                    (_totalSecondsPlayed > 0 || _wordsSolved > 0)) {
                  await _saveGameRecordOnGameEnd();
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.hangmanGame),
              Text(
                '${l10n.score}: $_totalScore',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
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
              : OrientationBuilder(
                  builder: (context, orientation) {
                    final isLandscape = orientation == Orientation.landscape;

                    if (isLandscape) {
                      return SafeArea(
                        child: _buildLandscapeLayout(
                          context,
                          l10n,
                          timedModeService,
                        ),
                      );
                    } else {
                      return _buildPortraitLayout(
                        context,
                        l10n,
                        timedModeService,
                      );
                    }
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    AppLocalizations l10n,
    TimedModeService timedModeService,
  ) {
    return Column(
      children: [
        // Scrollable content
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Score Cards
              Padding(
                padding: EdgeInsets.only(top: 24, bottom: 24),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 8,
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
                          _remainingSeconds <= 10 ? Colors.red : Colors.orange,
                        ),
                      _buildScoreCard(
                        l10n.lettersUsed,
                        '${_guessedLetters.length}',
                        Icons.text_fields,
                        Colors.blue,
                      ),
                      _buildScoreCard(
                        l10n.score,
                        '$_totalScore',
                        Icons.star,
                        Colors.amber,
                      ),
                      _buildScoreCard(
                        l10n.wordsSolved,
                        '$_wordsSolved',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildScoreCard(
                        l10n.totalTime,
                        '${_totalSecondsPlayed}s',
                        Icons.access_time,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
              ),

              // Hangman Drawing
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: 200,
                  child: Center(child: _buildHangmanDrawing()),
                ),
              ),

              const SizedBox(height: 8),

              // Word Display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(child: _buildWordDisplay()),
              ),

              const SizedBox(height: 12),

              // Hint Display or Game Status
              if (!_isGameWon && !_isGameLost)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: _buildHintDisplay(),
                ),

              const SizedBox(height: 8),
            ],
          ),
        ),

        // Fixed Keyboard at bottom with card elevation
        Card(
          margin: EdgeInsets.zero,
          elevation: 8,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: _buildKeyboard(),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    AppLocalizations l10n,
    TimedModeService timedModeService,
  ) {
    return Row(
      children: [
        // Left side - Score Cards (vertical) and Hangman
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Score Cards - Vertical
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildScoreCard(
                      l10n.guessesLeft,
                      '${_maxWrongGuesses - _wrongGuesses}',
                      Icons.favorite,
                      Colors.red,
                    ),
                    const SizedBox(height: 8),
                    if (timedModeService.isEnabled) ...[
                      _buildScoreCard(
                        l10n.time,
                        '${_remainingSeconds}s',
                        Icons.timer,
                        _remainingSeconds <= 10 ? Colors.red : Colors.orange,
                      ),
                      const SizedBox(height: 8),
                    ],
                    _buildScoreCard(
                      l10n.lettersUsed,
                      '${_guessedLetters.length}',
                      Icons.text_fields,
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildScoreCard(
                      l10n.score,
                      '$_totalScore',
                      Icons.star,
                      Colors.amber,
                    ),
                    const SizedBox(height: 8),
                    _buildScoreCard(
                      l10n.wordsSolved,
                      '$_wordsSolved',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildScoreCard(
                      l10n.totalTime,
                      '${_totalSecondsPlayed}s',
                      Icons.access_time,
                      Colors.purple,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Hangman Drawing
              Expanded(
                child: Center(
                  child: SizedBox(height: 250, child: _buildHangmanDrawing()),
                ),
              ),
            ],
          ),
        ),

        // Right side - Word, Hint, Status, and Keyboard
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),

                      // Word Display
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Center(child: _buildWordDisplay()),
                      ),

                      const SizedBox(height: 12),

                      // Hint Display
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: _buildHintDisplay(),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Fixed Keyboard at bottom
              _buildKeyboard(),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool?> _showExitConfirmationDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.exitGame),
          content: Text(l10n.exitGameConfirmation),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.exit),
            ),
          ],
        );
      },
    );
  }

  void _showGameResultModal(bool isWon) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final orientation = MediaQuery.of(dialogContext).orientation;
        final isLandscape = orientation == Orientation.landscape;

        // Build icon widget
        Widget buildIcon() {
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isWon ? Colors.green : Colors.red,
              boxShadow: [
                BoxShadow(
                  color: (isWon ? Colors.green : Colors.red).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              isWon ? Icons.emoji_events : Icons.close,
              size: 60,
              color: Colors.white,
            ),
          );
        }

        // Build title widget
        Widget buildTitle() {
          return Text(
            isWon ? l10n.youWon : l10n.gameOver,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isWon ? Colors.green.shade800 : Colors.red.shade800,
            ),
            textAlign: TextAlign.center,
          );
        }

        // Build points widget
        Widget buildPoints() {
          if (!isWon) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber.shade600,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  '+$_lastRoundPoints',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.points,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        // Build word widget
        Widget buildWord() {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isWon ? Colors.green.shade300 : Colors.red.shade300,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  l10n.theWordWas,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _word,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isWon ? Colors.green.shade900 : Colors.red.shade900,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          );
        }

        // Build button widget
        Widget buildButton() {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (isWon) {
                  _continueToNextWord();
                } else {
                  _playAgainAfterGameOver();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isWon ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isWon ? l10n.nextWord : l10n.playAgain,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isWon
                        ? Icons.arrow_forward_rounded
                        : Icons.refresh_rounded,
                    size: 24,
                  ),
                ],
              ),
            ),
          );
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isWon
                    ? [Colors.green.shade50, Colors.green.shade100]
                    : [Colors.red.shade50, Colors.red.shade100],
              ),
            ),
            child: isLandscape
                ? IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left column
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildIcon(),
                              const SizedBox(height: 24),
                              buildTitle(),
                              if (isWon) ...[
                                const SizedBox(height: 16),
                                buildPoints(),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        // Right column
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildWord(),
                              const SizedBox(height: 24),
                              buildButton(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildIcon(),
                      const SizedBox(height: 24),
                      buildTitle(),
                      const SizedBox(height: 16),
                      if (isWon) ...[
                        buildPoints(),
                        const SizedBox(height: 24),
                      ],
                      buildWord(),
                      const SizedBox(height: 32),
                      buildButton(),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildScoreCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
          painter: HangmanPainter(
            _wrongGuesses,
            Theme.of(context).colorScheme.primary,
          ),
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
          height: 40,
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
    final hints = _currentWord.tags.isNotEmpty ? _currentWord.tags : [''];

    if (hints.length == 1) {
      // Single hint - no swipe needed
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
                hints[0],
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

    // Multiple hints - swipeable
    return Column(
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.tertiary,
              width: 2,
            ),
          ),
          child: PageView.builder(
            controller: _hintPageController,
            onPageChanged: (index) {
              setState(() {
                _currentHintIndex = index;
              });
            },
            itemCount: hints.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        hints[index],
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onTertiaryContainer,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            hints.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentHintIndex == index
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyboard() {
    const letters = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ñ'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: letters.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((letter) {
                final isGuessed = _guessedLetters.contains(letter);
                final isCorrect = _word.contains(letter);
                return Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.5),
                    child: ElevatedButton(
                      onPressed: isGuessed || _isGameWon || _isGameLost
                          ? null
                          : () => _guessLetter(letter),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isGuessed
                            ? (isCorrect
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error)
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        foregroundColor: isGuessed
                            ? (isCorrect
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onError)
                            : Theme.of(context).colorScheme.onSurface,
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        letter,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

    // Always draw the gallows structure

    // Base
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.9),
      Offset(size.width * 0.5, size.height * 0.9),
      paint,
    );

    // Pole
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.9),
      Offset(size.width * 0.2, size.height * 0.1),
      paint,
    );

    // Top bar
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.1),
      Offset(size.width * 0.6, size.height * 0.1),
      paint,
    );

    // Rope
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.1),
      Offset(size.width * 0.6, size.height * 0.2),
      paint,
    );

    // Draw person parts based on wrong guesses

    // Head (1st wrong guess)
    if (wrongGuesses >= 1) {
      canvas.drawCircle(
        Offset(size.width * 0.6, size.height * 0.25),
        size.width * 0.05,
        paint,
      );
    }

    // Body (2nd wrong guess)
    if (wrongGuesses >= 2) {
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.3),
        Offset(size.width * 0.6, size.height * 0.5),
        paint,
      );
    }

    // Left arm (3rd wrong guess)
    if (wrongGuesses >= 3) {
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.35),
        Offset(size.width * 0.5, size.height * 0.4),
        paint,
      );
    }

    // Right arm (4th wrong guess)
    if (wrongGuesses >= 4) {
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.35),
        Offset(size.width * 0.7, size.height * 0.4),
        paint,
      );
    }

    // Left leg (5th wrong guess)
    if (wrongGuesses >= 5) {
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.5),
        Offset(size.width * 0.5, size.height * 0.65),
        paint,
      );
    }

    // Right leg (6th wrong guess)
    if (wrongGuesses >= 6) {
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
