import 'package:flutter/material.dart';

class GuessList extends StatelessWidget {
  final List<String> guesses;
  final List<List<String>> guessFeedback;

  const GuessList({
    super.key,
    required this.guesses,
    required this.guessFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: ListView.builder(
        itemCount: guesses.length,
        itemBuilder: (context, index) {
          final wordIndex = guesses.length - index - 1;
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: guesses[wordIndex].split('').asMap().entries.map((
                entry,
              ) {
                final i = entry.key;
                final letter = entry.value;
                final color = guessFeedback[wordIndex][i] == 'green'
                    ? Colors.green
                    : guessFeedback[wordIndex][i] == 'yellow'
                    ? Colors.yellow
                    : Colors.red;
                return Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(color: Colors.black),
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
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
