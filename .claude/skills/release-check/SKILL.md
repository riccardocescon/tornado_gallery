---
name: release-check
description: Use when preparing a new release of Tornado IMG (version bump, store build, pre-publish checklist) or when asked to "prepare the release" / "bump the version" / build for the Play Store or App Store.
---

# Release checklist

Run in order; each step gates the next.

1. **Tests + analyze** (per package — melos's glob is stale, see `CLAUDE.md`):
   ```bash
   cd lib/app/tornado_img && dart analyze --fatal-infos . && flutter test
   cd ../../packages/tornado_img_crypto && flutter test
   cd ../logger && dart test
   ```

2. **Bump the version** in
   [pubspec.yaml](../../../lib/app/tornado_img/pubspec.yaml):
   `version: X.Y.Z+B` — bump both the semver and the build number (`+B` must
   strictly increase for the stores).

3. **What's New popup** — run the `update-whats-new` skill. The popup keys off
   the pubspec version, so this and step 2 ship together.

4. **Release build.** ⚠️ `melos app:build:android` builds a **debug** APK
   (`flutter build apk --debug`) — never ship it. For the stores:
   ```bash
   cd lib/app/tornado_img
   flutter build appbundle --release   # Android / Play Console
   flutter build ipa --release        # iOS / App Store Connect (macOS only)
   ```

5. **IAP smoke test on a release build from a Play track.** Debug builds use the
   `com.flockit.tornadogallery.debug` application id, which Play doesn't know —
   billing returns zero products and the paywall shows "Pro is not available
   right now". This is expected in debug, and it means the paywall can ONLY be
   verified on a release build installed from a Play track (internal testing is
   fine). Check: products load with store-formatted prices, purchase and restore
   both work.

6. **Store consoles** — prices, product ids (`tornado_img_pro_monthly`,
   `tornado_img_pro_lifetime`) and listing text live only there; see
   [docs/store-setup.md](../../../docs/store-setup.md). Nothing in the codebase
   to change.

## Common mistakes

- Shipping the melos debug APK.
- Bumping the semver but not the `+B` build number (store upload rejected).
- Judging the paywall "broken" from a debug build (see step 5 — it's the id).
- Skipping `update-whats-new`, so users see the previous release's slides.
