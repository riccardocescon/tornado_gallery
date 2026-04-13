import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/homepage_bloc/homepage_bloc.dart';
import 'package:tornado_img_app/features/presentation/pages/homepage/archive/archive_page.dart';
import 'package:tornado_img_app/features/presentation/pages/homepage/home/home_page.dart';
import 'package:tornado_img_app/features/presentation/pages/homepage/settings/settings_page.dart';
import 'package:tornado_img_app/features/presentation/widgets/bottom_app_nav_bar.dart';

class ShellHomepage extends StatefulWidget {
  const ShellHomepage({super.key});

  @override
  State<ShellHomepage> createState() => _ShellHomepageState();
}

class _ShellHomepageState extends State<ShellHomepage> {
  final pages = const [HomePage(), ArchivePage(), SettingsPage()];
  late final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomepageBloc, HomepageState>(
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
    );
  }
}
