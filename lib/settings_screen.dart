import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen(this.switchScreen, {super.key});

  final void Function(String screenName) switchScreen;

  @override
  Widget build(context) {
    // Get screen size and calculate icon size
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.10; // Same 8% as ButtonScreen
    final padding = screenSize.width * 0.05; // Same 4% as ButtonScreen

    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: iconSize, color: Colors.black),
              onPressed: () {
                switchScreen('button-screen');
              },
            ),
          ),
        ),
      ],
    );
  }
}
