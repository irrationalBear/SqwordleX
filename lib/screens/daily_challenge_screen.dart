import 'dart:math';
import 'package:flutter/material.dart';
import 'gameplay_screen.dart';

class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Challenges')),
      body: Column(
        children: [
          // Dummy month header (hardcoded to current month/year for realism)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'January 2026',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Dummy calendar grid (7 columns × 5 rows = 35 slots, typical month view)
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              padding: const EdgeInsets.all(8),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: List.generate(35, (index) {
                final day = index + 1;
                // Dummy "played" status – every 4th day marked as played for visual variety
                final bool isPlayed = day % 4 == 0;
                // Dummy difficulty cycling
                final String difficulty = ['Easy', 'Medium', 'Hard'][day % 3];

                return Card(
                  color: isPlayed ? Colors.grey[400] : Colors.blue[50],
                  elevation: isPlayed ? 2 : 4,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          difficulty,
                          style: TextStyle(
                            fontSize: 12,
                            color: isPlayed ? Colors.grey[700] : Colors.black,
                          ),
                        ),
                        if (isPlayed)
                          const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          // Play button at bottom – starts a random difficulty game (stub behaviour)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                final difficulties = ['Easy', 'Medium', 'Hard'];
                final randomDifficulty =
                    difficulties[Random().nextInt(difficulties.length)];

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        GameplayScreen(difficulty: randomDifficulty),
                  ),
                );
              },
              child: const Text(
                'Play Today\'s Challenge',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
