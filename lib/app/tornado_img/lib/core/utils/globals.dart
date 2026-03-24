import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

late PackageInfo packageInfo;
late AppLogger appLogger;

Future<void> initializeGlobals() async {
  packageInfo = await PackageInfo.fromPlatform();
  appLogger = AppLogger();
}
