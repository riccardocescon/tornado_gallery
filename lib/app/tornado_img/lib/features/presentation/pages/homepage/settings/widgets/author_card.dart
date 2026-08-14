part of '../settings_page.dart';

/// The "Author" card: a short note plus name / email / GitHub links.
class _AuthorCard extends StatelessWidget {
  const _AuthorCard();

  @override
  Widget build(BuildContext context) {
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
