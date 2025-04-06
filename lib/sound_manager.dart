import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:hurrigame/utils/logger.dart';

class SoundManager {
  SoundManager();

  final AudioPlayer _audioPlayer = AudioPlayer();
  static const _audioControlChannel = MethodChannel(
    'com.example.audio_control',
  );

  void initState() {
    _audioPlayer.onPlayerComplete.listen((event) {
      gameLogger.info(
        "Audio playback complete. Now deactivating audio session.",
      );
      _deactivateAudioSession();
    });
    _configureAudioSession();
  }

  // Calls Swift code to setActive(false).
  Future<void> _deactivateAudioSession() async {
    try {
      await _audioControlChannel.invokeMethod('deactivateAudioSession');
    } catch (e) {
      gameLogger.info('Error calling deactivateAudioSession: $e');
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
      await _audioPlayer.play(AssetSource(filename));
    } catch (e) {
      gameLogger.info(e);
    }
  }

  Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      gameLogger.warning(e);
    }
  }

  bool isPlaying() {
    return _audioPlayer.state == PlayerState.playing;
  }

  Future<void> waitForSoundToFinish() async {
    while (isPlaying()) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> loopSound(String filename) async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource(filename));
    } catch (e) {
      gameLogger.warning(e);
    }
  }

  Future<void> stopLoop() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.stop();
    } catch (e) {
      gameLogger.warning(e);
    }
  }
}
