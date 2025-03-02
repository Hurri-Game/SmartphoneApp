import 'package:flutter/material.dart';
import 'package:hurrigame/bluetooth_manager.dart';

class LedRing extends StatelessWidget {
  LedRing(this.name, this.serviceUUID, this.characteristicsUUID, {Key? key})
    : super(key: key);

  final String name;
  final String serviceUUID;
  final String characteristicsUUID;
  final statusColor = Colors.white;

  // Make bluetoothManager late final instead of final
  late final BluetoothManager bluetoothManager;

  void setBluetoothManager(BluetoothManager manager) {
    bluetoothManager = manager;
  }

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
      },
      child: const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
