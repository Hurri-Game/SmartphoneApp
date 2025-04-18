import 'package:flutter/material.dart';
import 'package:hurrigame/game_engine.dart';
import 'package:hurrigame/settings_manager.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen(this.switchScreen, {super.key});

  final void Function(String screenName) switchScreen;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsManager _settingsManager = SettingsManager();
  List<String> _bullshitSoundFiles = [];

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    await _settingsManager.initialize();
    _loadBullshitSoundFiles();
  }

  Future<void> _loadBullshitSoundFiles() async {
    final String assetManifest = await rootBundle.loadString(
      'AssetManifest.json',
    );
    final Map<String, dynamic> manifest = json.decode(assetManifest);

    setState(() {
      _bullshitSoundFiles =
          manifest.keys
              .where((String key) => key.startsWith('assets/sounds/bullshit/'))
              .map((String path) => path.replaceFirst('assets/', ''))
              .toList();
    });
  }

  @override
  Widget build(context) {
    // Get screen size and calculate icon size
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.10;
    final padding = screenSize.width * 0.05;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 97, 97, 99),
            Color.fromARGB(255, 40, 35, 50),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Settings', style: TextStyle(color: Colors.black)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => widget.switchScreen('button-screen'),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Games',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ...Games.values.map(
                  (game) => SwitchListTile(
                    title: Text(
                      GameEngine.getGameDisplayName(game),
                      style: const TextStyle(color: Colors.black),
                    ),
                    value: _settingsManager.isGameEnabled(game),
                    activeColor: Colors.black,
                    inactiveThumbColor: Colors.black,
                    inactiveTrackColor: Colors.grey,
                    onChanged: (bool value) {
                      setState(() {
                        _settingsManager.toggleGame(game);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Challenges',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ...Challenges.values.map(
                  (challenge) => SwitchListTile(
                    title: Text(
                      GameEngine.getChallengeDisplayName(challenge),
                      style: const TextStyle(color: Colors.black),
                    ),
                    value: _settingsManager.isChallengeEnabled(challenge),
                    activeColor: Colors.black,
                    inactiveThumbColor: Colors.black,
                    inactiveTrackColor: Colors.grey,
                    onChanged: (bool value) {
                      setState(() {
                        _settingsManager.toggleChallenge(challenge);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Bullshit Sounds',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ..._bullshitSoundFiles.map(
                  (soundFile) => SwitchListTile(
                    title: Text(
                      soundFile.split('/').last.replaceAll('.mp3', ''),
                      style: const TextStyle(color: Colors.black),
                    ),
                    value: _settingsManager.isBullshitSoundEnabled(soundFile),
                    activeColor: Colors.black,
                    inactiveThumbColor: Colors.black,
                    inactiveTrackColor: Colors.grey,
                    onChanged: (bool value) {
                      setState(() {
                        _settingsManager.toggleBullshitSound(soundFile);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
