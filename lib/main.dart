import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hurrigame/beat_breaker.dart';
import 'package:hurrigame/utils/logger.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    WakelockPlus.enable();
    setupLogging();
    runApp(const BeatBreaker());
  });
}
