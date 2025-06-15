import 'package:hurrigame/led_ring.dart';
import 'package:hurrigame/sound_manager.dart';
import 'dart:math';
import 'package:hurrigame/games.dart';
import 'package:hurrigame/challenges.dart';
import 'package:hurrigame/utils/logger.dart';
import 'package:hurrigame/settings_manager.dart';

enum EngineState { idle, gameRunning, bullshitRunning }

enum Games {
  chooseSide,
  guessTheNumber,
  flunkyball,
  rageCage,
  roulette,
  farbenraten,
  beerpong,
  shortGames,
}

enum Challenges {
  armPress,
  thumbCatching,
  canThrowing,
  highJump,
  bowling,
  //pushUps, // soundfile not working
  holdYourBreath,
  measurePromille,
  quiz,
  rockPaperScissors,
  //staringContest, // soundfile not working
  race,
  dreisprung,
}

class GameEngine {
  GameEngine(this.soundManager, this.ledRing);
  final Random random = Random();

  SoundManager soundManager;

  Games? currentGame;
  EngineState currentEngineState = EngineState.idle;
  var currentChallenge = Challenges.armPress;

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
        currentEngineState = EngineState.bullshitRunning;
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
        currentEngineState = EngineState.idle;
        break;
      case EngineState.gameRunning:
        game?.redButtonPressed();
        break;
      case EngineState.bullshitRunning:
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
      case EngineState.bullshitRunning:
        // Do nothing, we are already in bullshit mode
        break;
    }
    gameLogger.info('Green Button Pressed!');
  }

  void orangeButtonPressed() {
    switch (currentEngineState) {
      case EngineState.idle:
        playRandomChallenge();
        break;
      case EngineState.gameRunning:
        game?.orangeButtonPressed();
        break;
      case EngineState.bullshitRunning:
        // Do nothing, we are already in bullshit mode
        break;
    }
    gameLogger.info('Orange Button Pressed!');
  }

  Future<String?> getRandomSoundFile() async {
    // Get all enabled bullshit sounds
    List<String> soundFiles = SettingsManager().getEnabledBullshitSounds();

    if (soundFiles.isEmpty) {
      gameLogger.info("No bullshit sounds enabled!");
      return null;
    }

    // Select a random enabled sound file
    String randomFile = soundFiles[random.nextInt(soundFiles.length)];
    gameLogger.info(randomFile);
    return randomFile;
  }

  static bool requiresLedRing(Games game) {
    switch (game) {
      case Games.roulette:
      case Games.farbenraten:
      case Games.guessTheNumber:
      case Games.chooseSide:
        return true;
      default:
        return false;
    }
  }

  Games getRandomGame() {
    final enabledGames = SettingsManager().getEnabledGames();
    if (enabledGames.isEmpty) {
      throw Exception("No games enabled");
    }

    // Filter out games that require LED ring if it's not connected
    final availableGames =
        enabledGames.where((game) {
          if (requiresLedRing(game)) {
            return ledRing.isConnected;
          }
          return true;
        }).toList();

    if (availableGames.isEmpty) {
      throw Exception("No available games (some require LED ring connection)");
    }

    return availableGames[random.nextInt(availableGames.length)];
  }

  void playRandomGame() {
    try {
      currentGame = getRandomGame();
      gameLogger.info("Next Game: $currentGame");
      switch (currentGame) {
        case Games.flunkyball:
          game = Flunkyball(ledRing, idleGameEngine);
          break;
        case Games.rageCage:
          game = RageCage(ledRing, idleGameEngine);
          break;
        case Games.roulette:
          game = Roulette(ledRing, idleGameEngine);
          break;
        case Games.farbenraten:
          game = FarbenRaten(ledRing, idleGameEngine);
          break;
        case Games.guessTheNumber:
          game = GuessTheNumber(ledRing, idleGameEngine);
          break;
        case Games.chooseSide:
          game = ChooseSide(ledRing, idleGameEngine);
          break;
        case Games.beerpong:
          game = Beerpong(ledRing, idleGameEngine);
          break;
        case Games.shortGames:
          game = ShortDrinkingGame(ledRing, idleGameEngine);
        default:
          gameLogger.warning("Game $currentGame is not implemented yet.");
      }
      currentEngineState = EngineState.gameRunning;
      //game = ChooseSide(ledRing, idleGameEngine);  // only for testing always the same game
      game?.play();
    } catch (e) {
      gameLogger.warning("Could not start game: $e");
    }
  }

  // challenges
  Challenges getRandomChallenge() {
    final enabledChallenges = SettingsManager().getEnabledChallenges();
    if (enabledChallenges.isEmpty) {
      throw Exception("No challenges enabled");
    }
    return enabledChallenges[random.nextInt(enabledChallenges.length)];
  }

  void playRandomChallenge() {
    try {
      currentChallenge = getRandomChallenge();
      gameLogger.info("Next Challenge: $currentChallenge");
      switch (currentChallenge) {
        case Challenges.armPress:
          game = ArmPress(ledRing, idleGameEngine);
          break;
        case Challenges.thumbCatching:
          game = ThumbCatching(ledRing, idleGameEngine);
          break;
        case Challenges.canThrowing:
          game = CanThrowing(ledRing, idleGameEngine);
          break;
        case Challenges.highJump:
          game = HighJump(ledRing, idleGameEngine);
          break;
        case Challenges.bowling:
          game = Bowling(ledRing, idleGameEngine);
          break;
        /*
        case Challenges.pushUps:
          game = PushUps(ledRing, idleGameEngine);
          break;
        */
        case Challenges.holdYourBreath:
          game = HoldYourBreath(ledRing, idleGameEngine);
          break;
        case Challenges.measurePromille:
          game = MeasurePromille(ledRing, idleGameEngine);
          break;
        case Challenges.quiz:
          game = Quiz(ledRing, idleGameEngine);
          break;
        case Challenges.rockPaperScissors:
          game = RockPaperScissors(ledRing, idleGameEngine);
          break;
        /*
        case Challenges.staringContest:
          game = StaringContest(ledRing, idleGameEngine);
          break;
        */
        case Challenges.race:
          game = Race(ledRing, idleGameEngine);
          break;
        case Challenges.dreisprung:
          game = Dreisprung(ledRing, idleGameEngine);
        default:
          throw Exception("Game $currentChallenge is not implemented yet.");
      }
      currentEngineState = EngineState.gameRunning;
      // game = Race(
      //   soundManager,
      //   ledRing,
      //   idleGameEngine,
      // ); // only for testing always the same game
      game?.play();
    } catch (e) {
      gameLogger.warning("Could not start challenge: $e");
    }
  }

  void idleGameEngine() {
    currentEngineState = EngineState.idle;
  }

  static String getGameDisplayName(Games game) {
    switch (game) {
      case Games.chooseSide:
        return "Choose Side";
      case Games.guessTheNumber:
        return "Guess the Number";
      case Games.flunkyball:
        return "Flunkyball";
      case Games.rageCage:
        return "Rage Cage";
      case Games.roulette:
        return "Roulette";
      case Games.farbenraten:
        return "Farbenraten";
      case Games.beerpong:
        return "Beerpong";
      case Games.shortGames:
        return "Schneller Suff";
      default:
        return game.toString().split('.').last;
    }
  }

  static String getChallengeDisplayName(Challenges challenge) {
    switch (challenge) {
      case Challenges.armPress:
        return "Arm Press";
      case Challenges.thumbCatching:
        return "Thumb Catching";
      case Challenges.canThrowing:
        return "Can Throwing";
      case Challenges.highJump:
        return "High Jump";
      case Challenges.bowling:
        return "Bowling";
      case Challenges.holdYourBreath:
        return "Hold Your Breath";
      case Challenges.measurePromille:
        return "Measure Promille";
      case Challenges.quiz:
        return "Quiz";
      case Challenges.rockPaperScissors:
        return "Rock Paper Scissors";
      case Challenges.race:
        return "Race";
      case Challenges.dreisprung:
        return "Dreisprung";
      default:
        return challenge.toString().split('.').last;
    }
  }
}
