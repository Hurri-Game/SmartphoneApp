import 'dart:async';
import 'dart:math';

import 'package:hurrigame/sound_manager.dart';
import 'package:hurrigame/led_ring.dart';
import 'package:flutter/material.dart';
import 'package:hurrigame/utils/logger.dart';
import 'package:hurrigame/utils/csv_colors.dart';

abstract class Game {
  Game(this.soundManager, this.ledRing, this.stopCallback);

  final SoundManager soundManager;
  final LedRing? ledRing;
  final void Function() stopCallback;
  bool _isStopped = false;

  void greenButtonPressed();
  void redButtonPressed();
  void orangeButtonPressed();

  void play() {
    ledRing?.pulse(Colors.green);
  }

  void stop() {
    _isStopped = true;
    soundManager.stopSound();
    ledRing?.setIdle();
    stopCallback();
  }

  bool get isStopped => _isStopped;
}

class Flunkyball extends Game {
  Flunkyball(
    SoundManager soundManager,
    LedRing? ledRing,
    void Function() stopCallback,
  ) : super(soundManager, ledRing, stopCallback);

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
    await soundManager.playSound('sounds/games/flunky-song.mp3');
    gameLogger.info('Flunkyball is being played!');
    await soundManager.waitForSoundToFinish();
    stopCallback();
    gameLogger.info('Flunkyball stopped!');
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('Flunkyball stopped!');
  }
}

class RageCage extends Game {
  RageCage(
    SoundManager soundManager,
    LedRing? ledRing,
    void Function() stopCallback,
  ) : super(soundManager, ledRing, stopCallback);

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
    gameLogger.info('RageCage play before loop!');
    if (isStopped) {
      return;
    }
    await soundManager.loopSound('sounds/games/GoranBregovic_GasGas.mp3');
  }

  @override
  void stop() {
    super.stop();
    soundManager.stopLoop();
    gameLogger.info('RageCage stopped!');
  }
}

class Roulette extends Game {
  Roulette(
    SoundManager soundManager,
    LedRing? ledRing,
    void Function() stopCallback,
  ) : super(soundManager, ledRing, stopCallback);

  bool runRoulette = false;
  Random random = Random();

  @override
  void greenButtonPressed() {
    gameLogger.info('Roulette Green Button Pressed!');
    int waitTime = random.nextInt(5) + 5;
    ledRing?.roulette(Colors.cyan);
    // wait for waitTime seconds
    Future.delayed(Duration(seconds: waitTime.toInt()), () {
      if (!isStopped) {
        ledRing?.freeze();
        gameLogger.info('Roulette stopped!');
      }
    });
  }

  @override
  void redButtonPressed() {
    gameLogger.info('Roulette Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('Roulette Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    gameLogger.info('Roulette is being played!');
    await soundManager.playSound('sounds/games/roulette.mp3');
    await soundManager.waitForSoundToFinish();
  }
}

class FarbenRaten extends Game {
  FarbenRaten(
    SoundManager soundManager,
    LedRing? ledRing,
    void Function() stopCallback,
  ) : super(soundManager, ledRing, stopCallback);
    Random random = Random();
  late final List<ColorEntry> colorEntries;
  bool showColor = true;
  ColorEntry currentColor = ColorEntry(name: 'white', color: Colors.white);

  @override
  Future<void> greenButtonPressed() async {
    gameLogger.info('FarbenRaten Green Button Pressed!');
    if (showColor) {
      gameLogger.info('show random color');
      currentColor = getRandomColor();
      ledRing?.setColor(currentColor.color);
      gameLogger.info('Random Color: $currentColor');
      showColor = false;
    } else {
      gameLogger.info("hide color");
      ledRing?.pulse(Colors.green);
      await Future.delayed(const Duration(seconds: 3));
      ledRing?.setColor(currentColor.color);
      await soundManager.playSound('sounds/color_sounds/${currentColor.name}.mp3');
      showColor = true;
    }
    }

  @override
  void redButtonPressed() {
    gameLogger.info('FarbenRaten Red Button Pressed!');
    stop();
  }

  @override
   void orangeButtonPressed() async {
    gameLogger.info('FarbenRaten Orange Button Pressed!');
    if (showColor) {
      gameLogger.info('show random color');
      currentColor = getRandomColor();
      ledRing?.setColor(currentColor.color);
      gameLogger.info('Random Color: $currentColor');
      showColor = false;
    } else {
      gameLogger.info("hide color");
      ledRing?.pulse(Colors.orange);
      await Future.delayed(const Duration(seconds: 3));
      ledRing?.setColor(currentColor.color);
      await soundManager.playSound('sounds/color_sounds/${currentColor.name}.mp3');
      showColor = true;
    }
  }

@override
Future<void> play() async {
  super.play();
  gameLogger.info('FarbenRaten is being played!');

  colorEntries = await loadColorEntries('assets/color_insults/colors.csv');
  gameLogger.info("Loaded ${colorEntries.length} color entries");

  await soundManager.playSound('sounds/games/farbenraten.mp3');
  await soundManager.waitForSoundToFinish();
}

ColorEntry getRandomColor() {
    int randomIndex = random.nextInt(colorEntries.length);
    gameLogger.info('Random Index: $randomIndex');
    gameLogger.info("length: ${colorEntries.length}");
    return colorEntries[randomIndex];
  }
}

class GuessTheNumber extends Game {
  GuessTheNumber(
    SoundManager soundManager,
    LedRing? ledRing,
    void Function() stopCallback,
  ) : super(soundManager, ledRing, stopCallback);
  bool numberShown = true;
  int numberToDisplay = 0;
  Random random = Random();

  @override
  void greenButtonPressed() {
    print('GuessTheNumber Green Button Pressed!');
    if (numberShown) {
      print('show random leds');
      numberToDisplay = random.nextInt(60);
      ledRing?.randomNumber(Colors.cyan, numberToDisplay);
      numberShown = false;
    } else {
      print("hide leds");
      ledRing?.setColor(Colors.green);
      numberShown = true;
      Future.delayed(const Duration(seconds: 2), () {
        bluetoothLogger.info("Call out number");
        soundManager.playSound('sounds/numbers/$numberToDisplay.mp3');
      });
    }
    print('Random no. leds: $numberToDisplay');
  }

  @override
  void redButtonPressed() {
    print('GuessTheNumber Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    print('GuessTheNumber Orange Button Pressed!');
    if (numberShown) {
      print('show random leds');
      numberToDisplay = random.nextInt(60);
      ledRing?.randomNumber(Colors.cyan, numberToDisplay);
      numberShown = false;
    } else {
      print("hide leds");
      ledRing?.setColor(Colors.orange);
      numberShown = true;
      Future.delayed(const Duration(seconds: 2), () {
        bluetoothLogger.info("Call out number");
        soundManager.playSound('sounds/numbers/$numberToDisplay.mp3');
      });
    }
    print('Random no. leds: $numberToDisplay');
  }

  @override
  void play() async {
    super.play();
    print('GuessTheNumber is being played!');
    numberShown = true;
    await soundManager.playSound('sounds/games/lichterraten.mp3');
    await soundManager.waitForSoundToFinish();
  }
}

class ChooseSide extends Game {
  ChooseSide(
    SoundManager soundManager,
    LedRing? ledRing,
    void Function() stopCallback,
  ) : super(soundManager, ledRing, stopCallback);

  Random random = Random();

  @override
  void greenButtonPressed() {
    print('ChooseSide Green Button Pressed!');

    Random random = Random();
    int waitTime = random.nextInt(5) + 5;

    ledRing?.setIdle();
    ledRing?.shuffleSection(Colors.white);
    Future.delayed(Duration(seconds: waitTime), () {
      ledRing?.setSection(
        Colors.red,
        RingSection.values[random.nextInt(RingSection.values.length)],
      );
    });
  }

  @override
  void redButtonPressed() {
    print('ChooseSide Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    print('ChooseSide Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    print('ChooseSide is being played!');
    await soundManager.playSound('sounds/games/chooseside.mp3');
    await soundManager.waitForSoundToFinish();
  }
}

class Challenge extends Game {
  Challenge(
    SoundManager soundManager,
    LedRing? ledRing,
    void Function() stopCallback,
  ) : super(soundManager, ledRing, stopCallback);

  @override
  void greenButtonPressed() {
    print('Challenge Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    print('Challenge Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    print('Challenge Orange Button Pressed!');
  }

  @override
  void play() {
    ledRing?.pulse(Colors.orange);
  }
}

class Beerpong extends Game {
  Beerpong(
    SoundManager soundManager,
    LedRing? ledRing,
    void Function() stopCallback,
  ) : super(soundManager, ledRing, stopCallback);

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
    await soundManager.playSound('sounds/games/olaf-bierpong.mp3');
    gameLogger.info('Beerpong is being played!');
    await soundManager.waitForSoundToFinish();
    super.stop();
    gameLogger.info('Beerpong stopped!');
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('Beerpong stopped!');
  }
}