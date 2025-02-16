import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE + Audioplayers 6.x Demo',
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
  bool _isScanning = false;
  String _statusText = 'Press SCAN to discover "HurriButton_Bullshit"';
  BluetoothDevice? _hurriButtonDevice;

  final AudioPlayer _audioPlayer = AudioPlayer();
  static const _audioControlChannel = MethodChannel('com.example.audio_control');

  @override
  void initState() {
    super.initState();    // Listen for playback completion, then manually deactivate iOS session
    _audioPlayer.onPlayerComplete.listen((event) {
      debugPrint("Audio playback complete. Now deactivating audio session.");
      _deactivateAudioSession();
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

    setState(() {
      _isScanning = true;
      _statusText = 'Scanning...';
      _hurriButtonDevice = null;
    });

    _scanSubscription = flutterBlue.scan().listen((result) {
      final device = result.device;
      final deviceName = device.name.trim();

      // Look for the "HurriButton_Bullshit" name
      if (deviceName == 'HurriButton_Bullshit') {
        setState(() {
          _hurriButtonDevice = device;
          _statusText = 'Found $deviceName (${device.id})';
        });

        _playBeep();    // Duck others and play beep
        _stopScan();
      }
    }, onError: (error) {
      setState(() => _statusText = 'Scan error: $error');
      _stopScan();
    });
  }

  Future<void> _stopScan() async {
    if (_scanSubscription != null) {
      await _scanSubscription!.cancel();
      _scanSubscription = null;
    }
    setState(() => _isScanning = false);
    await flutterBlue.stopScan();
  }

  Future<void> _playBeep() async {
    // beep.mp3 must be declared in pubspec.yaml under assets:
    // assets/sounds/beep.mp3
    try {
      await _audioPlayer.play(AssetSource('sounds/2024.mp3'));
    } catch (e) {
      setState(() => _statusText = 'Error playing sound: $e');
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
      appBar: AppBar(title: const Text('BLE + Audioplayers')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_statusText),
            const SizedBox(height: 16),
            if (_hurriButtonDevice != null)
              Text('Device: ${_hurriButtonDevice!.name} (${_hurriButtonDevice!.id})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isScanning ? _stopScan : _startScan,
        child: Icon(_isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}
