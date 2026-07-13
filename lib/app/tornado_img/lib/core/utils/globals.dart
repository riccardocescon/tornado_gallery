import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

// Re-export so callers that already depend on [appLogger] can name [LogLayer]
// (and the log types) without importing the logger package directly.
export 'package:logger/logger.dart';

late PackageInfo packageInfo;
AppLogger appLogger = AppLogger();
late Upgrader upgrader;
late SharedPreferences prefs;

Future<void> initializeGlobals() async {
  packageInfo = await PackageInfo.fromPlatform();
  appLogger = AppLogger();
  upgrader = Upgrader();
  prefs = await SharedPreferences.getInstance();
}
