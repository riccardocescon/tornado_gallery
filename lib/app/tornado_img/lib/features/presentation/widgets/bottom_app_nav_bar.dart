import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/presentation/bloc/homepage_bloc/homepage_bloc.dart';

class BottomAppNavBar extends StatefulWidget {
  const BottomAppNavBar({super.key});

  @override
  State<BottomAppNavBar> createState() => _BottomAppNavBarState();
}

class _BottomAppNavBarState extends State<BottomAppNavBar> {
  Pages _currentPage = Pages.home;

  Alignment _pillAlignment(int index) {
    final count = Pages.values.length;
    if (count == 1) return Alignment.center;
    return Alignment(-1.0 + (2.0 * index) / (count - 1), 0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomepageBloc, HomepageState>(
      listener: (context, state) {
        state.maybeMap(
          homepageSet: (value) {
            setState(() => _currentPage = value.page);
          },
          orElse: () {},
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          top: 12,
          bottom: 12 + MediaQuery.of(context).padding.bottom,
          left: 24,
          right: 24,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: AppStyle.cardBorderRadius,
        ),
        child: SizedBox(
          height: 32,
          child: Stack(
            children: [
              _slidingPill(),

              Row(children: Pages.values.map(_tab).toList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slidingPill() {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubicEmphasized,
      alignment: _pillAlignment(_currentPage.index),
      child: FractionallySizedBox(
        widthFactor: 1 / Pages.values.length,
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            color: context.colorScheme.primaryContainer,
            borderRadius: AppStyle.cardBorderRadius,
          ),
        ),
      ),
    );
  }

  Widget _tab(Pages page) {
    final isSelected = page == _currentPage;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          context.read<HomepageBloc>().add(HomepageEvent.setScreen(page: page));
        },
        child: SizedBox(
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 12,
            children: [
              Icon(
                page.icon,
                size: 22,
                color:
                    isSelected
                        ? context.colorScheme.onPrimary
                        : context.colorScheme.onSurface,
              ),
              Text(
                page.label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color:
                      isSelected
                          ? context.colorScheme.onPrimary
                          : context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
