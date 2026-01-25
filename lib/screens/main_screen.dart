import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'game_select_screen.dart';
import 'daily_challenge_screen.dart';
import 'weekly_challenge_screen.dart';

enum BadgeType { none, unplayed, completed }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool dailyHasUnplayed = true;
  bool weeklyHasUnplayed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDailyStatus();
    _loadWeeklyStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadDailyStatus();
      _loadWeeklyStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadDailyStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> completedDates =
        prefs.getStringList('completed_daily_dates') ?? [];

    final DateTime now = DateTime.now();
    final String todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (mounted) {
      setState(() {
        dailyHasUnplayed = !completedDates.contains(todayKey);
      });
    }
  }

  Future<void> _loadWeeklyStatus() async {
    DateTime now = DateTime.now();
    DateTime curWeek = now.subtract(
      Duration(days: now.weekday - DateTime.monday),
    );
    int weekID = (curWeek.difference(DateTime(2026, 1, 1)).inDays ~/ 7) + 1;
    bool finishedPlay = false;

    final prefs = await SharedPreferences.getInstance();
    final String jsonStr = prefs.getString('weekly_completed') ?? '{}';
    final Map<String, dynamic> decoded = jsonDecode(jsonStr);

    decoded.forEach((strKey, value) {
      if (int.parse(strKey) == weekID) {
        final List<dynamic> dynList = value as List;
        final List<bool> boolList = dynList.map((e) => e as bool).toList();
        if (boolList.length == puzzlesPerWeek) {
          finishedPlay = true;
        }
      }
    });

    if (mounted) {
      setState(() {
        weeklyHasUnplayed = !finishedPlay;
      });
    }
  }

  Widget _buildMenuButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required BadgeType badgeType,
  }) {
    Widget? badgeWidget;
    if (badgeType == BadgeType.unplayed) {
      badgeWidget = Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          'NEW',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    } else if (badgeType == BadgeType.completed) {
      badgeWidget = Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.check, color: Colors.white, size: 28),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  text,
                  style: const TextStyle(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        if (badgeWidget != null)
          Positioned(top: -10, right: -10, child: badgeWidget),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 200.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  'SqwordleX',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ),

              const SizedBox(height: 80),
              _buildMenuButton(
                text: 'Play Game',
                icon: Icons.play_circle_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameSelectScreen(),
                    ),
                  );
                },
                badgeType: BadgeType.none,
              ),
              const SizedBox(height: 40),
              _buildMenuButton(
                text: 'Daily Challenge',
                icon: Icons.calendar_today,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DailyChallengeScreen(),
                    ),
                  ).then((_) {
                    _loadDailyStatus();
                    _loadWeeklyStatus();
                  });
                },
                badgeType: dailyHasUnplayed
                    ? BadgeType.unplayed
                    : BadgeType.completed,
              ),
              const SizedBox(height: 40),
              _buildMenuButton(
                text: 'Weekly Challenge',
                icon: Icons.date_range,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WeeklyChallengeScreen(),
                    ),
                  ).then((_) {
                    _loadDailyStatus();
                    _loadWeeklyStatus();
                  });
                },
                badgeType: weeklyHasUnplayed
                    ? BadgeType.unplayed
                    : BadgeType.completed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
