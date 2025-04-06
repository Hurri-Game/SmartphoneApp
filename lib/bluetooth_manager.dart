import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hurrigame/action_button.dart';
import 'dart:async';
import 'dart:convert';
import 'package:hurrigame/led_ring.dart';
import 'package:permission_handler/permission_handler.dart';
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

  Future<bool> checkPermissions() async {
    try {
      // Request location permission first
      var locationStatus = await Permission.locationWhenInUse.request();
      bluetoothLogger.info("Location permission status: $locationStatus");

      if (locationStatus.isPermanentlyDenied) {
        bluetoothLogger.warning("Location permission permanently denied");
        return false;
      }

      if (!locationStatus.isGranted) {
        bluetoothLogger.warning("Location permission not granted");
        return false;
      }

      // Request Bluetooth permissions
      var bluetoothStatus = await Permission.bluetooth.request();
      bluetoothLogger.info("Bluetooth permission status: $bluetoothStatus");

      if (bluetoothStatus.isPermanentlyDenied) {
        bluetoothLogger.warning("Bluetooth permission permanently denied");
        return false;
      }

      if (!bluetoothStatus.isGranted) {
        bluetoothLogger.warning("Bluetooth permission not granted");
        return false;
      }

      return true;
    } catch (e, stackTrace) {
      bluetoothLogger.severe("Error checking permissions", e, stackTrace);
      return false;
    }
  }

  Future<void> requestBluetoothPermissions() async {
    try {
      // Request all necessary permissions
      await [
        Permission.locationWhenInUse,
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();
    } catch (e, stackTrace) {
      bluetoothLogger.severe("Error requesting permissions", e, stackTrace);
    }
  }

  Future<void> startBluetoothOn() async {
    try {
      BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
      bluetoothLogger.info("Current Bluetooth state: $state");

      if (state == BluetoothAdapterState.on) {
        bluetoothLogger.info("Bluetooth is on. Starting scan...");
      } else {
        bluetoothLogger.info("Bluetooth is off. Please enable it.");
      }
    } catch (e, stackTrace) {
      bluetoothLogger.severe("Error checking Bluetooth state", e, stackTrace);
    }
  }

  /// Call this once, and it will keep scanning (and listening) indefinitely
  void startScan() async {
    try {
      if (_scanSubscription != null) {
        bluetoothLogger.warning("Already scanning...");
        return;
      }

      // Check permissions first
      await requestBluetoothPermissions();
      final hasPermissions = await checkPermissions();

      if (!hasPermissions) {
        bluetoothLogger.warning(
          "Required permissions not granted. Please enable them in settings.",
        );
        return;
      }

      // Updated availability check
      if (FlutterBluePlus.isSupported == false) {
        bluetoothLogger.warning("Bluetooth is not available on this device");
        return;
      }

      if (_connecting) {
        bluetoothLogger.info("Currently connecting to device");
        return;
      }

      bluetoothLogger.info("Starting scan...");

      // Add a small delay before starting the scan, otherwise no devices are found
      await Future.delayed(const Duration(milliseconds: 500));

      // setup subscription
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          bluetoothLogger.info(
            "Scan results received: ${results.length} devices found",
          );
          if (results.isNotEmpty && !_connecting) {
            for (final result in results) {
              final device = result.device;
              final deviceName = device.platformName.trim();
              final rssi = result.rssi;
              bluetoothLogger.info("Found Device: $deviceName (RSSI: $rssi)");

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
                _connectToDevice(device); // Wait for connection to complete
              }
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
        if (FlutterBluePlus.isScanning == true) {
          bluetoothLogger.warning("Already scanning...");
        } else {
          bluetoothLogger.info("Starting initial scan...");
          FlutterBluePlus.startScan(oneByOne: true, continuousUpdates: true);
        }
      }
    } catch (e, stackTrace) {
      bluetoothLogger.severe("Error starting scan", e, stackTrace);
      // Retry after error
      Future.delayed(const Duration(seconds: 2), () {
        bluetoothLogger.info("Retrying scan after error...");
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
      startScan();
      return;
    }
    try {
      bluetoothLogger.info("Connecting to ${device.name}...");
      await device.connect();
      bluetoothLogger.info("Connected to ${device.name}");

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
