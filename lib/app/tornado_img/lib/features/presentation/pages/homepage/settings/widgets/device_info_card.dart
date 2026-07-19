part of '../settings_page.dart';

/// The "Info" card: app version and host OS details.
class _DeviceInfoCard extends StatelessWidget {
  const _DeviceInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
