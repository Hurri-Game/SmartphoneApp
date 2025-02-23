import 'package:hurrigame/sound_manager.dart';


class GameEngine{
  GameEngine(this.soundManager);

  SoundManager soundManager;

  void initState() {
    soundManager.initState();
  }

  void playRandomBullshit(){
    soundManager.playSound('sounds/bullshit/2024.mp3');
  }

  void startChallenge(){
    print('Challenge started!');
  }

  void startDrink(){
    print('Drink started!');
  }

}