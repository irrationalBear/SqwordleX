import 'package:flutter/material.dart';

import '../services/sound_manager.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    SoundManager().playSplash();
    _animationController.forward();

    // Navigate after animation
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Old black background (no MyScaffold)
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              // Fixed portrait size so it scales nicely in landscape
              width: 420.0,
              height: 780.0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Larger game icon
                    Image.asset(
                      'assets/images/sqwordlex_icon_trans.png',
                      width: 300,
                      height: 300,
                    ),
                    const SizedBox(height: 40),

                    // Title
                    const Text(
                      'SqwordleX',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // "from" text
                    const Text(
                      'from',
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white70,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Larger Irrational Bear logo
                    Image.asset(
                      'assets/images/irrational_bear_logo.png',
                      width: 200,
                      height: 243,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
