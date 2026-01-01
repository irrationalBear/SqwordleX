import 'package:flutter/material.dart';

class WordGrid extends StatelessWidget {
  final int wordLengthTopBottom;
  final int wordLengthLeftRight;
  final int horizontalInset;
  final int verticalInset;
  final List<String> targetWords;
  final List<List<String>> allGuesses;
  final List<String> guesses;
  final List<String> guessFeedback;
  final int currentSide;
  final String currentGuess; // Added to fix undefined error
  final bool isGameOver;
  final bool showAnimation;
  final AnimationController scaleController;
  final Animation<double> scaleAnimation;
  final bool isPuzzleSolved;
  final List<List<int?>> hintedLetters;
  final Function(int, int) onTap;

  const WordGrid({
    super.key,
    required this.wordLengthTopBottom,
    required this.wordLengthLeftRight,
    required this.horizontalInset,
    required this.verticalInset,
    required this.targetWords,
    required this.allGuesses,
    required this.guesses,
    required this.guessFeedback,
    required this.currentSide,
    required this.currentGuess, // Added to constructor
    required this.isGameOver,
    required this.showAnimation,
    required this.scaleController,
    required this.scaleAnimation,
    required this.isPuzzleSolved,
    required this.hintedLetters,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: showAnimation ? scaleAnimation.value : 1.0,
          child: Container(
            constraints: BoxConstraints.expand(),
            padding: EdgeInsets.all(5),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                children: List.generate(wordLengthLeftRight, (row) {
                  // Swapped to wordLengthLeftRight for rows
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(wordLengthTopBottom, (col) {
                      // Swapped to wordLengthTopBottom for columns
                      final isTop = row == verticalInset;
                      final isBottom =
                          row == wordLengthLeftRight - 1 - verticalInset;
                      final isLeft = col == horizontalInset;
                      final isRight =
                          col == wordLengthTopBottom - 1 - horizontalInset;
                      final isIntersection =
                          (isTop || isBottom) && (isLeft || isRight);
                      int side = isTop
                          ? 0
                          : isBottom
                          ? 1
                          : isLeft
                          ? 2
                          : isRight
                          ? 3
                          : -1;
                      final index = side < 2
                          ? col
                          : row; // col for top/bottom, row for left/right

                      bool isActive = side >= 0;
                      bool isCurrent =
                          isActive && currentSide == side && !isGameOver;
                      String letter = '';
                      Color? color;

                      if (isActive) {
                        int altIndex = index;
                        int altSide = side;
                        if (isIntersection) {
                          switch (side) {
                            case 0:
                            case 1:
                              altSide = isLeft ? 2 : 3;
                              altIndex = row;
                              break;
                            case 2:
                            case 3:
                              altSide = isTop ? 0 : 1;
                              altIndex = col;
                              break;
                          }
                        }

                        isCurrent =
                            isCurrent ||
                            (currentSide == altSide &&
                                !isGameOver &&
                                isIntersection);

                        // Show solved words on all sides
                        if (allGuesses[side].contains(targetWords[side])) {
                          letter = targetWords[side][index];
                          color = Colors.green[100];
                        }

                        if (letter.isEmpty && isIntersection) {
                          if (allGuesses[altSide].contains(
                            targetWords[altSide],
                          )) {
                            letter = targetWords[altSide][altIndex];
                            color = Colors.green[100];
                          }
                        }

                        // Show hints with light purple background
                        if (letter.isEmpty &&
                            hintedLetters[side][index] != null) {
                          letter = String.fromCharCode(
                            'A'.codeUnitAt(0) + hintedLetters[side][index]!,
                          );
                          color = Colors.purple[100]; // Light purple background
                        }

                        if (letter.isEmpty && isIntersection) {
                          if (hintedLetters[altSide][altIndex] != null) {
                            letter = String.fromCharCode(
                              'A'.codeUnitAt(0) +
                                  hintedLetters[altSide][altIndex]!,
                            );
                            color =
                                Colors.purple[100]; // Light purple background
                          }
                        }

                        // No current guess or wrong guesses in grid
                      }

                      return GestureDetector(
                        onTap: isActive ? () => onTap(row, col) : null,
                        child: Container(
                          width: 60, // Increased for larger grid
                          height: 60, // Increased for larger grid
                          margin: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            border: isActive
                                ? Border.all(
                                    color: Colors.black,
                                    width: isCurrent ? 3.0 : 1.0,
                                  )
                                : null, // Thicker border for selected
                            color: isActive
                                ? (color ?? Colors.white)
                                : Colors.white,
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.6),
                                      blurRadius: 6.0,
                                      spreadRadius: 4.0,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              letter,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color:
                                    (side >= 0 &&
                                            hintedLetters[side][index] !=
                                                null) ||
                                        (isIntersection &&
                                            (hintedLetters[0][row] != null ||
                                                hintedLetters[1][row] != null ||
                                                hintedLetters[2][col] != null ||
                                                hintedLetters[3][col] != null))
                                    ? Colors.black
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
