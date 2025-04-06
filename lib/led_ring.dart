import 'package:flutter/material.dart';
import 'package:hurrigame/bluetooth_manager.dart';
import 'package:hurrigame/button_screen.dart';
import 'package:hurrigame/utils/logger.dart';

enum RingSection {
  left(0),
  right(1),
  firstQuarter(2),
  secondQuarter(3),
  thirdQuarter(4),
  forthQuarter(5);

  final int value;
  const RingSection(this.value);
}

class LedRing extends StatelessWidget {
  LedRing(this.name, this.serviceUUID, this.characteristicsUUID, {Key? key})
    : super(key: key);

  final String name;
  final String serviceUUID;
  final String characteristicsUUID;
  final statusColor = Colors.white;
  bool _isConnected = false;

  late final BluetoothManager bluetoothManager;

  void setBluetoothManager(BluetoothManager manager) {
    bluetoothManager = manager;
  }

  void setConnected(bool connected) {
    _isConnected = connected;
    bluetoothLogger.info('LED-Ring Connected: $_isConnected');
    connectionKey.currentState?.setConnectedIndicator(_isConnected);
  }

  bool get isConnected => _isConnected;

  void setColor(Color color) {
    if (!_isConnected) {
      bluetoothLogger.info('Not connected to LED ring');
      return;
    }
    final rgbString =
        '${(color.r * 255).toInt()},${(color.g * 255).toInt()},${(color.b * 255).toInt()}';
    bluetoothLogger.info(rgbString);
    bluetoothManager.writeStringToCharacteristic(
      '{"state":"STATIC","parameter":[{"color":"$rgbString"}]}',
    );
  }

  void setIdle() {
    if (!_isConnected) {
      bluetoothLogger.info('Not connected to LED ring');
      return;
    }
    bluetoothManager.writeStringToCharacteristic('{"state":"IDLE"}');
  }

  void setRainbow() {
    if (!_isConnected) {
      bluetoothLogger.info('Not connected to LED ring');
      return;
    }
    bluetoothManager.writeStringToCharacteristic('{"state":"RAINBOW"}');
  }

  void setRainbowWipe() {
    if (!_isConnected) {
      bluetoothLogger.info('Not connected to LED ring');
      return;
    }
    bluetoothManager.writeStringToCharacteristic('{"state":"RAINBOW_WIPE"}');
  }

  void freeze() {
    if (!_isConnected) {
      bluetoothLogger.info('Not connected to LED ring');
      return;
    }
    bluetoothManager.writeStringToCharacteristic('{"state":"FREEZE"}');
  }

  void pulse(Color color) {
    if (!_isConnected) {
      bluetoothLogger.info('Not connected to LED ring');
      return;
    }
    final rgbString =
        '${(color.r * 255).toInt()},${(color.g * 255).toInt()},${(color.b * 255).toInt()}';
    bluetoothLogger.info(rgbString);
    bluetoothManager.writeStringToCharacteristic(
      '{"state":"PULSE","parameter":[{"color":"$rgbString"}]}',
    );
  }

  void roulette(Color color) {
    if (!_isConnected) {
      bluetoothLogger.info('Not connected to LED ring');
      return;
    }
    final rgbString =
        '${(color.r * 255).toInt()},${(color.g * 255).toInt()},${(color.b * 255).toInt()}';
    bluetoothManager.writeStringToCharacteristic(
      '{"state":"ROULETTE","parameter":[{"color":"$rgbString"}]}',
    );
  }

  void randomNumber(Color color, int numberOfLeds) {
    if (!_isConnected) {
      bluetoothLogger.info('Not connected to LED ring');
      return;
    }
    final rgbString =
        '${(color.r * 255).toInt()},${(color.g * 255).toInt()},${(color.b * 255).toInt()}';
    bluetoothManager.writeStringToCharacteristic(
      '{"state":"RANDOM_NUMBER","parameter":[{"color":"$rgbString"},{"number":"$numberOfLeds"}]}',
    );
  }

  void shuffleSection(Color color) {
    if (!_isConnected) {
      bluetoothLogger.info('Not connected to LED ring');
      return;
    }
    final rgbString =
        '${(color.r * 255).toInt()},${(color.g * 255).toInt()},${(color.b * 255).toInt()}';
    bluetoothManager.writeStringToCharacteristic(
      '{"state":"SHUFFLE_SECTIONS","parameter":[{"color":"$rgbString"}]}',
    );
  }

  void setSection(Color color, RingSection section) {
    if (!_isConnected) {
      bluetoothLogger.info('Not connected to LED ring');
      return;
    }
    final rgbString =
        '${(color.r * 255).toInt()},${(color.g * 255).toInt()},${(color.b * 255).toInt()}';
    final sectionValue = section.value;
    bluetoothLogger.info(section.value);
    bluetoothManager.writeStringToCharacteristic(
      '{"state":"SHOW_SECTION","parameter":[{"color":"$rgbString"},{"number":"$sectionValue"}]}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(
          100,
          100,
        ), // Keep it a circle by making width=height
        backgroundColor: statusColor,
        shape: const CircleBorder(
          side: BorderSide(color: Colors.black, width: 10),
        ),
      ),
      onPressed: () {
        bluetoothLogger.info("Pressed Ring!");
      },
      child: const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
