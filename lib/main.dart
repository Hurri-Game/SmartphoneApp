import 'package:flutter/material.dart';
import 'package:hurrigame/bluetooth_manager.dart';
import 'package:hurrigame/game_button.dart';
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

  late SoundManager soundManager;
  late BluetoothManager bluetoothManager;

  @override
  void initState() {
    super.initState();
    soundManager = SoundManager();
    soundManager.initState();

    bluetoothManager = BluetoothManager(soundManager);
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
            GameButton(Colors.red, soundManager),
            SizedBox(height: 20),
            GameButton(Colors.green, soundManager),
            SizedBox(height: 20),
            GameButton(Colors.blue, soundManager),
          ],
        ),
      ),
    );
  }
}
