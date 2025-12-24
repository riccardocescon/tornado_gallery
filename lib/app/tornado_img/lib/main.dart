import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tornado_img_app/injection_container.dart';
import 'package:tornado_img_app/routes.dart';

late PackageInfo packageInfo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  packageInfo = await PackageInfo.fromPlatform();
  setupInjectionContainer();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tornado Image',
      theme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: routes,
    );
  }
}
