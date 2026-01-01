import 'package:flutter/material.dart';

class Keyboard extends StatelessWidget {
  final Function(String)? onKeyPressed;
  final List<String> targetWords;
  final bool isGameOver;
  final String currentGuess;
  final int wordLength;

  const Keyboard({
    super.key,
    required this.onKeyPressed,
    required this.targetWords,
    required this.isGameOver,
    required this.currentGuess,
    required this.wordLength,
  });

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'BACK'],
    ];

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              final isEnabled =
                  !isGameOver &&
                  (key == 'ENTER'
                      ? currentGuess.length == wordLength
                      : key == 'BACK' ||
                            targetWords.any((word) => word.contains(key)));
              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: isEnabled && onKeyPressed != null
                      ? () => onKeyPressed!(key)
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(40, 40),
                    padding: const EdgeInsets.all(8.0),
                    backgroundColor: isGameOver
                        ? Colors.grey.shade500
                        : (isEnabled ? null : Colors.grey.shade500),
                  ),
                  child: Text(
                    key == 'BACK' ? '⌫' : key,
                    style: TextStyle(
                      fontSize: 16,
                      color: isGameOver
                          ? Colors.grey.shade400
                          : (isEnabled ? null : Colors.grey.shade400),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
