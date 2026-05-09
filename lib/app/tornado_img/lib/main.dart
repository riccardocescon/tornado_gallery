import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/injection_container.dart';
import 'package:tornado_img_app/routes.dart';
import 'package:tornado_img_app/theme/theme.dart';
import 'package:tornado_img_app/theme/theme_notifier.dart';
import 'package:device_preview_plus/device_preview_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeGlobals();
  setupInjectionContainer();
  await getIt<ThemeNotifier>().load();
  runApp(
    BlocProvider(create: (context) => getIt<AppBloc>(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DevicePreview(
      enabled: kDebugMode && false,
      builder: (context) {
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
      },
    );
  }
}
