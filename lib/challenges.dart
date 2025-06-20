import 'package:hurrigame/games.dart';
import 'package:hurrigame/utils/logger.dart';
import 'package:hurrigame/sound_manager.dart';
import 'package:hurrigame/led_ring.dart';
import 'package:flutter/material.dart';

class Challenge extends Game {
  Challenge(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

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

class ArmPress extends Challenge {
  ArmPress(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  @override
  void greenButtonPressed() {
    gameLogger.info('ArmPress Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('ArmPress Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('ArmPress Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    await soundManager.playSound('sounds/challenges/ArmPress.mp3');
    gameLogger.info('ArmPress is being played!');
    await soundManager.waitForSoundToFinish();
    stop();
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('ArmPress stopped!');
  }
}

class ThumbCatching extends Challenge {
  ThumbCatching(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  @override
  void greenButtonPressed() {
    gameLogger.info('ThumbCatching Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('ThumbCatching Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('ThumbCatching Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    await soundManager.playSound('sounds/challenges/ThumbCatching.mp3');
    gameLogger.info('ThumbCatching is being played!');
    await soundManager.waitForSoundToFinish();
    stop();
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('ThumbCatching stopped!');
  }
}

class CanThrowing extends Challenge {
  CanThrowing(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  @override
  void greenButtonPressed() {
    gameLogger.info('CanThrowing Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('CanThrowing Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('CanThrowing Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    await soundManager.playSound('sounds/challenges/CanThrowing.mp3');
    gameLogger.info('CanThrowing is being played!');
    await soundManager.waitForSoundToFinish();
    stop();
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('CanThrowing stopped!');
  }
}

class HighJump extends Challenge {
  HighJump(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  @override
  void greenButtonPressed() {
    gameLogger.info('HighJump Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('HighJump Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('HighJump Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    await soundManager.playSound('sounds/challenges/HighJump.mp3');
    gameLogger.info('HighJump is being played!');
    await soundManager.waitForSoundToFinish();
    stop();
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('HighJump stopped!');
  }
}

class Bowling extends Challenge {
  Bowling(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  @override
  void greenButtonPressed() {
    gameLogger.info('Bowling Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('Bowling Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('Bowling Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    await soundManager.playSound('sounds/challenges/Bowling.mp3');
    gameLogger.info('CanThrowing is being played!');
    await soundManager.waitForSoundToFinish();
    stop();
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('Bowling stopped!');
  }
}

class PushUps extends Challenge {
  PushUps(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  @override
  void greenButtonPressed() {
    gameLogger.info('PushUps Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('PushUps Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('PushUps Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    await soundManager.playSound('sounds/challenges/PushUps.mp3');
    gameLogger.info('PushUps is being played!');
    await soundManager.waitForSoundToFinish();
    stop();
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('CanThrowing stopped!');
  }
}

class HoldYourBreath extends Challenge {
  HoldYourBreath(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  @override
  void greenButtonPressed() {
    gameLogger.info('HoldYourBreath Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('HoldYourBreath Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('HoldYourBreath Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    await soundManager.playSound('sounds/challenges/HoldYourBreath.mp3');
    gameLogger.info('HoldYourBreath is being played!');
    await soundManager.waitForSoundToFinish();
    stop();
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('HoldYourBreath stopped!');
  }
}

class MeasurePromille extends Challenge {
  MeasurePromille(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  @override
  void greenButtonPressed() {
    gameLogger.info('MeasurePromille Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('MeasurePromille Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('MeasurePromille Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    await soundManager.playSound('sounds/challenges/MeasurePromille.mp3');
    gameLogger.info('MeasurePromille is being played!');
    await soundManager.waitForSoundToFinish();
    stop();
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('MeasurePromille stopped!');
  }
}

class Quiz extends Challenge {
  Quiz(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  @override
  void greenButtonPressed() {
    gameLogger.info('Quiz Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('Quiz Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('Quiz Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    await soundManager.playSound('sounds/challenges/Quiz.mp3');
    gameLogger.info('Quiz is being played!');
    await soundManager.waitForSoundToFinish();
    stop();
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('Quiz stopped!');
  }
}

class RockPaperScissors extends Challenge {
  RockPaperScissors(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  @override
  void greenButtonPressed() {
    gameLogger.info('RockPaperScissors Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('RockPaperScissors Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('CanThrowing Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    await soundManager.playSound('sounds/challenges/RockPaperScissors.mp3');
    gameLogger.info('RockPaperScissors is being played!');
    await soundManager.waitForSoundToFinish();
    stop();
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('RockPaperScissors stopped!');
  }
}

class StaringContest extends Challenge {
  StaringContest(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  @override
  void greenButtonPressed() {
    gameLogger.info('StaringContest Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('StaringContest Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('StaringContest Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    await soundManager.playSound('sounds/challenges/StaringContest.mp3');
    gameLogger.info('StaringContest is being played!');
    await soundManager.waitForSoundToFinish();
    stop();
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('StaringContest stopped!');
  }
}

class Race extends Challenge {
  Race(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  @override
  void greenButtonPressed() {
    gameLogger.info('Race Green Button Pressed!');
  }

  @override
  void redButtonPressed() {
    gameLogger.info('Race Red Button Pressed!');
    stop();
  }

  @override
  void orangeButtonPressed() {
    gameLogger.info('Race Orange Button Pressed!');
  }

  @override
  void play() async {
    super.play();
    await soundManager.playSound('sounds/challenges/Race.mp3');
    gameLogger.info('Race is being played!');
    await soundManager.waitForSoundToFinish();
    stop();
  }

  @override
  void stop() {
    super.stop();
    gameLogger.info('Race stopped!');
  }
}

class Dreisprung extends Challenge {
  Dreisprung(LedRing? ledRing, void Function() stopCallback)
    : super(ledRing, stopCallback);

  @override
  void play() async {
    // TODO: implement play
    super.play();
    await soundManager.playSound('sounds/challenges/Dreisprung.mp3');
    gameLogger.info('Race is being played!');
    await soundManager.waitForSoundToFinish();
    stop();
  }
}
