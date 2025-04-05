import 'package:hurrigame/led_ring.dart';
import 'package:flutter/material.dart';
import 'package:hurrigame/sound_manager.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hurrigame/games.dart';

enum EngineState { idle, gameRunning }

enum Games {
  flunkyball,
  rageCage,
  // beerPong,
}

class GameEngine {
  GameEngine(this.soundManager, this.ledRing);
  final Random random = Random();
  SoundManager soundManager;

  var currentGame = Games.flunkyball;
  var currentEngineState = EngineState.idle;
  Game? game;

  LedRing ledRing;
  //ledRing.setColor(Colors.green);
  //ledRing.setIdle();
  //ledRing.setRainbow();
  //ledRing.setRainbowWipe();
  //ledRing.pulse(Colors.green);
  //ledRing.roulette(Colors.red);
  //ledRing.randomNumber(Colors.green, 10);
  //ledRing.shuffleSection(Colors.green);
  //ledRing.setSection(Colors.green, RingSection.right);

  // void buttonPressed(String name) {
  //   print('$name pressed');
  // }

  void redButtonPressed() async {
    switch (currentEngineState) {
      case EngineState.idle:
        ledRing.setRainbow();
        String? soundFile =
            await getRandomSoundFile(); // Warten auf das Ergebnis
        if (soundFile != null) {
          await soundManager.playSound(soundFile); // Sound abspielen
          await soundManager.waitForSoundToFinish();
          ledRing.setIdle();
        } else {
          print("Kein Sound gefunden.");
        }
        break;
      case EngineState.gameRunning:
        game?.redButtonPressed();
        break;
    }
    print('Red Button Pressed!');
  }

  void greenButtonPressed() {
    switch (currentEngineState) {
      case EngineState.idle:
        playRandomGame();
        ledRing.roulette(Colors.orange);
        break;
      case EngineState.gameRunning:
        game?.greenButtonPressed();
        break;
    }
    print('Green Button Pressed!');
  }

  void blueButtonPressed() {
    switch (currentEngineState) {
      case EngineState.idle:
        ledRing.setColor(Colors.blue);
        break;
      case EngineState.gameRunning:
        game?.blueButtonPressed();
        break;
    }
    print('Blue Button Pressed!');
  }

  Future<String?> getRandomSoundFile() async {
    final String assetManifest = await rootBundle.loadString(
      'AssetManifest.json',
    );
    final Map<String, dynamic> manifest = json.decode(assetManifest);

    // Alle Dateien unter 'assets/sounds/bullshit/' filtern
    List<String> soundFiles =
        manifest.keys
            .where((String key) => key.startsWith('assets/sounds/bullshit/'))
            .map((String path) => path.replaceFirst('assets/', ''))
            .toList();

    if (soundFiles.isEmpty) {
      print("Keine Sounddateien gefunden!");
      return null; // Falls keine Dateien vorhanden sind
    }

    // Zufällige Datei auswählen
    String randomFile = soundFiles[random.nextInt(soundFiles.length)];
    print(randomFile);
    return randomFile;
  }

  Games getRandomGame() {
    return Games.values[random.nextInt(Games.values.length)];
  }

  void playRandomGame() {
    currentGame = getRandomGame();
    print("Next Game: $currentGame");
    switch (currentGame) {
      case Games.flunkyball:
        game = Flunkyball(soundManager, ledRing, idleGameEngine);
        break;
      case Games.rageCage:
        game = RageCage(soundManager, ledRing, idleGameEngine);
        break;
      default:
        throw Exception("Game $currentGame is not implemented yet.");
    }

    currentEngineState = EngineState.gameRunning;
    game?.play();
  }

  void idleGameEngine() {
    currentEngineState = EngineState.idle;
  }
}
