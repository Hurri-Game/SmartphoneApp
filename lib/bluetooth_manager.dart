import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:convert';
import 'package:hurrigame/action_button.dart';
import 'package:hurrigame/led_ring.dart';

class BluetoothManager {
  BluetoothManager(this.buttons, this.ledRing);

  final List<ActionButton> buttons;
  final LedRing ledRing;
  final flutterBlue = FlutterBluePlus.instance;

  // Remove these since they come from ledRing now
  String get targetDeviceName => ledRing.name;
  Guid get serviceGuid => Guid(ledRing.serviceUUID);
  Guid get characteristicGuid => Guid(ledRing.characteristicsUUID);

  var _scanSubscription;
  var _connecting = false;
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? targetCharacteristic;

  // Add map to track last detection time for each button
  final Map<String, DateTime> _lastDetectionTimes = {};
  static const _cooldownDuration = Duration(seconds: 1);

  /// Call this once, and it will keep scanning (and listening) indefinitely
  void startScan() {
    if (_scanSubscription != null) {
      print("Already scanning...");
      return;
    }

    // Updated availability check
    if (FlutterBluePlus.isSupported == false) {
      print("Bluetooth is not available on this device");
      return;
    }

    if (_connecting) {
      print("Currently connecting to device");
      return;
    }

    print("Starting scan...");
    // setup supscription
    _scanSubscription = FlutterBluePlus.scanResults.listen(
      (result) {
        if (result.isNotEmpty) {
          final device = result.last.device;
          final deviceName = device.platformName.trim();

          // Action Buttons
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

          // LED-Ring
          if (deviceName == targetDeviceName && !_connecting) {
            _connecting = true;
            stopScan(); // Stop scanning before connecting
            _connectToDevice(device); // Wait for connection to complete
          }
        }
      },
      onError: (error) {
        print("Scan error: $error");
        stopScan();
        // Restart scan after error with delay
        Future.delayed(const Duration(seconds: 2), () {
          print("delayed error start scan");
          startScan();
        });
      },
    );

    if (!_connecting) {
      // start scanning
      FlutterBluePlus.startScan();

      // Restart scan periodically to prevent Android scan throttling
      Future.delayed(const Duration(seconds: 1), () async {
        await stopScan();
        print("delayed start scan");
        startScan();
      });
    }
  }

  Future<void> stopScan() async {
    if (_scanSubscription != null) {
      print("Cancle subscription");
      FlutterBluePlus.cancelWhenScanComplete(_scanSubscription);
      await _scanSubscription!.cancel();
      _scanSubscription = null;
    }
    await FlutterBluePlus.stopScan();
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (ledRing.isConnected) {
      print("Already connected");
      _connecting = false;
      return;
    }
    try {
      print("Connecting to ${device.platformName}...");
      await device.connect();
      print("Connected to ${device.platformName}");

      connectedDevice = device;
      ledRing.setConnected(true);

      print("Discovering services...");
      final services = await device.discoverServices().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print("Service discovery timed out");
          throw TimeoutException('Service discovery timed out');
        },
      );
      print("Services discovered: ${services.length} services found");

      // Log all discovered services to help debug
      for (var service in services) {
        print("Found service: ${service.uuid}");
      }

      for (BluetoothService s in services) {
        if (s.uuid == serviceGuid) {
          print("Found target service: $serviceGuid");
          for (BluetoothCharacteristic c in s.characteristics) {
            if (c.uuid == characteristicGuid) {
              targetCharacteristic = c;
              print("Found target characteristic: $characteristicGuid");
              _connecting = false;
              print("characteristic start scan");
              startScan();
              // If you want, you can now read, write, or setNotify on c.
              // You can keep scanning in the background or stop scanning,
              // depending on your needs.
              return;
            }
          }
        }
      }
      print("characteristic not found start scan");
      _connecting = false;
      startScan();
      print("Target service/characteristic not found on ${device.name}.");
    } catch (e) {
      print("Error while connecting: $e");
      _connecting = false;
      connectedDevice?.disconnect();
      connectedDevice = null;
      ledRing.setConnected(false);
      print("error connect to device start scan");
      startScan();
    }
  }

  /// Example write method
  Future<void> writeStringToCharacteristic(String data) async {
    if (targetCharacteristic == null || !ledRing.isConnected) {
      print('Not connected or characteristic not found');
      connectedDevice = null;
      ledRing.setConnected(false);
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
      ledRing.setConnected(false);
    }
  }
}
