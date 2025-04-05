import 'package:hurrigame/sound_manager.dart';
import 'package:hurrigame/led_ring.dart';

abstract class Game {
  Game(this.soundManager, this.ledRing, this.stopCallback);

  final SoundManager soundManager;
  final LedRing? ledRing;
  final void Function() stopCallback;

  void greenButtonPressed();
  void redButtonPressed();
  void blueButtonPressed();
  void play();
  void stop();
}

class Flunkyball extends Game {
  Flunkyball(
    SoundManager soundManager,
    LedRing? ledRing,
    void Function() stopCallback,
  ) : super(soundManager, ledRing, stopCallback);

  @override
  void greenButtonPressed() {
    print('Flunkyball Green Button Pressed!');
    stop();
  }

  @override
  void redButtonPressed() {
    print('Flunkyball Red Button Pressed!');
  }

  @override
  void blueButtonPressed() {
    print('Flunkyball Blue Button Pressed!');
  }

  @override
  void play() async {
    await soundManager.playSound('sounds/games/flunky-song.mp3');
    print('Flunkyball is being played!');
    while (soundManager.isPlaying()) {
      // Wait until the sound is finished playing
      await Future.delayed(const Duration(milliseconds: 100));
    }
    stopCallback();
    print('Flunkyball stopped!');
  }

  @override
  void stop() {
    soundManager.stopSound();
    stopCallback();
    print('Flunkyball stopped!');
  }
}
