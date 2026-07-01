---
name: update-whats-new
description: Use when preparing a new app release for Tornado IMG and the "What's New" popup needs to reflect the new release's features. Overwrites the previous release's slides in whats_new_dialog.dart so each update shows only the current release's highlights.
---

# Update the "What's New" popup for a release

The "What's New" popup is shown **once after an app update**, summarizing that
release's new features. Each release **overwrites** the previous release's
content — it is not cumulative.

## How the popup works (context)

- UI: [whats_new_dialog.dart](../../../lib/app/tornado_img/lib/core/presentation/widgets/whats_new_dialog.dart)
  — a paged `Dialog` driven by a `static const _slides` list of `_SlideData`.
- Trigger logic: [whats_new_service.dart](../../../lib/app/tornado_img/lib/core/data/whats_new_service.dart)
  — compares `prefs['whats_new_last_version']` to `packageInfo.version`. Shows
  only when a stored version exists AND differs (real update, not fresh install).
- Hook: `ShellHomepage.initState` post-frame callback in
  [shell_homepage.dart](../../../lib/app/tornado_img/lib/features/presentation/pages/homepage/shell_homepage.dart).
- Version source: `version:` in
  [pubspec.yaml](../../../lib/app/tornado_img/pubspec.yaml). The popup keys off
  the running build's version — no version string is hardcoded in the dialog.

## Steps to update for a new release

1. **Bump the version** in `pubspec.yaml` (`version: X.Y.Z+B`). The popup fires
   automatically on the next launch after users update to this version. Do NOT
   reference the version number inside the dialog.

2. **Rewrite the slides.** In `whats_new_dialog.dart`, replace the entire
   `static const _slides = <_SlideData>[ ... ]` list with the new release's
   features. Delete the old slides — content is per-release, not cumulative.

   Each slide is:
   ```dart
   _SlideData(
     icon: Icons.<rounded_icon>,   // pick a Material rounded icon that fits
     title: 'Short title',          // English, ~3 words
     body: 'One or two sentences describing the feature.', // English
   ),
   ```
   - Keep **1–4 slides**. The dialog paging, dots, and Skip/Next/Get Started
     adapt automatically to `_slides.length` — no other code changes needed.
   - Text is **English**.
   - Prefer `Icons.*_rounded` variants to match the existing visual style.

3. **Do not touch** the trigger logic, `WhatsNewService`, the DI registration,
   or the `ShellHomepage` hook. Only the `_slides` list (and `pubspec.yaml`
   version) change per release.

4. **Verify**:
   - `cd lib/app/tornado_img && dart analyze --fatal-infos lib/core/presentation/widgets/whats_new_dialog.dart`
   - Manual: simulate an update by setting an older value, e.g. open the app,
     then in devtools/adb set `whats_new_last_version` to an older string and
     relaunch — the popup must appear, page through all slides, and close on
     "Get Started". Relaunch again → must NOT reappear.

## Styling notes (keep consistent)

- Hero card uses `context.appColors.heroGradientStart/heroGradientEnd` +
  `onAccent` icon color — leave as is so light/dark themes stay correct.
- Active dot / accents use `context.appColors.accent`.
- Title: `context.textTheme.titleLarge`; body: `bodyMedium` with
  `onSurfaceVariant`. Reuse these; don't hardcode colors.
