import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tornado_img_app/injection_container.dart';
import 'package:tornado_img_app/routes.dart';
import 'package:tornado_img_app/theme/theme.dart';
import 'package:tornado_img_app/theme/theme_notifier.dart';

late PackageInfo packageInfo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  packageInfo = await PackageInfo.fromPlatform();
  setupInjectionContainer();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: getIt<ThemeNotifier>(),
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Tornado Image',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: getIt<ThemeNotifier>().mode,
          routerConfig: routes,
        );
      },
    );
  }
}
