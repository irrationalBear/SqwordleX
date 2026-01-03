import 'package:flutter/material.dart';
import 'game_select_screen.dart';
import 'daily_challenge_screen.dart';
import 'weekly_challenge_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SqwordleX')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameSelectScreen(),
                  ),
                );
              },
              child: const Text('Play'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DailyChallengeScreen(),
                  ),
                );
              },
              child: const Text('Daily Challenge'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeeklyChallengeScreen(),
                  ),
                );
              },
              child: const Text('Weekly Challenge'),
            ),
          ],
        ),
      ),
    );
  }
}
