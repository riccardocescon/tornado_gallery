import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tornado_img/features/viewmodels/homepage_viewmodel.dart';
import 'package:tornado_img/routes.dart';

void main() {
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
