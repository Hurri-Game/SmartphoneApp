import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  ActionButton(this.name, this.color, this.onTap, {this.size, super.key});

  final Color color;
  final String name;
  final double? size; // Add size parameter
  late void Function() onTap;

  void setOnTapFunc(void Function() onTapFunc) {
    onTap = onTapFunc;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final buttonSize =
        size ?? screenSize.width * 0.45; // Use passed size or default
    final borderWidth = screenSize.width * 0.05;
    final borderRadius = screenSize.width * 0.1;
    final padding = screenSize.width * 0.02;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: Size(buttonSize, buttonSize),
          backgroundColor: color,
          side: BorderSide(color: Colors.black, width: borderWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onTap,
        child: const Text(''),
      ),
    );
  }
}
