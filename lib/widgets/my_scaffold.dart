import 'package:flutter/material.dart';

import 'app_background.dart';

class MyScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const MyScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This is the key fix
      extendBodyBehindAppBar: true,

      // AppBar now floats on top of the background
      appBar: appBar,

      // Background covers the entire screen (including under AppBar)
      body: Stack(
        children: [
          const AppBackground(), // ← now under everything
          SafeArea(
            // keeps your content from going under status bar
            child: body,
          ),
        ],
      ),

      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,

      // Important: make scaffold itself transparent
      backgroundColor: Colors.transparent,
    );
  }
}
