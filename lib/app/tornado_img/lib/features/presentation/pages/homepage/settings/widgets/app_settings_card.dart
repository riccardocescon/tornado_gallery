part of '../settings_page.dart';

/// The "App" card: theme switcher, logger entry, and the GitHub issues link.
class _AppSettingsCard extends StatelessWidget {
  const _AppSettingsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      context.pushNamed(Routes.logger);
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
    );
  }
}
