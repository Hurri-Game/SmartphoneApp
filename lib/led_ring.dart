import 'package:flutter/material.dart';
import 'package:hurrigame/bluetooth_manager.dart';

class LedRing extends StatelessWidget {
  const LedRing(
    this.name,
    this.serviceUUID,
    this.characteristicsUUID,
    this.bluetoothManager, {
    Key? key,
  }) : super(key: key);

  final String name;
  final String serviceUUID;
  final String characteristicsUUID;
  final BluetoothManager bluetoothManager;
  final statusColor = Colors.white;

  void setColor(Color color) {
    final rgbString = '${color.red},${color.green},${color.blue}';
    print(rgbString);
    bluetoothManager.writeStringToCharacteristic(
      '{\"state\":\"STATIC\",\"parameter\":[{\"color\":\"$rgbString\"}]}',
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
        print("Pressed Ring!");
        setColor(Colors.white);
      },
      child: const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
