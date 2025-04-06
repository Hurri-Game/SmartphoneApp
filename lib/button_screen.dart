import 'package:flutter/material.dart';
import 'package:hurrigame/data/action_buttons.dart';

final GlobalKey<ButtonScreenState> connectionKey =
    GlobalKey<ButtonScreenState>();

class ButtonScreen extends StatefulWidget {
  ButtonScreen(this.switchScreen, {Key? key}) : super(key: connectionKey);

  final void Function(String screenName) switchScreen;

  @override
  State<ButtonScreen> createState() {
    return ButtonScreenState();
  }
}

class ButtonScreenState extends State<ButtonScreen> {
  var ringStatusColor = Colors.black;

  void setConnectedIndicator(var connected) {
    setState(() {
      ringStatusColor = connected ? Colors.green : Colors.black;
    });
  }

  @override
  Widget build(context) {
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.10;
    final padding = screenSize.width * 0.05;

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: buttons,
          ),
        ),

        // Bottom-right icon
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Icon(
              Icons.device_hub,
              size: iconSize,
              color: ringStatusColor,
            ),
          ),
        ),

        // Settings icon
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: IconButton(
              icon: Icon(Icons.settings, size: iconSize, color: Colors.black),
              onPressed: () {
                widget.switchScreen('settings-screen');
              },
            ),
          ),
        ),
      ],
    );
  }
}
