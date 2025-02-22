import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:hurrigame/game_button.dart';

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
  final flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult>? _scanSubscription;

  final AudioPlayer _audioPlayer = AudioPlayer();
  static const _audioControlChannel = MethodChannel('com.example.audio_control');

  @override
  void initState() {
    super.initState();    // Listen for playback completion, then manually deactivate iOS session
    _audioPlayer.onPlayerComplete.listen((event) {
      debugPrint("Audio playback complete. Now deactivating audio session.");
      _deactivateAudioSession();
      _startScan();
    });
    _configureIosAudioSession();
  }

  Future<void> _configureIosAudioSession() async {
    await _audioPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.duckOthers,
          },
        ),
      ),
    );
  }

  // Calls Swift code to setActive(false).
  Future<void> _deactivateAudioSession() async {
    try {
      await _audioControlChannel.invokeMethod('deactivateAudioSession');
    } catch (e) {
      debugPrint('Error calling deactivateAudioSession: $e');
    }
  }  

  void _startScan() async {
    await _stopScan();

    _scanSubscription = flutterBlue.scan().listen((result) {
      final device = result.device;
      final deviceName = device.name.trim();

      // Look for the "HurriButton_Bullshit" name
      if (deviceName == 'HurriButton_Bullshit') {
        _playBeep();    // Duck others and play beep
      }
    }, onError: (error) {
      _stopScan();
    });
  }

  Future<void> _stopScan() async {
    if (_scanSubscription != null) {
      await _scanSubscription!.cancel();
      _scanSubscription = null;
    }
    await flutterBlue.stopScan();
  }

  Future<void> _playBeep() async {
    // beep.mp3 must be declared in pubspec.yaml under assets:
    // assets/sounds/beep.mp3
    try {
      await _audioPlayer.play(AssetSource('sounds/2024.mp3'));
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _stopScan();
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
            GameButton(Colors.red),
            SizedBox(height: 20),
            GameButton(Colors.green),
            SizedBox(height: 20),
            GameButton(Colors.blue),
          ],
        ),
      ),
    );
  }
}
