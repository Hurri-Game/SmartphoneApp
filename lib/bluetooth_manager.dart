import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';

import 'package:hurrigame/game_button.dart';

class BluetoothManager {
  BluetoothManager(this.buttons);

  final List<GameButton> buttons;

  final flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult>? _scanSubscription;


  void startScan() async {
    await stopScan();

    _scanSubscription = flutterBlue.scan().listen((result) {
      final device = result.device;
      final deviceName = device.name.trim();

      for (var button in buttons) {
        if (button.name == deviceName) {
          print("Found: $deviceName");
          button.onPressedFunction();
          startScan();
        }
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
