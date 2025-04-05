import 'package:hurrigame/sound_manager.dart';
import 'package:hurrigame/led_ring.dart';

abstract class Game {
  Game(this.soundManager, this.ledRing);

  final SoundManager soundManager;
  final LedRing? ledRing;

  void greenButtonPressed();
  void redButtonPressed();
  void blueButtonPressed();
  void play();
  void stop();
}

class Flunkyball extends Game {

  Flunkyball(this.soundManager, this.ledRing) : super(soundManager, ledRing);
  
  @override
  final SoundManager soundManager;
  @override
  final LedRing? ledRing;

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
  void play() {
    soundManager.playSound('sounds/games/flunky-song.mp3');
    print('Flunkyball is being played!');

  }

  @override
  void stop() {
    soundManager.stopSound();
    print('Flunkyball stopped!');
  }
}
