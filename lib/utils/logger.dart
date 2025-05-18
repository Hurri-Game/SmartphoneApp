import 'package:logging/logging.dart';

// Create loggers for different parts of the app
final bluetoothLogger = Logger('Bluetooth');
final gameLogger = Logger('Game');
final uiLogger = Logger('UI');

void setupLogging() {
  Logger.root.level = Level.ALL; // Set the default logging level
  hierarchicalLoggingEnabled = true;
  bluetoothLogger.level = Level.WARNING;
  Logger.root.onRecord.listen((record) {
    // Format: [LEVEL] LOGGER_NAME: MESSAGE
    print('${record.level.name} ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      print('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('Stack trace:\n${record.stackTrace}');
    }
  });
}
