import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import 'package:hurrigame/sound_manager.dart';

class BluetoothManager {
  BluetoothManager(this.soundManager);

  final SoundManager soundManager;
  final flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult>? _scanSubscription;


  void startScan() async {
    await stopScan();

    _scanSubscription = flutterBlue.scan().listen((result) {
      final device = result.device;
      final deviceName = device.name.trim();

      // Look for the "HurriButton_Bullshit" name
      if (deviceName == 'HurriButton_Bullshit') {
        soundManager.playBullshit();
        startScan();
      }
    }, onError: (error) {
      stopScan();
    });
  }

  Future<void> stopScan() async {
    if (_scanSubscription != null) {
      await _scanSubscription!.cancel();
      _scanSubscription = null;
    }
    await flutterBlue.stopScan();
  }
}
