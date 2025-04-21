import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';

class ColorEntry {
  final String name;
  final Color color;

  ColorEntry({required this.name, required this.color});

  @override
  String toString() => '$name: ${color.value.toRadixString(16)}';
}

Color parseRgbString(String rgb) {
  final parts = rgb.split(',').map((e) => int.parse(e.trim())).toList();
  return Color.fromARGB(255, parts[0], parts[1], parts[2]);
}

Future<List<ColorEntry>> loadColorEntries(String path) async {
  final rawData = await rootBundle.loadString(path);
  final rows = const CsvToListConverter(
    shouldParseNumbers: false,
    eol: '\n',
  ).convert(rawData);

  // Skip header
  final dataRows = rows.sublist(1);

  return dataRows.map((row) {
    final name = row[0] as String;
    final rgbString = row[1] as String;
    final color = parseRgbString(rgbString);
    return ColorEntry(name: name, color: color);
  }).toList();
}
