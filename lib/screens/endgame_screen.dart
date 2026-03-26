import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqwordlex/widgets/my_scaffold.dart';

import '../models/game_state.dart';
import 'main_screen.dart';
import 'gameplay_screen.dart';
import '../services/sound_manager.dart';

class EndGameScreen extends StatefulWidget {
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
  State<EndGameScreen> createState() => _EndGameScreenState();
}

class _EndGameScreenState extends State<EndGameScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    if (widget.isPuzzleSolved) {
      SoundManager().playWin();
      _confettiController.play();
    } else {
      SoundManager().playLoss();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.read<GameState>();
    final minutes = widget.timeElapsed.inMinutes;
    final seconds = widget.timeElapsed.inSeconds % 60;
    final score =
        ((100 * 2 * (gameState.wordLengthTopBottom)) +
            (100 * 2 * (gameState.wordLengthLeftRight))) -
        (widget.wrongGuesses * 100) -
        (widget.hintsUsed * 100);

    return MyScaffold(
      body: Stack(
        children: [
          // Fireworks (win only) – full screen but does NOT block taps
          if (widget.isPuzzleSolved)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.06,
                numberOfParticles: 70,
                gravity: 0.12,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                  Colors.purple,
                  Colors.orange,
                ],
              ),
            ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Large, bold status
                    Text(
                      widget.isPuzzleSolved ? 'PUZZLE SOLVED!' : 'GAME OVER',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    if (widget.isPuzzleSolved)
                      const Icon(
                        Icons.celebration,
                        size: 80,
                        color: Colors.amber,
                      ),

                    const SizedBox(height: 32),

                    // Stats – larger and bolder
                    _buildStatRow(
                      'Difficulty',
                      widget.difficulty?.toUpperCase() ?? 'UNKNOWN',
                    ),
                    _buildStatRow(
                      'Wrong Guesses',
                      widget.wrongGuesses.toString(),
                    ),
                    _buildStatRow('Hints Used', widget.hintsUsed.toString()),
                    _buildStatRow(
                      'Time',
                      '$minutes:${seconds.toString().padLeft(2, '0')}',
                    ),
                    if (widget.isPuzzleSolved)
                      _buildStatRow('Score', score.toString()),
                    const SizedBox(height: 48),

                    // Bigger buttons with icons
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: [
                        if (widget.isPuzzleSolved)
                          _buildBigButton(
                            icon: Icons.play_arrow,
                            label: 'New Game',
                            onTap: () =>
                                _startNewGame(context, widget.difficulty),
                          ),
                        if (widget.isPuzzleSolved)
                          _buildBigButton(
                            icon: Icons.home,
                            label: 'Home',
                            onTap: () => _navigateToMain(context),
                          ),

                        if (!widget.isPuzzleSolved)
                          _buildBigButton(
                            icon: Icons.favorite,
                            label: '+1 Life',
                            onTap: () => _getAnotherLife(context),
                          ),
                        if (!widget.isPuzzleSolved)
                          _buildBigButton(
                            icon: Icons.play_arrow,
                            label: 'New Game',
                            onTap: () =>
                                _startNewGame(context, widget.difficulty),
                          ),
                        if (!widget.isPuzzleSolved)
                          _buildBigButton(
                            icon: Icons.home,
                            label: 'Home',
                            onTap: () => _navigateToMain(context),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBigButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _startNewGame(BuildContext context, String? difficulty) {
    SoundManager().playButton();
    Navigator.pop(context);
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.newGame(difficulty: difficulty);
  }

  void _getAnotherLife(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.addExtraGuess();
    SoundManager().playButton();
    Navigator.popUntil(
      context,
      (route) =>
          route is MaterialPageRoute &&
          route.builder(context) is GameplayScreen,
    );
  }

  void _navigateToMain(BuildContext context) {
    SoundManager().playButton();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }
}
