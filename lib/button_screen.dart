import 'package:flutter/material.dart';
import 'package:hurrigame/data/action_buttons.dart';
import 'package:hurrigame/bluetooth_manager.dart';
import 'package:hurrigame/led_ring.dart';

final GlobalKey<_ButtonScreenState> connectionKey =
    GlobalKey<_ButtonScreenState>();

class ButtonScreen extends StatefulWidget {
  ButtonScreen(this.switchScreen, {Key? key, required this.ledRing})
    : super(key: connectionKey);

  final void Function(String screenName) switchScreen;
  final LedRing ledRing;

  @override
  State<ButtonScreen> createState() {
    return _ButtonScreenState();
  }
}

class _ButtonScreenState extends State<ButtonScreen> {
  var ringStatusColor = Colors.black;

  @override
  void initState() {
    super.initState();
    // Initialize the color based on the LED ring's connection status
    ringStatusColor = widget.ledRing.isConnected ? Colors.green : Colors.black;
  }

  void setConnectedIndicator(bool connected) {
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

        // LED Ring connection status icon
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
