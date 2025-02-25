import 'package:hurrigame/sound_manager.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class GameEngine{
  GameEngine(this.soundManager);

  SoundManager soundManager;

  Future<void> redButtonPressed() async {
    String? soundFile = await getRandomSoundFile(); // Warten auf das Ergebnis
    if (soundFile != null) {
      soundManager.playSound(soundFile); // Sound abspielen
    } else {
      print("Kein Sound gefunden.");
    }
  }

  void greenButtonPressed(){
    print('Green Button Pressed!');
  }

  void blueButtonPressed(){
    print('Blue Button Pressed!');
  }


  Future<String?> getRandomSoundFile() async {
    final String assetManifest = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = json.decode(assetManifest);

    // Alle Dateien unter 'assets/sounds/bullshit/' filtern
    List<String> soundFiles = manifest.keys
      .where((String key) => key.startsWith('assets/sounds/bullshit/'))
      .map((String path) => path.replaceFirst('assets/', ''))
      .toList();

    if (soundFiles.isEmpty) {
      print("Keine Sounddateien gefunden!");
      return null; // Falls keine Dateien vorhanden sind
    }

    // Zufällige Datei auswählen
    Random random = Random();
    String randomFile = soundFiles[random.nextInt(soundFiles.length)];
    print(randomFile);
    return randomFile;
  }

}