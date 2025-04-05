import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hurrigame/action_button.dart';
import 'dart:async';
import 'dart:convert';
import 'package:hurrigame/led_ring.dart';
import 'package:hurrigame/utils/logger.dart';

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
  void startScan() async {
    if (_scanSubscription != null) {
      bluetoothLogger.info("Already scanning...");
      return;
    }

    if (await FlutterBluePlus.isAvailable == false) {
      bluetoothLogger.warning("Bluetooth is not available on this device");
      return;
    }

    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      bluetoothLogger.warning("Bluetooth is turned off");
      return;
    }

    if (_connecting) {
      bluetoothLogger.info("Currently connecting to device");
      return;
    }

    bluetoothLogger.info("Starting scan...");
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
                button.onTap();
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
        bluetoothLogger.severe("Scan error", error);
        stopScan();
        // Restart scan after error with delay
        Future.delayed(const Duration(seconds: 2), () {
          bluetoothLogger.info("delayed error start scan");
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
        bluetoothLogger.info("delayed start scan");
        startScan();
      });
    }
  }

  Future<void> stopScan() async {
    if (_scanSubscription != null) {
      bluetoothLogger.info("Cancle subscription");
      FlutterBluePlus.cancelWhenScanComplete(_scanSubscription);
      await _scanSubscription!.cancel();
      _scanSubscription = null;
    }
    await FlutterBluePlus.stopScan();
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (ledRing.isConnected) {
      bluetoothLogger.info("Already connected");
      _connecting = false;
      return;
    }
    try {
      bluetoothLogger.info("Connecting to ${device.platformName}...");
      await device.connect();
      bluetoothLogger.info("Connected to ${device.platformName}");

      connectedDevice = device;
      ledRing.setConnected(true);

      bluetoothLogger.info("Discovering services...");
      final services = await device.discoverServices().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          bluetoothLogger.severe("Service discovery timed out");
          throw TimeoutException('Service discovery timed out');
        },
      );
      bluetoothLogger.info(
        "Services discovered: ${services.length} services found",
      );

      // Log all discovered services to help debug
      for (var service in services) {
        bluetoothLogger.fine("Found service: ${service.uuid}");
      }

      for (BluetoothService s in services) {
        if (s.uuid == serviceGuid) {
          bluetoothLogger.info("Found target service: $serviceGuid");
          for (BluetoothCharacteristic c in s.characteristics) {
            if (c.uuid == characteristicGuid) {
              targetCharacteristic = c;
              bluetoothLogger.info(
                "Found target characteristic: $characteristicGuid",
              );
              _connecting = false;
              bluetoothLogger.info("characteristic start scan");
              startScan();
              // If you want, you can now read, write, or setNotify on c.
              // You can keep scanning in the background or stop scanning,
              // depending on your needs.
              return;
            }
          }
        }
      }
      bluetoothLogger.info("characteristic not found start scan");
      _connecting = false;
      startScan();
      bluetoothLogger.info(
        "Target service/characteristic not found on ${device.name}.",
      );
    } catch (e, stackTrace) {
      bluetoothLogger.severe("Error while connecting", e, stackTrace);
      _connecting = false;
      connectedDevice?.disconnect();
      connectedDevice = null;
      ledRing.setConnected(false);
      bluetoothLogger.info("error connect to device start scan");
      startScan();
    }
  }

  /// Example write method
  Future<void> writeStringToCharacteristic(String data) async {
    if (targetCharacteristic == null || !ledRing.isConnected) {
      bluetoothLogger.warning('Not connected or characteristic not found');
      connectedDevice = null;
      ledRing.setConnected(false);
      return;
    }

    try {
      final bytes = utf8.encode(data);
      await targetCharacteristic!.write(bytes, withoutResponse: false);
      bluetoothLogger.fine('Wrote: $data');
    } catch (e, stackTrace) {
      bluetoothLogger.severe('Error writing', e, stackTrace);
      connectedDevice?.disconnect();
      connectedDevice = null;
      ledRing.setConnected(false);
    }
  }
}
