import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'gameplay_screen.dart';
import '../widgets/my_scaffold.dart';

class GameSelectScreen extends StatelessWidget {
  const GameSelectScreen({super.key});

  Widget _buildDifficultyCard(BuildContext context, String difficulty) {
    final String iconPath = difficulty == 'Easy'
        ? 'assets/icons/icon_easy_game.svg'
        : difficulty == 'Medium'
        ? 'assets/icons/icon_med_game.svg'
        : 'assets/icons/icon_hard_game.svg';

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white.withValues(alpha: 0.5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  GameplayScreen(difficulty: difficulty.toLowerCase()),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 0.30,
              child: SvgPicture.asset(iconPath, fit: BoxFit.contain),
            ),
            Center(
              child: Text(
                difficulty,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text('Select Difficulty'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              width:
                  400.0, // ← same max width as main screen (or 300 if you prefer)
              height:
                  1100.0, // ← tune this: 3 cards + spacing in portrait — measure once in portrait and set ~50px higher
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.1,
                      child: _buildDifficultyCard(context, 'Easy'),
                    ),
                    const SizedBox(height: 32),
                    AspectRatio(
                      aspectRatio: 1.1,
                      child: _buildDifficultyCard(context, 'Medium'),
                    ),
                    const SizedBox(height: 32),
                    AspectRatio(
                      aspectRatio: 1.1,
                      child: _buildDifficultyCard(context, 'Hard'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
