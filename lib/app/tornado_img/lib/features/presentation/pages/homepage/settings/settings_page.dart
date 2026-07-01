import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/presentation/widgets/update_app_card.dart';
import 'package:tornado_img_app/core/utils/assets.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/presentation/widgets/contained_item.dart';
import 'package:tornado_img_app/features/presentation/widgets/page_title.dart';
import 'package:tornado_img_app/injection_container.dart';
import 'package:tornado_img_app/theme/theme_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

part 'widgets/info_cards.dart';

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
            Column(
              spacing: 12,
              children: [
                Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    borderRadius: AppStyle.cardBorderRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "App",
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Column(
                        spacing: 8,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Theme", style: context.textTheme.bodyLarge),
                              _ThemeSwitcher(),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Logger",
                                style: context.textTheme.bodyLarge,
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () {
                                  context.push('/logger');
                                },
                                icon: Icon(Icons.arrow_forward_ios_rounded),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Request feature / Report bug",
                                style: context.textTheme.bodyLarge,
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () {
                                  final url = Uri.parse(
                                    "https://github.com/riccardocescon/tornado_gallery/issues",
                                  );
                                  canLaunchUrl(url).then((can) {
                                    if (!can) return;
                                    launchUrl(url);
                                  });
                                },
                                icon: Icon(Icons.open_in_new_rounded),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    borderRadius: AppStyle.cardBorderRadius,
                  ),
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "What's Tornado Gallery?",
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Tornado Gallery aims to provide a new level of privacy for your photos by encyrpting them visually, preventing social embarrassment and adding an additional layer of security for picture scans from storage drivers",
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      _InfoCards(),
                      Text(
                        "Storage usage",
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Currently the storage limit is set to ${Constants.maxEncryptedImages} encrypted files.\nIn future updates more storage management options will be added.",
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    borderRadius: AppStyle.cardBorderRadius,
                  ),
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Info",
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Column(
                        spacing: 4,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'App version:',
                                style: context.textTheme.labelMedium,
                              ),
                              Text(
                                '${packageInfo.version}+${packageInfo.buildNumber}',
                                style: context.textTheme.labelMedium,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('OS:', style: context.textTheme.labelMedium),
                              Text(
                                Platform.operatingSystem,
                                style: context.textTheme.labelMedium,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'OS version:',
                                style: context.textTheme.labelMedium,
                              ),
                              Text(
                                Platform.operatingSystemVersion,
                                style: context.textTheme.labelMedium,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'locale',
                                style: context.textTheme.labelMedium,
                              ),
                              Text(
                                Platform.localeName,
                                style: context.textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _author(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _author() {
    final email = 'tornadogallery@iot.cescon.dev';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppStyle.cardBorderRadius,
      ),
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Author",
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Column(
              spacing: 8,
              children: [
                Text(
                  "Hi, i'm Riccardo, the developer of this project, thank you for using Torando Gallery! If you have any feedback or suggestions, feel free to reach out with the contact information below.\nI am a solo developer and I work on this project in my free time, so your support means a lot to me!",
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.person_rounded, size: 18),
                    Text(
                      'Riccardo Cescon',
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.email_rounded, size: 18),
                    GestureDetector(
                      onTap: () {
                        var url = Uri.parse("mailto:$email");
                        canLaunchUrl(url).then((can) {
                          if (!can) return;
                          launchUrl(url);
                        });
                      },
                      child: Text(
                        email,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    SizedBox.square(
                      dimension: 18,
                      child: Image.asset(
                        IconAssets.github,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        var url = Uri.parse(
                          "https://github.com/riccardocescon",
                        );
                        canLaunchUrl(url).then((can) {
                          if (!can) return;
                          launchUrl(url);
                        });
                      },
                      child: Text(
                        'riccardocescon',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
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

