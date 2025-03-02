import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import 'dart:convert';

import 'package:hurrigame/action_button.dart';
import 'package:hurrigame/led_ring.dart';

class BluetoothManager {
  BluetoothManager(this.buttons, this.ledRing);

  final List<ActionButton> buttons;
  final LedRing ledRing;
  final flutterBlue = FlutterBlue.instance;

  // Remove these since they come from ledRing now
  String get targetDeviceName => ledRing.name;
  Guid get serviceGuid => Guid(ledRing.serviceUUID);
  Guid get characteristicGuid => Guid(ledRing.characteristicsUUID);

  StreamSubscription<ScanResult>? _scanSubscription;
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? targetCharacteristic;

  /// Add this field
  bool _isConnecting = false;

  // Add map to track last detection time for each button
  final Map<String, DateTime> _lastDetectionTimes = {};
  static const _cooldownDuration = Duration(seconds: 1);

  /// Call this once, and it will keep scanning (and listening) indefinitely
  void startScan() async {
    // Prevent double-scanning
    if (_scanSubscription != null) {
      print("Already scanning...");
      return;
    }

    // First, ensure Bluetooth is on
    if (await flutterBlue.isAvailable == false) {
      print("Bluetooth is not available on this device");
      return;
    }

    if (await flutterBlue.isOn == false) {
      print("Bluetooth is turned off");
      return;
    }

    //print(">>> Starting Scan...");
    _scanSubscription = flutterBlue
        .scan(
          // Add scan settings for better detection
          timeout: const Duration(seconds: 4),
          allowDuplicates: true,
          scanMode: ScanMode.lowLatency,
        )
        .listen(
          (result) {
            final device = result.device;
            final deviceName = device.name.trim();
            // Add RSSI logging to help debug detection issues

            //print(
            //  "Found device: $deviceName | ${result.device.id} | RSSI: ${result.rssi}",
            //);

            // 1) Check if device is a "beacon" for any of your ActionButtons
            for (var button in buttons) {
              if (button.name == deviceName) {
                // Check cooldown period
                final lastDetection = _lastDetectionTimes[deviceName];
                final now = DateTime.now();
                if (lastDetection == null ||
                    now.difference(lastDetection) > _cooldownDuration) {
                  button.onPressedFunction();
                  _lastDetectionTimes[deviceName] = now;
                }
              }
            }

            // 2) Check if device is the one you want to connect to
            //    e.g. maybe you have a property `targetDeviceName`.
            //    Or you pass it in from outside. This is just an example:
            if (deviceName == targetDeviceName) {
              print("Found target device: $deviceName");
              _connectToDevice(device);
            }
          },
          onError: (error) {
            print("Scan error: $error");
            stopScan();
            // Restart scan after error with delay
            Future.delayed(const Duration(seconds: 2), () {
              startScan();
            });
          },
        );

    // Restart scan periodically to prevent Android scan throttling
    Future.delayed(const Duration(seconds: 1), () async {
      await stopScan();
      startScan();
    });
  }

  Future<void> stopScan() async {
    //print(">>> Stopping Scan...");
    if (_scanSubscription != null) {
      await _scanSubscription!.cancel();
      _scanSubscription = null;
    }
    await flutterBlue.stopScan();
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    // Prevent multiple connection attempts
    if (_isConnecting || connectedDevice != null) {
      print("Already connected or connecting...");
      return;
    }

    _isConnecting = true;
    try {
      print("Connecting to ${device.name}...");
      await device.connect();
      print("Connected to ${device.name}");

      connectedDevice = device;

      print("Discovering services...");
      final services = await device.discoverServices();
      print("Services discovered.");

      for (BluetoothService s in services) {
        if (s.uuid == serviceGuid) {
          print("Found target service: $serviceGuid");
          for (BluetoothCharacteristic c in s.characteristics) {
            if (c.uuid == characteristicGuid) {
              targetCharacteristic = c;
              print("Found target characteristic: $characteristicGuid");
              // If you want, you can now read, write, or setNotify on c.
              // You can keep scanning in the background or stop scanning,
              // depending on your needs.
              return;
            }
          }
        }
      }
      print("Target service/characteristic not found on ${device.name}.");
    } catch (e) {
      print("Error while connecting: $e");
      connectedDevice?.disconnect();
      connectedDevice = null;
    } finally {
      _isConnecting = false;
    }
  }

  /// Example write method
  Future<void> writeStringToCharacteristic(String data) async {
    if (targetCharacteristic == null) {
      print('Characteristic not found or not set.');
      connectedDevice = null;
      return;
    }

    try {
      final bytes = utf8.encode(data);
      await targetCharacteristic!.write(bytes, withoutResponse: false);
      print('Wrote: $data');
    } catch (e) {
      print('Error writing: $e');
      connectedDevice?.disconnect();
      connectedDevice = null;
    }
  }
}
