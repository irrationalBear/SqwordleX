import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class GameState extends ChangeNotifier {
  static const int maxGuessesEasy = 6;
  static const int maxGuessesMedium = 7;
  static const int maxGuessesHard = 8;
  int maxGuesses = maxGuessesMedium;
  String matchFile = 'matches-1.json';
  String? difficulty;
  DateTime startTime = DateTime.now();
  DateTime? currentChallengeDate;

  List<String> wordList3 = [];
  List<String> wordList4 = [];
  List<String> wordList5 = [];
  List<String> wordList6 = [];
  List<String> wordList7 = [];
  List<String> wordList8 = [];
  List<List<int>> matches = [];
  List<String> targetWords = ['', '', '', ''];
  int wordLengthTopBottom = 3;
  int wordLengthLeftRight = 3;
  int horizontalInset = 0;
  int verticalInset = 0;
  List<List<String>> guesses = [[], [], [], []];
  List<List<List<String>>> guessFeedback = [[], [], [], []];
  String currentGuess = '';
  int currentSide = 0;
  bool isGameOver = false;
  bool isContinuing = false; // Flag for "extra life" continue mode
  int incorrectGuesses = 0;
  int hintsUsed = 0;
  List<List<int?>> hintedLetters = [
    [],
    [],
    [],
    [],
  ]; // Dynamically sized per side

  GameState() {
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      wordList3 = List<String>.from(
        jsonDecode(await rootBundle.loadString('assets/data/words3.json')),
      );
      wordList4 = List<String>.from(
        jsonDecode(await rootBundle.loadString('assets/data/words4.json')),
      );
      wordList5 = List<String>.from(
        jsonDecode(await rootBundle.loadString('assets/data/words5.json')),
      );
      wordList6 = List<String>.from(
        jsonDecode(await rootBundle.loadString('assets/data/words6.json')),
      );
      wordList7 = List<String>.from(
        jsonDecode(await rootBundle.loadString('assets/data/words7.json')),
      );
      wordList8 = List<String>.from(
        jsonDecode(await rootBundle.loadString('assets/data/words8.json')),
      );
      notifyListeners();
    } catch (e) {
      print('Error loading assets: $e');
    }
  }

  Future<void> loadMatchFile(String difficulty) async {
    this.difficulty = difficulty;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        maxGuesses = maxGuessesEasy;
        matchFile = 'matches-1.json';
        break;
      case 'medium':
        maxGuesses = maxGuessesMedium;
        matchFile = 'matches-2.json';
        break;
      case 'hard':
        maxGuesses = maxGuessesHard;
        matchFile = 'matches-3.json';
        break;
    }
    try {
      final matchesJson = await rootBundle.loadString('assets/data/$matchFile');
      matches = List<List<int>>.from(
        jsonDecode(matchesJson).map((m) => List<int>.from(m)),
      );
    } catch (e) {
      print('Error loading match file: $e');
    }
  }

  Future<void> newGame({
    String? difficulty,
    int? fixedSeed,
    DateTime? challengeDate,
  }) async {
    currentChallengeDate = challengeDate;

    late String chosenDifficulty;
    late Random random;

    isGameOver = false;
    isContinuing = false;

    if (fixedSeed != null) {
      random = Random(fixedSeed);
      final int diffIndex = random.nextInt(3);
      chosenDifficulty = ['Easy', 'Medium', 'Hard'][diffIndex];
    } else {
      chosenDifficulty = difficulty ?? 'Easy';
      random = Random();
    }

    await loadMatchFile(chosenDifficulty);
    if (matches.isEmpty) return;

    final match = matches[random.nextInt(matches.length)];
    wordLengthTopBottom = match[0];
    horizontalInset = match[1];
    wordLengthLeftRight = match[2];
    verticalInset = match[3];

    final List<List<String>> wordLists = [
      wordList3,
      wordList4,
      wordList5,
      wordList6,
      wordList7,
      wordList8,
    ];

    targetWords = [
      wordLists[wordLengthTopBottom - 3][match[4]],
      wordLists[wordLengthTopBottom - 3][match[5]],
      wordLists[wordLengthLeftRight - 3][match[6]],
      wordLists[wordLengthLeftRight - 3][match[7]],
    ];
    print(
      'Debug: Target Words - Top: ${targetWords[0]}, Bottom: ${targetWords[1]}, Left: ${targetWords[2]}, Right: ${targetWords[3]}',
    );

    guesses = [[], [], [], []];
    guessFeedback = [[], [], [], []];
    currentGuess = '';
    currentSide = 0;
    incorrectGuesses = 0;
    hintsUsed = 0;
    // Use max length for all sides to avoid range errors
    final maxLength = max(wordLengthTopBottom, wordLengthLeftRight);
    hintedLetters = List.generate(4, (_) => List.filled(maxLength, null));
    startTime = DateTime.now();
    notifyListeners();
  }

  Future<void> markDailyCompleted() async {
    if (currentChallengeDate == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String key =
        '${currentChallengeDate!.year}-'
        '${currentChallengeDate!.month.toString().padLeft(2, '0')}-'
        '${currentChallengeDate!.day.toString().padLeft(2, '0')}';

    final List<String> list =
        prefs.getStringList('completed_daily_dates') ?? [];
    if (!list.contains(key)) {
      list.add(key);
      await prefs.setStringList('completed_daily_dates', list);
    }

    currentChallengeDate = null;
    notifyListeners();
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void setCurrentSide(int side) {
    currentSide = side;
    currentGuess = '';
    notifyListeners();
  }

  void addLetter(String letter) {
    if (!isGameOver &&
        currentGuess.length <
            (currentSide < 2 ? wordLengthTopBottom : wordLengthLeftRight)) {
      currentGuess += letter;
      notifyListeners();
    }
  }

  void removeLetter() {
    if (!isGameOver && currentGuess.isNotEmpty) {
      currentGuess = currentGuess.substring(0, currentGuess.length - 1);
      notifyListeners();
    }
  }

  int findNextEmptySide() {
    int side = (currentSide + 1) % 4;
    while (guesses[side].contains(targetWords[side]) && side != currentSide) {
      side = (side + 1) % 4;
    }
    return side;
  }

  bool submitGuess() {
    if (isGameOver ||
        currentGuess.length !=
            (currentSide < 2 ? wordLengthTopBottom : wordLengthLeftRight)) {
      currentGuess = '';
      notifyListeners();
      return false;
    }

    guesses[currentSide].add(currentGuess);
    guessFeedback[currentSide].add(
      _getFeedback(currentGuess, targetWords[currentSide]),
    );
    if (currentGuess != targetWords[currentSide]) {
      incorrectGuesses++;
    }
    if (currentGuess == targetWords[currentSide]) {
      currentSide = findNextEmptySide();
    }
    currentGuess = '';

    if (incorrectGuesses >= maxGuesses || isPuzzleSolved()) {
      isGameOver = true;
    }
    notifyListeners();
    return true;
  }

  List<String> _getFeedback(String guess, String target) {
    List<String> feedback = List.filled(guess.length, 'red');
    List<bool> targetUsed = List.filled(target.length, false);
    List<bool> guessUsed = List.filled(guess.length, false);

    for (int i = 0; i < guess.length; i++) {
      if (guess[i] == target[i]) {
        feedback[i] = 'green';
        targetUsed[i] = true;
        guessUsed[i] = true;
      }
    }

    for (int i = 0; i < guess.length; i++) {
      if (!guessUsed[i]) {
        for (int j = 0; j < target.length; j++) {
          if (!targetUsed[j] && guess[i] == target[j]) {
            feedback[i] = 'yellow';
            targetUsed[j] = true;
            break;
          }
        }
      }
    }
    return feedback;
  }

  bool isPuzzleSolved() {
    return guesses[0].contains(targetWords[0]) &&
        guesses[1].contains(targetWords[1]) &&
        guesses[2].contains(targetWords[2]) &&
        guesses[3].contains(targetWords[3]);
  }

  void addExtraGuess() {
    maxGuesses += 1;
    isGameOver = false;
    isContinuing = true;
    notifyListeners();
  }

  void useHint() {
    if (!isGameOver) {
      final random = Random();
      final side = currentSide;
      final wordLength = side < 2 ? wordLengthTopBottom : wordLengthLeftRight;
      final isSolved = guesses[side].contains(targetWords[side]);
      final inset = side < 2 ? horizontalInset : verticalInset;
      final altSide1 = side < 2 ? 2 : 0;
      final altSide2 = side < 2 ? 3 : 1;
      List<int> availablePositions = [];
      if (!isSolved) {
        for (int i = 0; i < wordLength; i++) {
          bool isHinted = hintedLetters[side][i] != null;
          // Check if this position intersects with a solved word
          bool isIntersectionSolved = false;
          if (i == inset && guesses[altSide1].contains(targetWords[altSide1])) {
            isIntersectionSolved = true;
          }
          if (i == (wordLength - inset - 1) &&
              guesses[altSide2].contains(targetWords[altSide2])) {
            isIntersectionSolved = true;
          }
          if (!isHinted && !isIntersectionSolved) {
            availablePositions.add(i);
          }
        }
      }
      if (availablePositions.isNotEmpty) {
        int pos = availablePositions[random.nextInt(availablePositions.length)];
        hintedLetters[side][pos] =
            targetWords[side].codeUnitAt(pos) -
            'A'.codeUnitAt(0); // Store letter index (A=0, B=1, etc.)
        hintsUsed++;
        // Check if this completes the word (no unfilled letters)
        bool isComplete = availablePositions.length == 1;
        if (isComplete) {
          guesses[side].add(targetWords[side]);
          guessFeedback[side].add(List.filled(wordLength, 'green'));
          currentSide = findNextEmptySide();
          if (isPuzzleSolved()) isGameOver = true;
        }
        notifyListeners();
      }
    }
  }

  bool CanHint() {
    final side = currentSide;
    final wordLength = side < 2 ? wordLengthTopBottom : wordLengthLeftRight;
    final isSolved = guesses[side].contains(targetWords[side]);
    final inset = side < 2 ? horizontalInset : verticalInset;
    final altSide1 = side < 2 ? 2 : 0;
    final altSide2 = side < 2 ? 3 : 1;
    int nHintsAvail = 0;
    if (!isSolved) {
      for (int i = 0; i < wordLength; i++) {
        bool isHinted = hintedLetters[side][i] != null;
        // Check if this position intersects with a solved word
        bool isIntersectionSolved = false;
        if (i == inset && guesses[altSide1].contains(targetWords[altSide1])) {
          isIntersectionSolved = true;
        }
        if (i == (wordLength - inset - 1) &&
            guesses[altSide2].contains(targetWords[altSide2])) {
          isIntersectionSolved = true;
        }
        if (!isHinted && !isIntersectionSolved) {
          nHintsAvail++;
        }
      }
    }

    return nHintsAvail != 0;
  }

  String? getDifficulty() => difficulty;
  DateTime getStartTime() => startTime;
  int getIncorrectGuesses() => incorrectGuesses;
  int getHintsUsed() => hintsUsed;
}
