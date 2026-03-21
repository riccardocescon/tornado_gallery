import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/presentation/bloc/homepage_bloc/homepage_bloc.dart';
import 'package:tornado_img_app/features/presentation/widgets/bottom_app_nav_bar.dart';
import 'package:tornado_img_app/features/presentation/widgets/contained_icon.dart';

part 'widgets/action_card.dart';
part 'widgets/archive_state.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    context.read<HomepageBloc>().add(const HomepageEvent.setup());
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<HomepageBloc>().add(const HomepageEvent.refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _title(),
              const SizedBox(height: 24),
              _actions(),
              const SizedBox(height: 24),
              const _ArchiveState(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppNavBar(),
    );
  }

  Widget _title() {
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 12,
          children: [
            ContainedIcon(icon: Icons.lock_rounded),
            Text(
              "Tornado Gallery",
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          "Visually encrypted your images for full privacy",
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _actions() {
    return Row(
      spacing: 16,
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.image_rounded,
            title: "Select Photo",
            subtitle: "Select from your gallery",
            buttonText: "Open gallery",
            buttonIcon: Icons.open_in_new_rounded,
            darker: true,
          ),
        ),
        Expanded(
          child: _ActionCard(
            icon: Icons.lock_rounded,
            title: "My encrypted photos",
            subtitle: "View and decrypt",
            buttonText: "Open archive",
            buttonIcon: Icons.lock_rounded,
            darker: false,
          ),
        ),
      ],
    );
  }
}
