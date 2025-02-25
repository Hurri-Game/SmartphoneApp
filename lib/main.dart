import 'package:flutter/material.dart';
import 'package:hurrigame/bluetooth_manager.dart';
import 'package:hurrigame/action_button.dart';
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

  late ActionButton redButton;
  late ActionButton greenButton;
  late ActionButton blueButton;

  @override
  void initState() {
    super.initState();
    soundManager = SoundManager();
    soundManager.initState();

    gameEngine = GameEngine(soundManager);
    
    redButton = ActionButton('RedActionButton', Colors.red, gameEngine.redButtonPressed);
    greenButton = ActionButton('GreenActionButton', Colors.green, gameEngine.greenButtonPressed);
    blueButton = ActionButton('BlueActionButton', Colors.blue, gameEngine.blueButtonPressed);

    bluetoothManager = BluetoothManager([redButton, greenButton, blueButton]);
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
