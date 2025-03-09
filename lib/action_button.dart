import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  ActionButton(this.name, this.color, this.onTap, {super.key});

  final Color color;
  final String name;
  late void Function() onTap;

  void setOnTapFunc(void Function() onTapFunc) {
    onTap = onTapFunc;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20), // space outside the button
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(200, 200),
          backgroundColor: color,
          side: const BorderSide(color: Colors.black, width: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          // minimal or no padding here
          padding: EdgeInsets.zero,
        ),
        onPressed: onTap,
        child: const Text(''),
      ),
    );
  }
}
