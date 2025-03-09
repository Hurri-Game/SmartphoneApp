import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen(this.switchScreen, {super.key});

  final void Function(String screenName) switchScreen;

  @override
  Widget build(context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 50, color: Colors.black),
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
