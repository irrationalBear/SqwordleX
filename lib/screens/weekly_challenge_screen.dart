import 'dart:math';
import 'package:flutter/material.dart';
import 'gameplay_screen.dart';

class WeeklyChallengeScreen extends StatelessWidget {
  const WeeklyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Challenges')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '2026 Weekly Challenges',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Dummy grid – 4 columns × 4 rows = 16 weeks visible
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.all(8),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: List.generate(16, (index) {
                final week = index + 1;
                final bool isPlayed = week % 3 == 0; // dummy played status
                final String difficulty = ['Easy', 'Medium', 'Hard'][week % 3];

                return Card(
                  color: isPlayed ? Colors.grey[400] : Colors.green[50],
                  elevation: isPlayed ? 2 : 4,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Week $week',
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
                'Play Next Weekly Challenge',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
