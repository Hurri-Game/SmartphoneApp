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
    final prefs = await SharedPreferences.getInstance();

    // Load games
    final savedGames = prefs.getStringList('enabledGames');
    if (savedGames != null) {
      _enabledGames
        ..clear()
        ..addAll(
          savedGames.map((g) => Games.values.firstWhere((e) => e.name == g)),
        );
    }

    // Load challenges
    final savedChallenges = prefs.getStringList('enabledChallenges');
    if (savedChallenges != null) {
      _enabledChallenges
        ..clear()
        ..addAll(
          savedChallenges.map(
            (c) => Challenges.values.firstWhere((e) => e.name == c),
          ),
        );
    }

    // Load bullshit sounds from manifest
    final String assetManifest = await rootBundle.loadString(
      'AssetManifest.json',
    );
    final Map<String, dynamic> manifest = json.decode(assetManifest);
    final allBullshitSounds =
        manifest.keys
            .where((String key) => key.startsWith('assets/sounds/bullshit/'))
            .map((String path) => path.replaceFirst('assets/', ''))
            .toSet();

    final savedSounds = prefs.getStringList('enabledBullshitSounds');

    if (savedSounds != null) {
      _enabledBullshitSounds = savedSounds.toSet();
    } else {
      gameLogger.warning('enable all bullshit sounds');
      _enabledBullshitSounds = allBullshitSounds;
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
    savePrefs(_enabledGames, _enabledChallenges, _enabledBullshitSounds);
  }

  void toggleChallenge(Challenges challenge) {
    if (_enabledChallenges.contains(challenge)) {
      _enabledChallenges.remove(challenge);
    } else {
      _enabledChallenges.add(challenge);
    }
    savePrefs(_enabledGames, _enabledChallenges, _enabledBullshitSounds);
  }

  void toggleBullshitSound(String soundFile) {
    if (_enabledBullshitSounds.contains(soundFile)) {
      _enabledBullshitSounds.remove(soundFile);
    } else {
      _enabledBullshitSounds.add(soundFile);
    }
    savePrefs(_enabledGames, _enabledChallenges, _enabledBullshitSounds);
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

  List<Games> getEnabledGames() => _enabledGames.toList();
  List<Challenges> getEnabledChallenges() => _enabledChallenges.toList();
  List<String> getEnabledBullshitSounds() => _enabledBullshitSounds.toList();
}
