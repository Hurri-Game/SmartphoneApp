import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  ActionButton(this.name, this.color, this.onPressedFunction, {super.key});

  final Color color;
  final String name;
  late VoidCallback onPressedFunction;

  void setCallback(VoidCallback callback) {
    onPressedFunction = callback;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // Button's exact size
        fixedSize: const Size(200, 200), // width=80, height=80 (square)
        backgroundColor: color,
        side: const BorderSide(color: Colors.black, width: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
      ),
      onPressed: () {
        onPressedFunction();
      },
      child: const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
