import 'package:flutter/material.dart';

class GameButton extends StatelessWidget {
  GameButton(this.color, {super.key});

  var color = Colors.red;

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
        // onPressed logic
      },
      child: const Text(
        '',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}