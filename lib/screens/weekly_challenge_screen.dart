import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqwordlex/widgets/my_scaffold.dart';

import '../main.dart'; // For routeObserver
import 'gameplay_screen.dart';

DateTime weeklyEpoch = DateTime(2026, 1, 1);
const int puzzlesPerWeek = 36; // 6x6 grid

DateTime getWeekStart(DateTime date) {
  // Weeks start on Monday
  int weekday = date.weekday;
  return date.subtract(Duration(days: weekday - DateTime.monday));
}

int getWeekId(DateTime weekStart) {
  final days = weekStart.difference(weeklyEpoch).inDays;
  return (days ~/ 7) + 1;
}

String _getMonthName(int month) {
  const months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[month];
}

String formatWeekRange(DateTime start) {
  final DateTime end = start.add(const Duration(days: 6));
  final String startStr = '${_getMonthName(start.month)} ${start.day}';
  final String endStr = '${_getMonthName(end.month)} ${end.day}, ${end.year}';
  return '$startStr – $endStr';
}

String getDifficultyForPuzzle(int weekId, int puzzleIndex) {
  final Random random = Random(weekId * 10000 + puzzleIndex);
  return ['Easy', 'Medium', 'Hard'][random.nextInt(3)];
}

int getSeedForPuzzle(int weekId, int puzzleIndex) {
  return weekId * 10000 + puzzleIndex;
}

class WeeklyChallengeScreen extends StatefulWidget {
  const WeeklyChallengeScreen({super.key});

  @override
  State<WeeklyChallengeScreen> createState() => _WeeklyChallengeScreenState();
}

class _WeeklyChallengeScreenState extends State<WeeklyChallengeScreen>
    with RouteAware {
  late DateTime currentWeekStart;
  late DateTime earliestWeekStart;
  Map<int, List<bool>> completedByWeek = {};

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    currentWeekStart = getWeekStart(now);
    earliestWeekStart = getWeekStart(weeklyEpoch);
    _loadCompleted();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadCompleted();
  }

  Future<void> _loadCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonStr = prefs.getString('weekly_completed') ?? '{}';
    final Map<String, dynamic> decoded = jsonDecode(jsonStr);

    final Map<int, List<bool>> newMap = {};
    decoded.forEach((strKey, value) {
      final int weekId = int.parse(strKey);
      final List<dynamic> dynList = value as List;
      final List<bool> boolList = dynList.map((e) => e as bool).toList();
      if (boolList.length != puzzlesPerWeek) {
        newMap[weekId] = List<bool>.filled(puzzlesPerWeek, false);
      } else {
        newMap[weekId] = boolList;
      }
    });

    if (mounted) {
      setState(() {
        completedByWeek = newMap;
      });
    }
  }

  int? _findNextUnplayedIndex() {
    final int weekId = getWeekId(currentWeekStart);
    final List<bool> completed =
        completedByWeek[weekId] ?? List<bool>.filled(puzzlesPerWeek, false);
    for (int i = 0; i < puzzlesPerWeek; i++) {
      if (!completed[i]) {
        return i;
      }
    }
    return null;
  }

  void _playPuzzle(int puzzleIndex) {
    final int weekId = getWeekId(currentWeekStart);
    final int seed = getSeedForPuzzle(weekId, puzzleIndex);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameplayScreen(
          fixedSeed: seed,
          weeklyId: weekId,
          weeklyPuzzleIndex: puzzleIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime todayWeekStart = getWeekStart(DateTime.now());
    final bool isCurrentWeek = currentWeekStart.isAtSameMomentAs(
      todayWeekStart,
    );

    final DateTime previousWeekStart = currentWeekStart.subtract(
      const Duration(days: 7),
    );
    final DateTime nextWeekStart = currentWeekStart.add(
      const Duration(days: 7),
    );

    final bool canGoPrevious =
        previousWeekStart.compareTo(earliestWeekStart) >= 0;
    final bool canGoNext = nextWeekStart.compareTo(todayWeekStart) <= 0;

    final int weekId = getWeekId(currentWeekStart);
    final List<bool> currentCompleted =
        completedByWeek[weekId] ?? List<bool>.filled(puzzlesPerWeek, false);
    final int completedCount = currentCompleted.where((b) => b).length;

    final int? nextIndex = _findNextUnplayedIndex();

    return MyScaffold(
      appBar: AppBar(
        title: const Text('Weekly Challenges'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              width: 820.0, // ← match your other screens
              height:
                  1100.0, // ← tune this: portrait natural height + margin (start here, measure & adjust)
              child: Column(
                children: [
                  // Week navigation and info
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: canGoPrevious
                                  ? () {
                                      setState(() {
                                        currentWeekStart = previousWeekStart;
                                      });
                                    }
                                  : null,
                            ),
                            Column(
                              children: [
                                Text(
                                  'Week of ${formatWeekRange(currentWeekStart)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (isCurrentWeek)
                                  const Text(
                                    'Current Week',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: canGoNext
                                  ? () {
                                      setState(() {
                                        currentWeekStart = nextWeekStart;
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Completed $completedCount / $puzzlesPerWeek',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  // 6x6 grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 6,
                      padding: const EdgeInsets.all(8),
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1.0,
                      children: List.generate(puzzlesPerWeek, (index) {
                        final bool isCompleted = currentCompleted[index];
                        final String difficulty = getDifficultyForPuzzle(
                          weekId,
                          index,
                        );

                        final String iconPath = difficulty == 'Easy'
                            ? 'assets/icons/icon_easy_game.svg'
                            : difficulty == 'Medium'
                            ? 'assets/icons/icon_med_game.svg'
                            : 'assets/icons/icon_hard_game.svg';

                        return Card(
                          color: nextIndex == null
                              ? Colors.deepOrange[50]
                              : isCompleted
                              ? Colors.grey[200]
                              : Colors.grey[50],
                          elevation: nextIndex == null
                              ? 4
                              : isCompleted
                              ? 2
                              : 6,
                          shadowColor: nextIndex == null ? Colors.white : null,
                          child: InkWell(
                            onTap: () => _playPuzzle(index),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: 0.40,
                                    child: SvgPicture.asset(
                                      iconPath,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        difficulty,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          decoration: isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      if (isCompleted)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 28,
                                        ),
                                      if (!isCompleted && isCurrentWeek)
                                        const Text(
                                          'New',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Play next unplayed button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: Colors.grey[50],
                      ),
                      onPressed: nextIndex == null
                          ? () {}
                          : () => _playPuzzle(nextIndex),
                      child: Text(
                        nextIndex == null
                            ? 'Week Complete! (Tap any puzzle to replay)'
                            : 'Play Next Unplayed Puzzle',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
