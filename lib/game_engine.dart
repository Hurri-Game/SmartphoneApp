import 'package:hurrigame/led_ring.dart';
import 'package:flutter/material.dart';
import 'package:hurrigame/sound_manager.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hurrigame/games.dart';
import 'package:hurrigame/utils/logger.dart';

enum EngineState { idle, gameRunning }

enum Games {
  guessTheNumber,
  flunkyball,
  rageCage,
  roulette,
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

  void redButtonPressed() async {
    switch (currentEngineState) {
      case EngineState.idle:
        ledRing.setRainbow();
        String? soundFile =
            await getRandomSoundFile(); // Warten auf das Ergebnis
        if (soundFile != null) {
          await soundManager.playSound(
            soundFile,
            sessionType: "duck",
          ); // Sound abspielen
          await soundManager.waitForSoundToFinish();
          ledRing.setIdle();
        } else {
          gameLogger.info("Kein Sound gefunden.");
        }
        break;
      case EngineState.gameRunning:
        game?.redButtonPressed();
        break;
    }
    gameLogger.info('Red Button Pressed!');
  }

  void greenButtonPressed() {
    switch (currentEngineState) {
      case EngineState.idle:
        playRandomGame();

        break;
      case EngineState.gameRunning:
        game?.greenButtonPressed();
        break;
    }
    gameLogger.info('Green Button Pressed!');
  }

  void orangeButtonPressed() {
    switch (currentEngineState) {
      case EngineState.idle:
        ledRing.setColor(Colors.blue);
        break;
      case EngineState.gameRunning:
        game?.orangeButtonPressed();
        break;
    }
    gameLogger.info('Blue Button Pressed!');
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
      gameLogger.info("Keine Sounddateien gefunden!");
      return null; // Falls keine Dateien vorhanden sind
    }

    // Zufällige Datei auswählen
    String randomFile = soundFiles[random.nextInt(soundFiles.length)];
    gameLogger.info(randomFile);
    return randomFile;
  }

  // games
  Games getRandomGame() {
    return Games.values[random.nextInt(Games.values.length)];
  }

  void playRandomGame() {
    currentGame = getRandomGame();
    gameLogger.info("Next Game: $currentGame");
    switch (currentGame) {
      case Games.flunkyball:
        game = Flunkyball(soundManager, ledRing, idleGameEngine);
        break;
      case Games.rageCage:
        game = RageCage(soundManager, ledRing, idleGameEngine);
        break;
      case Games.roulette:
        game = Roulette(soundManager, ledRing, idleGameEngine);
        break;
      case Games.guessTheNumber:
        game = GuessTheNumber(soundManager, ledRing, idleGameEngine);
        break;
      default:
        throw Exception("Game $currentGame is not implemented yet.");
    }

    currentEngineState = EngineState.gameRunning;
    //game = GuessTheNumber(soundManager, ledRing, idleGameEngine);
    game?.play();
  }

  void idleGameEngine() {
    currentEngineState = EngineState.idle;
  }
}
