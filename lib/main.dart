import 'package:flutter/material.dart';
import 'package:hurrigame/bluetooth_manager.dart';
import 'package:hurrigame/game_button.dart';
import 'package:hurrigame/game_engine.dart';
import 'package:hurrigame/sound_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hurrigame',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BleAudioPage(),
    );
  }
}

class BleAudioPage extends StatefulWidget {
  const BleAudioPage({super.key});
  @override
  State<BleAudioPage> createState() => _BleAudioPageState();
}

class _BleAudioPageState extends State<BleAudioPage> {

  late BluetoothManager bluetoothManager;

  late SoundManager soundManager;

  late GameEngine gameEngine;

  late GameButton bullshitButton;
  late GameButton drinkButton;
  late GameButton challengeButton;

  @override
  void initState() {
    super.initState();
    soundManager = SoundManager();
    soundManager.initState();

    gameEngine = GameEngine(soundManager);
    
    bullshitButton = GameButton('HurriButton_Bullshit', Colors.red, gameEngine.playRandomBullshit);
    drinkButton = GameButton('HurriButton_Drink', Colors.green, gameEngine.startDrink);
    challengeButton = GameButton('HurriButton_Challenge', Colors.blue, gameEngine.startChallenge);

    bluetoothManager = BluetoothManager([bullshitButton, drinkButton, challengeButton]);
    bluetoothManager.startScan();
  }

  @override
  void dispose() {
    bluetoothManager.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Hurrigame')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            bullshitButton,
            SizedBox(height: 20),
            drinkButton,
            SizedBox(height: 20),
            challengeButton,
          ],
        ),
      ),
    );
  }
}
