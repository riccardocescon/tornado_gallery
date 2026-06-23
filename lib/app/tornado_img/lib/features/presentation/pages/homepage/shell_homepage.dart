import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/features/presentation/bloc/homepage_bloc/homepage_bloc.dart';
import 'package:tornado_img_app/features/presentation/pages/homepage/home/home_page.dart';
import 'package:tornado_img_app/features/presentation/pages/homepage/settings/settings_page.dart';
import 'package:tornado_img_app/features/presentation/widgets/bottom_app_nav_bar.dart';

class ShellHomepage extends StatefulWidget {
  const ShellHomepage({super.key});

  @override
  State<ShellHomepage> createState() => _ShellHomepageState();
}

class _ShellHomepageState extends State<ShellHomepage> {
  final pages = const [HomePage(), SettingsPage()];
  late final PageController _pageController = PageController();
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    upgrader.initialize();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPop() {
    final bloc = context.read<HomepageBloc>();
    if (bloc.currentPage != Pages.home) {
      bloc.add(const HomepageEvent.setScreen(page: Pages.home));
      return;
    }

    final now = DateTime.now();
    if (_lastBackPress != null &&
        now.difference(_lastBackPress!) < const Duration(seconds: 1)) {
      SystemNavigator.pop();
      return;
    }

    _lastBackPress = now;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Press back again to exit the app'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onPop();
      },
      child: BlocListener<HomepageBloc, HomepageState>(
      listener: (context, state) {
        state.maybeMap(
          homepageSet: (value) {
            _pageController.animateToPage(
              value.page.index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
            );
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: pages,
          ),
        ),
        bottomNavigationBar: BottomAppNavBar(),
      ),
      ),
    );
  }
}
