import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import 'main_screen.dart';
import 'gameplay_screen.dart';

class EndGameScreen extends StatelessWidget {
  final bool isPuzzleSolved;
  final String? difficulty;
  final int wrongGuesses;
  final int hintsUsed;
  final Duration timeElapsed;

  const EndGameScreen({
    super.key,
    required this.isPuzzleSolved,
    this.difficulty,
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
    gameState.addExtraGuess();
    Navigator.popUntil(
      context,
      (route) =>
          route is MaterialPageRoute &&
          route.builder(context) is GameplayScreen,
    );
  }

  void _navigateToMain(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }
}
