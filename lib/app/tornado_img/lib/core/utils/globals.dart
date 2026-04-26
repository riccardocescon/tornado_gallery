import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';

late PackageInfo packageInfo;
AppLogger appLogger = AppLogger();
late Upgrader upgrader;

Future<void> initializeGlobals() async {
  packageInfo = await PackageInfo.fromPlatform();
  appLogger = AppLogger();
  upgrader = Upgrader(
    // debugDisplayAlways: true,
    // debugLogging: true,
  );
  await upgrader.initialize();
}
