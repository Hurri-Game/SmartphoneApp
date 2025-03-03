import 'package:flutter/material.dart';
import 'package:hurrigame/bluetooth_manager.dart';
import 'package:hurrigame/action_button.dart';
import 'package:hurrigame/game_engine.dart';
import 'package:hurrigame/led_ring.dart';
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

  late LedRing ledRing;

  @override
  void initState() {
    super.initState();
    soundManager = SoundManager();
    soundManager.initState();

    // Initialize buttons first, without callbacks
    redButton = ActionButton(
      'HurriButton_Bullshit',
      Colors.red,
      () {}, // temporary empty callback
    );
    greenButton = ActionButton(
      'GreenActionButton',
      Colors.green,
      () {}, // temporary empty callback
    );
    blueButton = ActionButton(
      'BlueActionButton',
      Colors.blue,
      () {}, // temporary empty callback
    );

    ledRing = LedRing(
      'HurriRing',
      '4fafc201-1fb5-459e-8fcc-c5c9c331914b',
      'beb5483e-36e1-4688-b7f5-ea07361b26a8',
    );

    bluetoothManager = BluetoothManager([
      redButton,
      greenButton,
      blueButton,
    ], ledRing);

    gameEngine = GameEngine(soundManager, ledRing);

    ledRing.setBluetoothManager(bluetoothManager);
    redButton.setCallback(gameEngine.redButtonPressed);
    greenButton.setCallback(gameEngine.greenButtonPressed);
    blueButton.setCallback(gameEngine.blueButtonPressed);

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
            redButton,
            SizedBox(height: 20),
            greenButton,
            SizedBox(height: 20),
            blueButton,
          ],
        ),
      ),
    );
  }
}
