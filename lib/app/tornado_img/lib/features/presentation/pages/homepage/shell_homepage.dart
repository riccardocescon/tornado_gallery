import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/archive_page_bloc/archive_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/homepage_bloc/homepage_bloc.dart';
import 'package:tornado_img_app/features/presentation/pages/homepage/archive/archive_page.dart';
import 'package:tornado_img_app/features/presentation/pages/homepage/home/home_page.dart';
import 'package:tornado_img_app/features/presentation/pages/homepage/settings/settings_page.dart';
import 'package:tornado_img_app/features/presentation/widgets/bottom_app_nav_bar.dart';
import 'package:tornado_img_app/features/presentation/widgets/unlock_all_bottom_sheet.dart';

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
        floatingActionButton: _fab(),
        bottomNavigationBar: BottomAppNavBar(),
      ),
    );
  }

  Widget _fab() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: BlocBuilder<HomepageBloc, HomepageState>(
        builder: (context, state) {
          return state.maybeMap(
            orElse: () => const SizedBox.shrink(),
            homepageSet: (value) {
              if (value.page == Pages.archive) {
                return BlocBuilder<ArchivePageBloc, ArchivePageState>(
                  buildWhen:
                      (previous, current) => current.maybeMap(
                        decryptingAllUI: (value) => true,
                        ui: (value) => true,
                        orElse: () => false,
                      ),
                  builder: (context, state) {
                    final isDecrypting =
                        context.read<ArchivePageBloc>().isDecryptingAllImages;
                    final hasDecryptedAll =
                        context.read<ArchivePageBloc>().hasAllDecrypted;

                    final isLoading = state.maybeMap(
                      decryptingAllUI:
                          (value) =>
                              value.dearchivingState.totalImages !=
                              value.dearchivingState.progress,
                      orElse: () => isDecrypting && !hasDecryptedAll,
                    );

                    if (isLoading) return const SizedBox.shrink();

                    return FloatingActionButton(
                      onPressed: () {
                        if (isDecrypting) {
                          context.read<ArchivePageBloc>().add(
                            const ArchivePageEvent.encryptAll(),
                          );
                          return;
                        }
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder:
                              (_) => UnlockAllBottomSheet(
                                onUnlockAll: (passphrase) {
                                  context.read<ArchivePageBloc>().add(
                                    ArchivePageEvent.decryptAll(
                                      passphrase: passphrase,
                                    ),
                                  );
                                },
                              ),
                        );
                      },
                      child: Icon(
                        context.read<ArchivePageBloc>().hasAllDecrypted
                            ? Icons.lock_rounded
                            : Icons.lock_open_rounded,
                      ),
                    );
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }
}
