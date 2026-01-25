import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart'; // For routeObserver
import 'gameplay_screen.dart';

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

String getDifficultyForDate(DateTime date) {
  final int seed = date.year * 10000 + date.month * 100 + date.day;
  final random = Random(seed);
  final int index = random.nextInt(3);
  return ['Easy', 'Medium', 'Hard'][index];
}

String _dateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen>
    with RouteAware {
  late DateTime currentMonth;
  DateTime? selectedDate;
  Set<String> completedDates = <String>{};

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
    selectedDate = null; // Explicitly null on fresh entry
    _loadCompletedDates();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is ModalRoute<void>) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Reload completed dates AND clear selection whenever we return to this screen
    _loadCompletedDates();
    if (mounted) {
      setState(() {
        selectedDate = null;
      });
    }
  }

  Future<void> _loadCompletedDates() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('completed_daily_dates') ?? [];
    if (mounted) {
      setState(() {
        completedDates = list.toSet();
        final bool isCompleted = completedDates.contains(
          _dateKey(DateTime.now()),
        );
        if (!isCompleted) {
          selectedDate = DateTime.now();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    ).day;
    final DateTime firstDay = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    );
    final int firstDayColumn = firstDay.weekday % 7;

    final List<Widget> dayTiles = [];

    // Leading blanks (Sunday start)
    for (int i = 0; i < firstDayColumn; i++) {
      dayTiles.add(const SizedBox.shrink());
    }

    final DateTime today = DateTime.now();
    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime thisDate = DateTime(
        currentMonth.year,
        currentMonth.month,
        day,
      );
      final bool isToday =
          thisDate.year == today.year &&
          thisDate.month == today.month &&
          thisDate.day == today.day;
      final bool isFuture = thisDate.isAfter(today);
      final bool isCompleted = completedDates.contains(_dateKey(thisDate));
      final bool isSelected =
          selectedDate != null &&
          selectedDate!.year == thisDate.year &&
          selectedDate!.month == thisDate.month &&
          selectedDate!.day == thisDate.day;

      final String difficulty = getDifficultyForDate(thisDate);

      dayTiles.add(
        Card(
          color: isCompleted
              ? Colors.grey[300]
              : (isSelected ? Colors.blue[100] : Colors.white),
          elevation: isCompleted ? 1 : 4,
          child: InkWell(
            onTap: isFuture
                ? null
                : () {
                    setState(() {
                      selectedDate = thisDate;
                    });
                  },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isFuture ? Colors.grey[600] : Colors.black,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (isToday)
                    const Text(
                      'Today',
                      style: TextStyle(fontSize: 10, color: Colors.red),
                    ),
                  Text(
                    difficulty,
                    style: TextStyle(
                      fontSize: 12,
                      color: isFuture ? Colors.grey[600] : Colors.black,
                    ),
                  ),
                  if (isCompleted)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Challenges')),
      body: Column(
        children: [
          // Month navigation (unlimited past as discussed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      currentMonth = DateTime(
                        currentMonth.year,
                        currentMonth.month - 1,
                      );
                      selectedDate = null;
                    });
                  },
                ),
                Text(
                  '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed:
                      currentMonth.month == today.month &&
                          currentMonth.year == today.year
                      ? null
                      : () {
                          setState(() {
                            currentMonth = DateTime(
                              currentMonth.year,
                              currentMonth.month + 1,
                            );
                            selectedDate = null;
                          });
                        },
                ),
              ],
            ),
          ),
          // Weekday headers
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map(
                  (d) => Center(
                    child: Text(
                      d,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
          ),
          // Calendar grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              padding: const EdgeInsets.all(8),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: dayTiles,
            ),
          ),
          // Play button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              onPressed: (selectedDate == null || selectedDate!.isAfter(today))
                  ? null
                  : () {
                      final int seed =
                          selectedDate!.year * 10000 +
                          selectedDate!.month * 100 +
                          selectedDate!.day;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GameplayScreen(
                            fixedSeed: seed,
                            dailyDate: selectedDate,
                          ),
                        ),
                      );
                    },
              child: Text(
                selectedDate == null
                    ? 'Select a day to play'
                    : 'Play ${_getMonthName(selectedDate!.month)} ${selectedDate!.day}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
