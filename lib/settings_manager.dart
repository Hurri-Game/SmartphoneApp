import 'package:hurrigame/game_engine.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hurrigame/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  final Set<Games> _enabledGames = Set.from(Games.values);
  final Set<Challenges> _enabledChallenges = Set.from(Challenges.values);
  static Set<String> _enabledBullshitSounds = {};

  Future<void> initialize() async {
    gameLogger.info('init settings manager');
    // Load all bullshit sounds
    final String assetManifest = await rootBundle.loadString(
      'AssetManifest.json',
    );
    final Map<String, dynamic> manifest = json.decode(assetManifest);

    // Only add new sounds if they're not already in the set
    final allBullshitSounds =
        manifest.keys
            .where((String key) => key.startsWith('assets/sounds/bullshit/'))
            .map((String path) => path.replaceFirst('assets/', ''))
            .toSet();

    // If _enabledBullshitSounds is empty, initialize with all sounds
    if (_enabledBullshitSounds.isEmpty) {
      gameLogger.info('enable all bullshit sounds');
      _enabledBullshitSounds = allBullshitSounds;
    } else {
      // Otherwise, only add new sounds that aren't already in the set
      gameLogger.info('enable enabled bullshit sounds');
      //_enabledBullshitSounds.addAll(
      //  allBullshitSounds.difference(_enabledBullshitSounds),
      //);
    }
  }

  bool isGameEnabled(Games game) => _enabledGames.contains(game);
  bool isChallengeEnabled(Challenges challenge) =>
      _enabledChallenges.contains(challenge);
  bool isBullshitSoundEnabled(String soundFile) =>
      _enabledBullshitSounds.contains(soundFile);

  void toggleGame(Games game) {
    if (_enabledGames.contains(game)) {
      _enabledGames.remove(game);
    } else {
      _enabledGames.add(game);
    }
  }

  void toggleChallenge(Challenges challenge) {
    if (_enabledChallenges.contains(challenge)) {
      _enabledChallenges.remove(challenge);
    } else {
      _enabledChallenges.add(challenge);
    }
  }

  void toggleBullshitSound(String soundFile) {
    if (_enabledBullshitSounds.contains(soundFile)) {
      _enabledBullshitSounds.remove(soundFile);
    } else {
      _enabledBullshitSounds.add(soundFile);
    }
  }

  Future<void> savePrefs(
    Set<Games> games,
    Set<Challenges> challenges,
    Set<String> sounds,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      'enabledGames',
      games.map((g) => g.name).toList(),
    );

    await prefs.setStringList(
      'enabledChallenges',
      challenges.map((c) => c.name).toList(),
    );

    await prefs.setStringList('enabledBullshitSounds', sounds.toList());
  }

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final gameNames = prefs.getStringList('enabledGames') ?? [];
    final challengeNames = prefs.getStringList('enabledChallenges') ?? [];
    final soundList = prefs.getStringList('enabledBullshitSounds') ?? [];

    _enabledGames =
        gameNames
            .map((name) => Games.values.firstWhere((g) => g.name == name))
            .toSet();

    _enabledChallenges =
        challengeNames
            .map((name) => Challenges.values.firstWhere((c) => c.name == name))
            .toSet();

    _enabledBullshitSounds = soundList.toSet();
  }

  List<Games> getEnabledGames() => _enabledGames.toList();
  List<Challenges> getEnabledChallenges() => _enabledChallenges.toList();
  List<String> getEnabledBullshitSounds() => _enabledBullshitSounds.toList();
}
