import 'package:flutter/material.dart';
import 'package:hurrigame/button_screen.dart';
import 'package:hurrigame/bluetooth_manager.dart';
import 'package:hurrigame/game_engine.dart';
import 'package:hurrigame/led_ring.dart';
import 'package:hurrigame/sound_manager.dart';
import 'package:hurrigame/data/action_buttons.dart';
import 'package:hurrigame/settings_screen.dart';
import 'package:hurrigame/settings_manager.dart';

class BeatBreaker extends StatefulWidget {
  const BeatBreaker({super.key});

  @override
  State<BeatBreaker> createState() {
    return _BeatBreakerState();
  }
}

class _BeatBreakerState extends State<BeatBreaker> {
  var activeScreen = 'button-screen';
  late BluetoothManager bluetoothManager;
  late SoundManager soundManager;
  late GameEngine gameEngine;
  late LedRing ledRing;

  @override
  void initState() {
    super.initState();
    soundManager = SoundManager();
    soundManager.initState("silent");

    // Initialize settings manager
    SettingsManager().initialize();

    // Initialize buttons first, without callbacks

    ledRing = LedRing(
      'HurriRing',
      '4fafc201-1fb5-459e-8fcc-c5c9c331914b',
      'beb5483e-36e1-4688-b7f5-ea07361b26a8',
    );

    bluetoothManager = BluetoothManager(buttons, ledRing);
    gameEngine = GameEngine(soundManager, ledRing);

    ledRing.setBluetoothManager(bluetoothManager);
    buttons[0].setOnTapFunc(gameEngine.greenButtonPressed);
    buttons[1].setOnTapFunc(gameEngine.orangeButtonPressed);
    buttons[2].setOnTapFunc(gameEngine.redButtonPressed);

    bluetoothManager.startScan();
  }

  void switchScreen(String screenName) {
    setState(() {
      activeScreen = screenName; //QuestionsScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screenWidget = ButtonScreen(switchScreen, ledRing: ledRing);

    if (activeScreen == 'button-screen') {
      screenWidget = ButtonScreen(switchScreen, ledRing: ledRing);
    } else if (activeScreen == 'settings-screen') {
      screenWidget = SettingsScreen(switchScreen);
    }

    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 97, 97, 99),
                Color.fromARGB(255, 40, 35, 50),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: screenWidget,
        ),
      ),
    );
  }
}
