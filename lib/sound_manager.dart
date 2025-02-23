import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundManager {
  SoundManager();

  final AudioPlayer _audioPlayer = AudioPlayer();
  static const _audioControlChannel = MethodChannel('com.example.audio_control');

  void initState() {
    _audioPlayer.onPlayerComplete.listen((event) {
      debugPrint("Audio playback complete. Now deactivating audio session.");
      _deactivateAudioSession();
    });
    _configureIosAudioSession();
  }


  // Calls Swift code to setActive(false).
  Future<void> _deactivateAudioSession() async {
    try {
      await _audioControlChannel.invokeMethod('deactivateAudioSession');
    } catch (e) {
      debugPrint('Error calling deactivateAudioSession: $e');
    }
  }  

  Future<void> _configureIosAudioSession() async {
    await _audioPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.duckOthers,
          },
        ),
      ),
    );
  }

  Future<void> playSound(String filename) async {
    // beep.mp3 must be declared in pubspec.yaml under assets:
    // assets/sounds/beep.mp3
    try {
        await _audioPlayer.play(AssetSource(filename));
      } catch (e) {
        print(e);
      }
  }

}
