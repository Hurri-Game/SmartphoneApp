import 'dart:async';
import 'dart:math';

import 'package:hurrigame/sound_manager.dart';
import 'package:hurrigame/led_ring.dart';
import 'package:flutter/material.dart';
import 'package:hurrigame/utils/logger.dart';
import 'package:hurrigame/utils/csv_colors.dart';

abstract class Game {
  Game(this.ledRing, this.stopCallback, {this.deactivateAfterPlayback = true}) {
    soundManager = SoundManager(
      deactivateAfterPlayback: deactivateAfterPlayback,
    );
    soundManager.initState('silent');
    gameLogger.info('Game initialized with sound manager and led ring.');
  }

  // final SoundManager _soundManager;
  final bool deactivateAfterPlayback;
  late final SoundManager soundManager;

  final LedRing? ledRing;
  final void Function() stopCallback;
  bool _isStopped = false;
  bool _buttonBlocked = false;

  void greenButtonPressed();
  void redButtonPressed();
  void orangeButtonPressed();

  void play() {
    ledRing?.pulse(const Color.fromARGB(255, 0, 255, 8));
  }

  void stop() async {
    if (_isStopped) {
      gameLogger.info('Game is already stopped, returning early.');
      return;
    }
    _isStopped = true;
    _buttonBlocked = false;
    await soundManager.destroy();
    ledRing?.setIdle();
    stopCallback();
  }

  bool get isStopped => _isStopped;
}

class Flunkyball extends Game {
  Flunkyball(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  @override
  void greenButtonPressed() {
    gameLogger.info('Flunkyball Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('Flunkyball Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('Flunkyball Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    gameLogger.info('Flunkyball is being played!');
    await soundManager.playSound('sounds/games/flunky-song.mp3');
    await soundManager.waitForSoundToFinish();
    // stopCallback();
    // gameLogger.info('Flunkyball stopped!');
    stop();
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('Flunkyball stopped!');
  }
}

class RageCage extends Game {
  RageCage(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback, deactivateAfterPlayback: false);

  @override
  void greenButtonPressed() {
    gameLogger.info('RageCage Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('RageCage Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('RageCage Orange Button Pressed!');
  }

  @override
  void play() async {
    gameLogger.info('RageCage is being played!');
    super.play();
    await soundManager.playSound('sounds/games/rage_im_kaefig.mp3');
    await soundManager.waitForSoundToFinish();
    ledRing?.setIdle();
    if (isStopped) {
      print("In is stopped, returning early");
      return;
    }

    gameLogger.info('RageCage play before loop!');
    await soundManager.loopSound('sounds/games/GoranBregovic_GasGas.mp3');
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('RageCage stopped!');
  }
}

class Roulette extends Game {
  Roulette(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  // bool runRoulette = false;
  Random random = Random();

  @override
  void greenButtonPressed() async {
    if (!_buttonBlocked) {
      _buttonBlocked = true;
      gameLogger.info('Roulette Green Button Pressed!');
      await runRoulette();
      _buttonBlocked = false;
    }
  }

  @override
  void redButtonPressed() {
    gameLogger.info('Roulette Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() async {
    if (!_buttonBlocked) {
      _buttonBlocked = true;
      gameLogger.info('Roulette Orange Button Pressed!');
      await runRoulette();
      _buttonBlocked = false;
    }
  }

  @override
  void play() async {
    _buttonBlocked = true;
    super.play();
    gameLogger.info('Roulette is being played!');
    await soundManager.playSound('sounds/games/roulette.mp3');
    await soundManager.waitForSoundToFinish();
    _buttonBlocked = false;
  }

  Future<void> runRoulette() async {
    int waitTime = random.nextInt(5) + 5;
    gameLogger.info("Got $waitTime seconds in runRoulette");
    ledRing?.roulette(Colors.cyan);
    // wait for waitTime seconds
    await Future.delayed(Duration(seconds: waitTime.toInt()), () {
      if (!isStopped) {
        ledRing?.freeze();
        gameLogger.info('Roulette stopped!');
      }
    });
  }
}

class FarbenRaten extends Game {
  FarbenRaten(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);
  Random random = Random();
  late final List<ColorEntry> colorEntries;
  bool showColor = true;
  ColorEntry currentColor = ColorEntry(name: 'white', color: Colors.white);

  @override
  Future<void> greenButtonPressed() async {
    if (!_buttonBlocked) {
      _buttonBlocked = true;
      gameLogger.info('FarbenRaten Green Button Pressed!');
      await runFarbenRaten();
      _buttonBlocked = false;
    }
  }

  @override
  void redButtonPressed() {
    gameLogger.info('FarbenRaten Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() async {
    if (!_buttonBlocked) {
      _buttonBlocked = true;
      gameLogger.info('FarbenRaten Orange Button Pressed!');
      await runFarbenRaten();
      _buttonBlocked = false;
    }
  }

  @override
  Future<void> play() async {
    super.play();
    _buttonBlocked = true;
    gameLogger.info('FarbenRaten is being played!');

    colorEntries = await loadColorEntries('assets/color_insults/colors.csv');
    gameLogger.info("Loaded ${colorEntries.length} color entries");

    await soundManager.playSound('sounds/games/farbenraten.mp3');
    await soundManager.waitForSoundToFinish();
    _buttonBlocked = false;
  }

  ColorEntry getRandomColor() {
    int randomIndex = random.nextInt(colorEntries.length);
    gameLogger.info('Random Index: $randomIndex');
    gameLogger.info("length: ${colorEntries.length}");
    return colorEntries[randomIndex];
  }

  Future<void> runFarbenRaten() async {
    if (showColor) {
      gameLogger.info('show random color');
      currentColor = getRandomColor();
      ledRing?.setColor(currentColor.color);
      gameLogger.info('Random Color: $currentColor');
      showColor = false;
    } else {
      gameLogger.info("hide color");
      ledRing?.pulse(Colors.white);
      await Future.delayed(const Duration(seconds: 3));
      ledRing?.setColor(currentColor.color);
      await soundManager.playSound(
        'sounds/color_sounds/${currentColor.name}.mp3',
      );
      showColor = true;
      await soundManager.waitForSoundToFinish();
    }
  }
}

class GuessTheNumber extends Game {
  GuessTheNumber(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);
  // bool numberShown = true;
  int numberToDisplay = 0;
  Random random = Random();

  @override
  void greenButtonPressed() async {
    if (!_buttonBlocked) {
      _buttonBlocked = true;
      gameLogger.info('GuessTheNumber Green Button Pressed!');
      await runGuessTheNumber();
      _buttonBlocked = false;
    }
  }

  @override
  void redButtonPressed() {
    gameLogger.info('GuessTheNumber Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() async {
    if (!_buttonBlocked) {
      _buttonBlocked = true;
      gameLogger.info('GuessTheNumber Orange Button Pressed!');
      await runGuessTheNumber();
      _buttonBlocked = false;
    }
  }

  @override
  void play() async {
    _buttonBlocked = true;
    super.play();
    gameLogger.info('GuessTheNumber is being played!');
    // numberShown = true;
    await soundManager.playSound('sounds/games/lichterraten.mp3');
    await soundManager.waitForSoundToFinish();
    _buttonBlocked = false;
  }

  Future<void> runGuessTheNumber() async {
    numberToDisplay = random.nextInt(60);
    gameLogger.info('Random no. leds: $numberToDisplay');
    ledRing?.randomNumber(Colors.cyan, numberToDisplay);
    await Future.delayed(const Duration(seconds: 5));
    ledRing?.setColor(const Color.fromARGB(255, 255, 255, 255));
    await soundManager.playSound('sounds/numbers/$numberToDisplay.mp3');
    await soundManager.waitForSoundToFinish();
  }
}

class ChooseSide extends Game {
  ChooseSide(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  Random random = Random();

  @override
  void greenButtonPressed() async {
    if (!_buttonBlocked) {
      _buttonBlocked = true;
      gameLogger.info('ChooseSide Green Button Pressed!');
      await runChooseSide();
      _buttonBlocked = false;
    }
  }

  @override
  void redButtonPressed() {
    gameLogger.info('ChooseSide Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() async {
    if (!_buttonBlocked) {
      _buttonBlocked = true;
      gameLogger.info('ChooseSide Orange Button Pressed!');
      await runChooseSide();
      _buttonBlocked = false;
    }
  }

  @override
  void play() async {
    _buttonBlocked = true;
    super.play();
    gameLogger.info('ChooseSide is being played!');
    await soundManager.playSound('sounds/games/chooseside.mp3');
    await soundManager.waitForSoundToFinish();
    _buttonBlocked = false;
  }

  Future<void> runChooseSide() async {
    Random random = Random();
    int waitTime = random.nextInt(5) + 5;

    ledRing?.setIdle();
    ledRing?.shuffleSection(Colors.white);
    await Future.delayed(Duration(seconds: waitTime), () {
      ledRing?.setSection(
        Colors.red,
        RingSection.values[random.nextInt(RingSection.values.length)],
      );
    });
  }
}

class Beerpong extends Game {
  Beerpong(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  @override
  void greenButtonPressed() {
    gameLogger.info('Beerpong Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('Beerpong Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('Beerpong Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    gameLogger.info('Beerpong is being played!');
    await soundManager.playSound('sounds/games/bierpong.mp3');
    await soundManager.waitForSoundToFinish();
    stop();
    // gameLogger.info('Beerpong stopped!');
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('Beerpong stopped!');
  }
}

class ShortDrinkingGame extends Game {
  ShortDrinkingGame(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  final List<String> shortGames = [
    "geradesitzen",
    "geradestehen",
    "huttragen",
    "keinenhuttragen",
    "keinesonnenbrilletragen",
    "sonnenbrilletragen",
    "trichter",
    "zigarette",
  ];

  Random random = Random();

  @override
  void greenButtonPressed() {
    gameLogger.info('SingleDrinkGame Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('SingleDrinkGame Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('SingleDrinkGame Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    String nextGame = getRandomShortGame();
    gameLogger.info("$nextGame is being played");
    await soundManager.playSound("sounds/games/$nextGame.mp3");
    await soundManager.waitForSoundToFinish();
    stop();
  }

  String getRandomShortGame() {
    return shortGames[random.nextInt(shortGames.length)];
  }
}
