import 'package:flutter/material.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:hangman/pages/settings.dart';
import 'package:hangman/services/words_service.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WordsService _wordsService = WordsService();
  late Word _currentWord;
  late String _word;
  final Set<String> _guessedLetters = {};
  int _wrongGuesses = 0;
  final int _maxWrongGuesses = 6;
  bool _isLoading = true;
  bool _hasLoadedWords = false;

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
    await _wordsService.loadWords(locale: locale);
    setState(() {
      _currentWord = _wordsService.getRandomWord();
      _word = _currentWord.word.toUpperCase();
      _isLoading = false;
    });
  }

  bool get _isGameWon {
    return _word.split('').every((letter) => _guessedLetters.contains(letter));
  }

  bool get _isGameLost {
    return _wrongGuesses >= _maxWrongGuesses;
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
  }

  void _resetGame() {
    setState(() {
      _currentWord = _wordsService.getRandomWord();
      _word = _currentWord.word.toUpperCase();
      _guessedLetters.clear();
      _wrongGuesses = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.hangmanGame),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push(SettingsPage.routeName);
            },
            tooltip: l10n.settings,
          ),
        ],
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
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SafeArea(
          child: Column(
            children: [
              // Score Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildScoreCard(
                      l10n.guessesLeft,
                      '${_maxWrongGuesses - _wrongGuesses}',
                      Icons.favorite,
                      Colors.red,
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
              Expanded(flex: 3, child: Center(child: _buildHangmanDrawing())),

              // Word Display
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: _buildWordDisplay(),
              ),

              // Hint Display
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
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _resetGame,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.playAgain),
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
                child: SingleChildScrollView(child: _buildKeyboard()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHangmanDrawing() {
    return Container(
      width: 200,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(painter: HangmanPainter(_wrongGuesses)),
    );
  }

  Widget _buildWordDisplay() {
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: _word.split('').map((letter) {
        final isGuessed = _guessedLetters.contains(letter);
        final showLetter = isGuessed || _isGameLost;

        return Container(
          width: 40,
          height: 50,
          decoration: BoxDecoration(
            color: showLetter
                ? (_isGameLost && !isGuessed
                      ? Colors.red.shade100
                      : Colors.green.shade100)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: showLetter
                  ? (_isGameLost && !isGuessed ? Colors.red : Colors.green)
                  : Colors.grey.shade400,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            showLetter ? letter : '',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: showLetter
                  ? (_isGameLost && !isGuessed
                        ? Colors.red.shade700
                        : Colors.green.shade700)
                  : Colors.transparent,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHintDisplay() {
    final l10n = AppLocalizations.of(context)!;
    // Get a random tag from the current word as a hint
    final hint = _currentWord.tags.isNotEmpty 
        ? _currentWord.tags.first 
        : 'No hint available';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.shade300,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.amber.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${l10n.hint}: $hint',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboard() {
    const rows = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: rows.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((letter) {
                final isGuessed = _guessedLetters.contains(letter);
                final isCorrect = isGuessed && _word.contains(letter);
                final isWrong = isGuessed && !_word.contains(letter);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _guessLetter(letter),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 32,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? Colors.green
                              : isWrong
                              ? Colors.red
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isGuessed
                                ? Colors.transparent
                                : Colors.grey.shade400,
                            width: 1,
                          ),
                          boxShadow: isGuessed
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isGuessed ? Colors.white : Colors.black87,
                          ),
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

  HangmanPainter(this.wrongGuesses);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Base
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.95),
      Offset(size.width * 0.5, size.height * 0.95),
      paint,
    );

    // Pole
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.95),
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

    if (wrongGuesses >= 1) {
      // Head
      canvas.drawCircle(
        Offset(size.width * 0.6, size.height * 0.25),
        size.height * 0.05,
        paint,
      );
    }

    if (wrongGuesses >= 2) {
      // Body
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.3),
        Offset(size.width * 0.6, size.height * 0.5),
        paint,
      );
    }

    if (wrongGuesses >= 3) {
      // Left arm
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.35),
        Offset(size.width * 0.5, size.height * 0.4),
        paint,
      );
    }

    if (wrongGuesses >= 4) {
      // Right arm
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.35),
        Offset(size.width * 0.7, size.height * 0.4),
        paint,
      );
    }

    if (wrongGuesses >= 5) {
      // Left leg
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.5),
        Offset(size.width * 0.5, size.height * 0.65),
        paint,
      );
    }

    if (wrongGuesses >= 6) {
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
