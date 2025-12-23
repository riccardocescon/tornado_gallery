import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tornado_img_app/routes.dart';
import 'package:tornado_img_app/features/viewmodels/homepage_viewmodel.dart';

late PackageInfo packageInfo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  packageInfo = await PackageInfo.fromPlatform();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomepageViewmodel()..init(),
      child: MaterialApp.router(
        title: 'Tornado Image',
        theme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        routerConfig: routes,
      ),
    );
  }
}
