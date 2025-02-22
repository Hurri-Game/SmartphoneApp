import 'package:flutter/material.dart';
import 'package:hurrigame/sound_manager.dart';

class GameButton extends StatelessWidget {
  const GameButton(this.color, this.soundManager, {super.key});

  final Color color;
  final SoundManager soundManager;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // Button's exact size
        fixedSize: const Size(200, 200), // width=80, height=80 (square)
        backgroundColor: color,
        side: const BorderSide(
          color: Colors.black,
          width: 30,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(60),
        ),
      ),
      onPressed: () {
        soundManager.playBullshit();
      },
      child: const Text(
        '',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}