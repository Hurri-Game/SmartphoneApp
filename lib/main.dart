import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hurrigame/beat_breaker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const BeatBreaker());
  });
}
