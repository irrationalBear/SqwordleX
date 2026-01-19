import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/game_state.dart';
import 'screens/splash_screen.dart'; // New import

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const SquordleXApp());
}

class SquordleXApp extends StatelessWidget {
  const SquordleXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      child: MaterialApp(
        title: 'SqwordleX',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver], // NEW: enables RouteAware
      ),
    );
  }
}
