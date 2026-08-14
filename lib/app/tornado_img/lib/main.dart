import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/purchase_bloc/purchase_bloc.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/injection_container.dart';
import 'package:tornado_img_app/routes.dart';
import 'package:tornado_img_app/theme/theme.dart';
import 'package:tornado_img_app/theme/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeGlobals();
  setupInjectionContainer();
  await getIt<ThemeNotifier>().load();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AppBloc>()),
        BlocProvider(
          lazy: false,
          create:
              (context) =>
                  getIt<PurchaseBloc>()..add(const PurchaseEvent.setup()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Re-confirm the entitlement whenever the app comes back to the foreground.
    // The store only reports *active* purchases, so this is what keeps the Pro
    // grace clock alive — and what lets a cancelled subscription expire.
    _lifecycle = AppLifecycleListener(
      onResume:
          () => getIt<PurchaseBloc>().add(
            const PurchaseEvent.restore(silent: true),
          ),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

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
