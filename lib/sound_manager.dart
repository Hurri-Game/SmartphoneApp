import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundManager {
  SoundManager();

  final AudioPlayer _audioPlayer = AudioPlayer();
  static const _audioControlChannel = MethodChannel(
    'com.example.audio_control',
  );

  void initState() {
    _audioPlayer.onPlayerComplete.listen((event) {
      debugPrint("Audio playback complete. Now deactivating audio session.");
      _deactivateAudioSession();
    });
    _configureAudioSession();
  }

  // Calls Swift code to setActive(false).
  Future<void> _deactivateAudioSession() async {
    try {
      await _audioControlChannel.invokeMethod('deactivateAudioSession');
    } catch (e) {
      debugPrint('Error calling deactivateAudioSession: $e');
    }
  }

  Future<void> _configureAudioSession() async {
    await _audioPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.duckOthers,
          },
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
      ),
    );
  }

  Future<void> playSound(String filename) async {
    // beep.mp3 must be declared in pubspec.yaml under assets:
    // assets/sounds/beep.mp3
    try {
      await fadeOutBackgroundMusic();
      await _audioPlayer.play(AssetSource(filename));
      await fadeInBackgroundMusic();
    } catch (e) {
      print(e);
    }
  }

  Future<void> fadeOutBackgroundMusic() async {
    const int steps = 10;
    const Duration stepDuration = Duration(milliseconds: 100);
    for (int i = 0; i < steps; i++) {
      await _audioPlayer.setVolume(1.0 - (i + 1) / steps);
      await Future.delayed(stepDuration);
    }
  }

  Future<void> fadeInBackgroundMusic() async {
    const int steps = 10;
    const Duration stepDuration = Duration(milliseconds: 100);
    for (int i = 0; i < steps; i++) {
      await _audioPlayer.setVolume((i + 1) / steps);
      await Future.delayed(stepDuration);
    }
  }
}
