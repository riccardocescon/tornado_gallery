import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/domain/entities/pro_product.dart';
import 'package:tornado_img_app/core/presentation/bloc/purchase_bloc/purchase_bloc.dart';
import 'package:tornado_img_app/core/presentation/widgets/update_app_card.dart';
import 'package:tornado_img_app/core/utils/assets.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/utils/routes.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/presentation/widgets/contained_item.dart';
import 'package:tornado_img_app/features/presentation/widgets/page_title.dart';
import 'package:tornado_img_app/features/presentation/widgets/pro_widgets.dart';
import 'package:tornado_img_app/injection_container.dart';
import 'package:tornado_img_app/theme/theme_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

part 'widgets/info_cards.dart';
part 'widgets/subscription_section.dart';
part 'widgets/app_settings_card.dart';
part 'widgets/about_card.dart';
part 'widgets/device_info_card.dart';
part 'widgets/author_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SingleChildScrollView(
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Column(
              spacing: 8,
              children: [
                PageTitle(
                  title: "Settings",
                  subtitle: "Customize your app experience",
                  icon: Icons.settings,
                ),
                UpdateAppCard(),
              ],
            ),
            const _SubscriptionSection(),
            Column(
              spacing: 12,
              children: [
                const _AppSettingsCard(),
                const _AboutCard(),
                const _DeviceInfoCard(),
                const _AuthorCard(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwitcher extends StatelessWidget {
  const _ThemeSwitcher();

  static const _options = [
    (ThemeMode.light, Icons.wb_sunny_rounded, 'Light'),
    (ThemeMode.system, Icons.brightness_auto_rounded, 'System'),
    (ThemeMode.dark, Icons.nights_stay_rounded, 'Dark'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: getIt<ThemeNotifier>(),
      builder: (context, _) {
        final notifier = getIt<ThemeNotifier>();
        final selectedIndex = _options.indexWhere((o) => o.$1 == notifier.mode);

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: context.colorScheme.onSurface.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 34,
            width: 140,
            child: Stack(
              children: [
                // Sliding pill
                AnimatedAlign(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubicEmphasized,
                  alignment: Alignment(
                    -1.0 + (2.0 * selectedIndex) / (_options.length - 1),
                    0,
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 1 / _options.length,
                    child: Container(
                      height: 34,
                      decoration: BoxDecoration(
                        color: context.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tabs row
                Row(
                  children:
                      _options.asMap().entries.map((entry) {
                        final isSelected = entry.key == selectedIndex;
                        final (mode, icon, _) = entry.value;

                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => notifier.setMode(mode),
                            child: SizedBox(
                              height: 34,
                              child: Center(
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 200),
                                  scale: isSelected ? 1.15 : 1.0,
                                  child: Icon(
                                    icon,
                                    size: 16,
                                    color:
                                        isSelected
                                            ? context.colorScheme.onSurface
                                            : context.colorScheme.onSurface
                                                .withValues(alpha: 0.35),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
