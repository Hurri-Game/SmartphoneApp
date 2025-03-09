import 'package:flutter/material.dart';
import 'package:hurrigame/data/action_buttons.dart';

final GlobalKey<_ButtonScreenState> connectionKey =
    GlobalKey<_ButtonScreenState>();

class ButtonScreen extends StatefulWidget {
  ButtonScreen(this.switchScreen, {Key? key}) : super(key: connectionKey);

  final void Function(String screenName) switchScreen;

  @override
  State<ButtonScreen> createState() {
    return _ButtonScreenState();
  }
}

class _ButtonScreenState extends State<ButtonScreen> {
  var ringStatusColor = Colors.black;

  void setConnectedIndicator(var connected) {
    setState(() {
      if (connected) {
        ringStatusColor = Colors.green;
      } else {
        ringStatusColor = Colors.black;
      }
    });
  }

  @override
  Widget build(context) {
    return Stack(
      children: [
        // Your existing centered layout
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [...buttons],
          ),
        ),

        // Bottom-right icon
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Icon(Icons.device_hub, size: 50, color: ringStatusColor),
          ),
        ),

        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: IconButton(
              icon: Icon(Icons.settings, size: 50, color: Colors.black),
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
