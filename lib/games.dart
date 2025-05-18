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
  void blueButtonPressed();
  
  void play() {
    ledRing?.pulse(Colors.orange);
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
  void blueButtonPressed() {
    gameLogger.info('Flunkyball Blue Button Pressed!');
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
  void blueButtonPressed() {
    gameLogger.info('RageCage Blue Button Pressed!');
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
  void blueButtonPressed() {
    gameLogger.info('Roulette Blue Button Pressed!');
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
  Completer<void>? _blueButtonCompleter;

  @override
  Future<void> greenButtonPressed() async {
    gameLogger.info('FarbenRaten Green Button Pressed!');
    ColorEntry color = getRandomColor();
    ledRing?.setColor(color.color);
    gameLogger.info('Random Color: $color');

    // Wait for the blue button to be pressed
    _blueButtonCompleter = Completer<void>();
    await _blueButtonCompleter?.future;
    _blueButtonCompleter = null;
    // wait for 5 seconds
    ledRing?.pulse(color.color);
    await Future.delayed(const Duration(seconds: 3));
    await soundManager.playSound('sounds/color_sounds/${color.name}.mp3');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('FarbenRaten Red Button Pressed!');
    stop();
  }

  @override
  void blueButtonPressed() {
    gameLogger.info('FarbenRaten Blue Button Pressed!');
    _blueButtonCompleter?.complete();
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