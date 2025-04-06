// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  String assetPath = 'assets/sounds/bullshit/';
  Directory dir = Directory(assetPath);

  if (!dir.existsSync()) {
    print("Der Ordner $assetPath existiert nicht.");
    return;
  }

  List<String> files =
      dir
          .listSync()
          .whereType<File>()
          .map(
            (file) => file.path.replaceAll('\\', '/'),
          ) // Pfad anpassen für pubspec
          .toList();

  print("Kopiere die folgenden Zeilen in die pubspec.yaml:");
  for (var file in files) {
    print("    - $file");
  }
}
