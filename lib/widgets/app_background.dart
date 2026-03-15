import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  // Change this string to try different backgrounds instantly!
  // (assets/backgrounds/sqwordle_tile.png is the default)
  static const String texturePath = 'assets/backgrounds/wood_oak.jpeg';

  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(texturePath),
          repeat: ImageRepeat.repeat,
          fit: BoxFit.none, // important for true tiling
          opacity: 0.92, // keeps it subtle even with bolder textures
        ),
      ),
    );
  }
}
