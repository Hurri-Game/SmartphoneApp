import 'package:hurrigame/sound_manager.dart';
import 'package:hurrigame/led_ring.dart';
import 'package:hurrigame/utils/logger.dart';

abstract class Game {
  Game(this.soundManager, this.ledRing, this.stopCallback);

  final SoundManager soundManager;
  final LedRing? ledRing;
  final void Function() stopCallback;
  bool _isStopped = false;

  void greenButtonPressed();
  void redButtonPressed();
  void blueButtonPressed();
  void play();

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
    stop();
  }

  @override
  void redButtonPressed() {
    gameLogger.info('Flunkyball Red Button Pressed!');
  }

  @override
  void blueButtonPressed() {
    gameLogger.info('Flunkyball Blue Button Pressed!');
  }

  @override
  void play() async {
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
    stop();
  }

  @override
  void redButtonPressed() {
    gameLogger.info('RageCage Red Button Pressed!');
  }

  @override
  void blueButtonPressed() {
    gameLogger.info('RageCage Blue Button Pressed!');
  }

  @override
  void play() async {
    gameLogger.info('RageCage is being played!');
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
