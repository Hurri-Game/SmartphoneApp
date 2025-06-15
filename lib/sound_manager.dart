import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:hurrigame/utils/logger.dart';

class SoundManager {
  SoundManager({this.deactivateAfterPlayback = true});

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool deactivateAfterPlayback;
  static const _audioControlChannel = MethodChannel(
    'com.example.audio_control',
  );

  void initState(String sessionType) {
    _audioPlayer.onPlayerComplete.listen((event) {
      if (deactivateAfterPlayback) {
        gameLogger.info(
          "Audio playback complete. Now deactivating audio session.",
        );
        _deactivateAudioSession();
      } else {
        gameLogger.info(
          "Deactivate after playback is false, not deactivating session.",
        );
        return;
      }
    });
    _configureAudioSession(sessionType);
  }

  // Calls Swift code to setActive(false).
  Future<void> _deactivateAudioSession() async {
    try {
      await _audioControlChannel.invokeMethod('deactivateAudioSession');
    } catch (e) {
      gameLogger.info('Error calling deactivateAudioSession: $e');
    }
  }

  Future<void> _configureAudioSession(String sessionType) async {
    if (sessionType == "silent") {
      print("Config silent");
      await _audioPlayer.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {},
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
        ),
      );
    } else if (sessionType == "duck") {
      print("Config duck");
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
  }

  Future<void> playSound(
    String filename, {
    String sessionType = "silent",
  }) async {
    // beep.mp3 must be declared in pubspec.yaml under assets:
    // assets/sounds/beep.mp3
    try {
      await _configureAudioSession(sessionType);
      await _audioPlayer.play(AssetSource(filename));
    } catch (e) {
      gameLogger.info(e);
    }
  }

  Future<void> stopSound() async {
    try {
      await _audioPlayer.release();
      await _deactivateAudioSession();
    } catch (e) {
      gameLogger.warning(e);
    }
  }

  bool isPlaying() {
    return _audioPlayer.state == PlayerState.playing;
  }

  Future<void> waitForSoundToFinish() async {
    try {
      await _audioPlayer.onPlayerStateChanged.first;
    } catch (e) {
      gameLogger.warning("Error waiting for sound to finish", e);
    }
  }

  Future<void> loopSound(String filename) async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await playSound(filename);
  }

  Future<void> stopLoop() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.release);
    await stopSound();
  }
}
