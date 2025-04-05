import 'package:hurrigame/led_ring.dart';
import 'package:flutter/material.dart';
import 'package:hurrigame/sound_manager.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hurrigame/games.dart';

enum EngineState
{
  idle,
  gameRunning,
}

enum Games {
  flunkyball,
  // rageCage,
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
    print('Red Button Pressed!');
    ledRing.setRainbow();
    String? soundFile = await getRandomSoundFile(); // Warten auf das Ergebnis
    if (soundFile != null) {
      soundManager.playSound(soundFile); // Sound abspielen
    } else {
      print("Kein Sound gefunden.");
    }
  }

  void greenButtonPressed() {
    if (currentEngineState == EngineState.idle) {
      playRandomGame();
    } else if (currentEngineState == EngineState.gameRunning) {
      game?.greenButtonPressed();
      currentEngineState = EngineState.idle;
    }
    print('Green Button Pressed!');
    ledRing.roulette(Colors.orange);
  }

  void blueButtonPressed() {
    print('Blue Button Pressed!');
    ledRing.setColor(Colors.blue);
    ledRing.freeze();
  }

  void soundPlayed() {
    ledRing.setColor(Colors.black);
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

  String getRandomGame() {
    return Games.values[
        random.nextInt(Games.values.length)].name;
  }

  void playRandomGame() {
    String nextGame = getRandomGame();
    print("Next Game: $nextGame");
    if (nextGame == "flunkyball") {
      game = Flunkyball(soundManager, ledRing, idleGameEngine);
      currentGame = Games.flunkyball;
      }
    else
    {
      print("$nextGame is not implemented yet.");
      return;
    }
      currentEngineState = EngineState.gameRunning;
      game?.play();
    // } else if (nextGame == "RageCage") {
    //   currentGame = Games.rageCage;
    //   game = RageCage(soundManager, ledRing);
    // } else if (nextGame == "BeerPong") {
    //   currentGame = Games.beerPong;
    //   game = BeerPong(soundManager, ledRing);
    // }
  }

  void idleGameEngine() {
    currentEngineState = EngineState.idle;
  }
}
