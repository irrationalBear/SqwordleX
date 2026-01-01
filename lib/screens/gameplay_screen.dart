import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../widgets/word_grid.dart';
import '../widgets/keyboard.dart';
import '../widgets/guess_list.dart';
import '../main.dart';

class CurrentGuessDisplay extends StatelessWidget {
  final String currentGuess;
  final int wordLength;

  const CurrentGuessDisplay({
    super.key,
    required this.currentGuess,
    required this.wordLength,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(wordLength, (index) {
          final letter = index < currentGuess.length ? currentGuess[index] : '';
          return Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              color: index < currentGuess.length
                  ? Colors.white
                  : Colors.grey[300],
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class GameplayScreen extends StatefulWidget {
  final String? difficulty;
  const GameplayScreen({super.key, this.difficulty});

  @override
  _GameplayScreenState createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  final GlobalKey _wordGridKey = GlobalKey();
  bool _isWordGridLaidOut = false;
  bool _showAnimation = false;
  bool _wasGameOver = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    final gameState = Provider.of<GameState>(context, listen: false);
    if (widget.difficulty != null) {
      setState(() => _isInitializing = true);
      gameState.newGame(difficulty: widget.difficulty).then((_) {
        if (mounted) {
          setState(() => _isInitializing = false);
          SchedulerBinding.instance.addPostFrameCallback((_) {
            gameState.setCurrentSide(0);
          });
        }
      });
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        gameState.setCurrentSide(0);
      });
    }
    _isWordGridLaidOut = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gameState = Provider.of<GameState>(context, listen: false);
    if (!gameState.isGameOver && (_wasGameOver || _showAnimation)) {
      _resetLocalState();
      if (!gameState.isContinuing) {
        _scheduleInitialSetup();
      } else {
        gameState.isContinuing = false; // Reset after continuing
      }
    }
  }

  void _initializeAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..reset();
    _shakeAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..reset();
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
    _scaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _showAnimation = false;
        });
      }
    });
  }

  void _scheduleInitialSetup() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startNewGame(widget.difficulty);
      }
    });
  }

  void _startNewGame(String? difficulty) {
    _shakeController.reset();
    _scaleController.reset();
    _showAnimation = false;
    _wasGameOver = false;
    final gameState = Provider.of<GameState>(context, listen: false);
    if (difficulty != null) {
      gameState.newGame(difficulty: difficulty);
    }
    gameState.setCurrentSide(0);
    _isWordGridLaidOut = true;
  }

  void _resetLocalState() {
    _wasGameOver = false;
    _showAnimation = false;
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _shakeOnInvalidGuess(String guess, String target) {
    if (guess != target) {
      _shakeController.forward().then((_) => _shakeController.reset());
    }
  }

  void _onGridTap(int row, int col) {
    final gameState = Provider.of<GameState>(context, listen: false);
    if (gameState.isGameOver) return;

    final isTop = row == gameState.verticalInset;
    final isBottom =
        row == gameState.wordLengthLeftRight - 1 - gameState.verticalInset;
    final isLeft = col == gameState.horizontalInset;
    final isRight =
        col ==
        gameState.wordLengthTopBottom -
            1 -
            gameState.horizontalInset; // Fixed typo

    int newSide;
    if ((isTop || isBottom) && (isLeft || isRight)) {
      // Overlap
      if (isTop && isLeft) {
        newSide = gameState.currentSide == 0 ? 2 : 0;
      } else if (isTop && isRight) {
        newSide = gameState.currentSide == 0 ? 3 : 0;
      } else if (isBottom && isLeft) {
        newSide = gameState.currentSide == 1 ? 2 : 1;
      } else if (isBottom && isRight) {
        newSide = gameState.currentSide == 1 ? 3 : 1;
      } else {
        return;
      }
    } else if (isTop) {
      newSide = 0;
    } else if (isBottom) {
      newSide = 1;
    } else if (isLeft) {
      newSide = 2;
    } else if (isRight) {
      newSide = 3;
    } else {
      return; // Not on a word
    }
    gameState.setCurrentSide(newSide);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        if (_isInitializing) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (gameState.isGameOver) {
          final timeElapsed = DateTime.now().difference(gameState.startTime);
          final isPuzzleSolved = gameState.isPuzzleSolved();
          return EndGameScreen(
            isPuzzleSolved: isPuzzleSolved,
            difficulty: gameState.difficulty,
            wrongGuesses: gameState.incorrectGuesses,
            hintsUsed: gameState.getHintsUsed(),
            timeElapsed: timeElapsed,
          );
        }

        final wordLength = gameState.currentSide < 2
            ? gameState.wordLengthTopBottom
            : gameState.wordLengthLeftRight;

        return Scaffold(
          appBar: AppBar(title: const Text('SqwordleX Gameplay')),
          body: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        gameState.maxGuesses,
                        (index) => Icon(
                          Icons.favorite,
                          color:
                              index <
                                  gameState.maxGuesses -
                                      gameState.incorrectGuesses
                              ? Colors.red
                              : Colors.grey,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16.0,
                    child: ElevatedButton(
                      onPressed: () => gameState.useHint(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gameState.CanHint()
                            ? null
                            : Colors.grey.shade400,
                      ),
                      child: Text(
                        'Hint',
                        style: TextStyle(
                          color: gameState.CanHint()
                              ? null
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                flex: 3,
                child: WordGrid(
                  key: _wordGridKey,
                  wordLengthTopBottom: gameState.wordLengthTopBottom,
                  wordLengthLeftRight: gameState.wordLengthLeftRight,
                  horizontalInset: gameState.horizontalInset,
                  verticalInset: gameState.verticalInset,
                  targetWords: gameState.targetWords,
                  allGuesses: gameState.guesses,
                  guesses: gameState.guesses[gameState.currentSide],
                  guessFeedback:
                      gameState.guessFeedback[gameState.currentSide].isNotEmpty
                      ? gameState.guessFeedback[gameState.currentSide].last
                      : List.filled(gameState.wordLengthTopBottom, 'red'),
                  currentSide: gameState.currentSide,
                  currentGuess: gameState.currentGuess, // Pass currentGuess
                  isGameOver: gameState.isGameOver,
                  showAnimation: _showAnimation,
                  scaleController: _scaleController,
                  scaleAnimation: _scaleAnimation,
                  isPuzzleSolved: gameState.isPuzzleSolved(),
                  hintedLetters: gameState.hintedLetters,
                  onTap: _onGridTap,
                ),
              ),
              CurrentGuessDisplay(
                currentGuess: gameState.currentGuess,
                wordLength: wordLength,
              ),
              GuessList(
                guesses: gameState.guesses[gameState.currentSide],
                guessFeedback: gameState.guessFeedback[gameState.currentSide],
              ),
              Keyboard(
                onKeyPressed: (key) {
                  if (key == 'ENTER') {
                    if (gameState.submitGuess()) {
                      _shakeOnInvalidGuess(
                        gameState.currentGuess,
                        gameState.targetWords[gameState.currentSide],
                      );
                    }
                    if (gameState.isGameOver) {
                      setState(() {
                        _showAnimation = true;
                        _scaleController.forward();
                      });
                    }
                  } else if (key == 'BACK') {
                    gameState.removeLetter();
                  } else {
                    gameState.addLetter(key);
                  }
                },
                targetWords: gameState.targetWords,
                isGameOver: gameState.isGameOver,
                currentGuess: gameState.currentGuess,
                wordLength: wordLength,
              ),
            ],
          ),
        );
      },
    );
  }
}

class EndGameScreen extends StatelessWidget {
  final bool isPuzzleSolved;
  final String? difficulty;
  final int wrongGuesses;
  final int hintsUsed;
  final Duration timeElapsed;

  const EndGameScreen({
    super.key,
    required this.isPuzzleSolved,
    required this.difficulty,
    required this.wrongGuesses,
    required this.hintsUsed,
    required this.timeElapsed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              child: Text(
                isPuzzleSolved ? 'Congratulations!' : 'Game Over!',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            if (isPuzzleSolved)
              const Icon(Icons.whatshot, size: 50, color: Colors.yellow),
            if (isPuzzleSolved)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Score: ${((100 * 2 * (context.read<GameState>().wordLengthTopBottom)) + (100 * 2 * (context.read<GameState>().wordLengthLeftRight))) - (wrongGuesses * 100) - (hintsUsed * 100)}',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Difficulty: ${difficulty ?? 'Unknown'}'),
                  Text('Wrong Guesses: $wrongGuesses'),
                  Text('Hints Used: $hintsUsed'),
                  Text('Time Elapsed: ${timeElapsed.inSeconds} seconds'),
                ],
              ),
            ),
            Column(
              children: [
                if (isPuzzleSolved)
                  ElevatedButton(
                    onPressed: () => _startNewGame(context, difficulty),
                    child: const Text('New Game'),
                  ),
                if (isPuzzleSolved)
                  ElevatedButton(
                    onPressed: () => _navigateToMain(context),
                    child: const Text('Home'),
                  ),
                if (!isPuzzleSolved)
                  ElevatedButton(
                    onPressed: () => _getAnotherLife(context),
                    child: const Text('Get Another Life'),
                  ),
                if (!isPuzzleSolved)
                  ElevatedButton(
                    onPressed: () => _startNewGame(context, difficulty),
                    child: const Text('New Game'),
                  ),
                if (!isPuzzleSolved)
                  ElevatedButton(
                    onPressed: () => _navigateToMain(context),
                    child: const Text('Home'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startNewGame(BuildContext context, String? difficulty) {
    Navigator.pop(context);
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.newGame(difficulty: difficulty);
  }

  void _getAnotherLife(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.addExtraGuess(); // Increment maxGuesses, set isContinuing=true
    Navigator.popUntil(
      context,
      (route) =>
          route is MaterialPageRoute &&
          route.builder(context) is GameplayScreen,
    ); // Pop until GameplayScreen
  }

  void _navigateToMain(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }
}
