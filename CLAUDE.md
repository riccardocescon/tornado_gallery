# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tornado IMG is a Flutter mobile app for local image encryption. Users select images from their device, encrypt them with AES-256-CTR (via a native C++ FFI library), and manage them through a folder-based UI. The workspace is a **Melos monorepo** with three packages:

- `lib/app/tornado_img/` — main Flutter application
- `lib/packages/tornado_img_crypto/` — FFI wrapper for the C++ encryption engine
- `lib/packages/logger/` — shared logging utility

## Commands

> **Melos glob is stale.** `melos.yaml` declares `packages: packages/**`, but the
> real packages live under `lib/` (`lib/app/tornado_img`, `lib/packages/*`).
> So `melos exec` matches **zero packages** and silently no-ops (e.g. a
> `melos exec -- dart analyze` prints SUCCESS without analyzing anything). Until
> the glob is fixed, run tooling **per package** (`cd` into each):

```bash
# App package: analyze + tests (the app uses flutter_test, so use `flutter test`)
cd lib/app/tornado_img
dart analyze --fatal-infos .
flutter test                              # all app tests
flutter test test/path/to/foo_test.dart   # a single test file
flutter test --name "substring"           # a single test by name

# Crypto package (also flutter_test — `dart test` fails: it only dev-deps flutter_test)
cd lib/packages/tornado_img_crypto && flutter test

# Logger package (pure Dart)
cd lib/packages/logger && dart test

# Format a package
dart format .
```

Melos scripts that DO work (they scope explicitly): `melos app:run`,
`melos app:build:android`. The `melos crypto:test` script is broken (invokes
`dart test`, which the package can't run).

The crypto package native binary is compiled separately (see `lib/packages/tornado_img_crypto/CLAUDE.md` for full build prerequisites):
- Windows: `lib/packages/tornado_img_crypto/scripts/build_windows.bat`
- iOS/macOS: `lib/packages/tornado_img_crypto/scripts/build_ios.sh`
- C++ engine test/deploy: `lib/cpp/scripts/build_test_deploy.ps1`

The C++ source lives at `lib/cpp/src/` (shared across platforms). Per `README.md` it is excluded from the public repo, but is present in this working tree. Deep docs: `lib/cpp/CLAUDE.md`.

## Architecture

The app follows **Clean Architecture** with three layers inside `lib/app/tornado_img/lib/`:

### Domain (`core/domain/`)
Pure Dart. Contains entities (`EncryptedImage`, `StoragePath`, `BytesInfo`, `EncryptedFolder`, `GalleryImage`, `EncryptionSettings`), abstract repository interfaces, and use cases. No Flutter or platform dependencies.

### Data (`core/data/`)
Implements the domain repositories. Key split:
- **Datasources** are platform-specific: `AndroidPublicStorageDatasource` / `IosPublicStorageDatasource` for the system gallery, `PrivateStorageDatasource` for the app's private filesystem. `StorageRepositoryImpl` selects the correct public datasource at construction time via `Platform.isIOS`.
- Repositories delegate all platform calls to datasources and never touch `Gal`, `PhotoManager`, or `File` directly.

### Presentation (`core/presentation/` + `features/presentation/`)
- **BLoC** (`flutter_bloc` + `freezed`) for all state management.
- `AppBloc` is the **in-memory canonical store** of `EncryptedImage` objects; all UI reads from it, not from disk.
- `HomepageBloc` tracks `_runtimeUpserts` and `_runtimeRemovals` as pending changes before committing to `AppBloc`.
- `StreamManager` watches private and public folders concurrently via `watcher`; folder change events flow into `HomepageBloc` for real-time UI refresh.
- `PurchaseBloc` is the app-wide owner of the Pro entitlement; its `isPro` getter is the single source of truth for every paid gate (see **Monetization** below).
- Feature BLoCs (`EncryptionPageBloc`, `ArchivePageBloc`) are registered as **factories** (not singletons) in `get_it` to allow multiple instances.

### Dependency Injection
`injection_container.dart` wires everything with `get_it`. Singletons for core blocs and repositories; factories for feature blocs.

### Routing
`go_router`. All navigation is **named** via the `Routes` constants
(`core/utils/routes.dart`) — use `context.pushNamed(Routes.x, extra: obj)`,
never raw path strings. Complex objects (e.g. `EncryptedImage`, a bloc instance)
are passed between routes via `state.extra` (cast to the concrete type in the
route builder), not URL params.

### Key Patterns
- **Either**: `dartz` `Either<Failure, T>` starts at the **use case** — repositories
  (e.g. `AppRepository`, `StorageRepository`) return plain futures and let the use
  case wrap them. The one deliberate exception is `PurchaseRepository`: purchases
  have no use-case layer, so the repository *is* the outermost boundary and returns
  `Either<PurchaseFailure, T>` itself.
- **Freezed sealed classes**: `AppState`, `HomepageState`, etc. use `@freezed` union types. Always run `flutter pub run build_runner build` after modifying a `@freezed` class.
- **Lazy decryption**: `EncryptedImage.decryptInfo` starts as `null`. Decrypted bytes are populated on-demand by `GalleryBloc._onDecryptImages` to avoid loading all images into memory at once.
- **FFI encryption**: The `tornado_img_crypto` package exposes a Dart interface over a C++ AES-256-CTR engine compiled via CMake per platform.

### Conventions (follow when adding code)
- **Use cases**: extend `EncryptionUseCase<T, Params>` (Future/`Either`) or
  `StreamUseCase<T, Params>` (Stream/`Either`) from `core/domain/usecases/usecase.dart`.
  Class names end in `UseCase`. Wrap the body in `guardEither('log message', () async {...})`
  — it centralises the try / `Right` / catch·log·`Left(EncryptionFailure)` pattern, so
  don't hand-roll try/catch in a use case.
- **Logging**: one entry point — `appLogger.log(message, LogLayer.x, {error})`.
  `LogLayer` is re-exported from `core/utils/globals.dart` (where `appLogger` lives),
  so importing globals is enough. There are no `logUi`/`logRepository`/… helpers.
- **File names / paths**: use `FileNameUtils.basename()` and `FileNameUtils.extensionOf()`
  and `Constants.imageExtensions` — don't re-inline `split('.')` / `{png,jpg,jpeg}`.
- **Shared UI**: reuse `AppCard` (`features/presentation/widgets/app_card.dart`) for the
  standard surface card instead of re-declaring the `Container`+`BoxDecoration`.
- **Visual style**: read `DESIGN.md` before writing or changing any UI — palette, radii,
  typography and the `AppColorsExtension` tokens all come from
  `theme/theme.dart`. Never hardcode a colour, radius, or text style in a widget.
- **Paid gates**: read `PurchaseBloc.isPro` — never re-derive entitlement from
  `prefs` or the store. Never hardcode a price (see **Monetization**).

### Crypto encoding constraint (do NOT change)
`encryptor_interface.dart` `_encodePhrase` uses `String.codeUnits` (UTF-16 code
units, **not** UTF-8). Key derivation depends on these raw bytes, so changing the
encoding would break decryption of every image already encrypted with a non-ASCII
password. Any migration is a separate task with a migration strategy. The
`tornado_img_crypto` package is **gitignored** (excluded from the public repo) —
edits there apply on disk but won't be committed.

## Monetization (Tornado Gallery Pro)

In-app purchases via `in_app_purchase` (Apple/Google only — **no RevenueCat, no
backend**, which is what keeps the app fully offline). Two SKUs, one entitlement:
a monthly subscription and a lifetime unlock both grant the same `isPro`, and
nothing that reads it cares which one paid.

Background: `docs/tornado-pro-premium-plan.md` (decisions) and
`docs/store-setup.md` (Play Console / App Store Connect setup).

### Free tier vs Pro
| | Free | Pro |
|---|---|---|
| Encrypted images | `Constants.maxEncryptedImages` (20) | unlimited |
| Archives (folders) | `Constants.maxArchives` (3) | unlimited |

### Enforcement — two choke points, and only two
Both were verified as the *sole* path to their action, so a cap check anywhere
else is a bug (and a cap check that's missing from one of these is a revenue leak):

- **Images** → `EncryptionPageBloc.exceedsFreeLimit`. `Routes.encryption` is the
  only way into encryption, and `GalleryEvent.encryptImages` is dispatched only
  from that bloc.
- **Archives** → `ArchivePageBloc.exceedsFreeLimit`, checked in `_onCreateFolder`.
  Counting uses `ArchiveTreeUtils.allFolderKeys` (shared with `foldersAtLevel` —
  don't write a second tree walk).

Hitting a cap emits a **`limitReached`** state, *not* `failure`. A limit is an
offer, not an error: the UI answers it with the paywall, never an error toast.
The Encrypt button is also *disabled* up front so the user never presses
something that can only fail.

### Layering
- `core/data/datasources/purchase_datasource.dart` is the **only** file permitted
  to import `in_app_purchase`. Keep it that way — it is what makes the entitlement
  rules testable without a device or a store.
- **No use cases** for purchases (they would be 1:1 pass-throughs), so
  `PurchaseRepository` is the outermost boundary and returns `Either<PurchaseFailure, T>`.
- `PurchaseBloc` is a **lazy singleton**, provided at the root in `main.dart` and
  set up with `PurchaseEvent.setup()`. Paywall route: `Routes.pro` → `/pro`
  (top-level, because it's pushed from both the home shell and the encryption page).

### Entitlement rules (subtle — do not "simplify")
- **One 7-day grace rule for both SKUs.** Pro holds only while the store has
  confirmed it within `Constants.proGracePeriod`. Lifetime is *not* cached forever.
- **Why:** `restorePurchases()` returns `void`; its results arrive asynchronously
  on `purchaseStream` as `PurchaseStatus.restored`. The plugin gives you **no**
  "the store returned nothing" signal, and the store only ever reports *active*
  purchases — so a cancelled subscription or a refunded lifetime is detectable
  only by **absence**. The 7-day clock *is* that detection: no confirmation ⇒ the
  clock runs out ⇒ Pro drops. Deleting it silently makes cancellations unenforceable.
- Persisted in `prefs`: `pro_plan`, `pro_last_verified`. A silent
  `PurchaseEvent.restore(silent: true)` fires on every app resume to restamp it.
- **`completePurchase()` must run for every `purchased` *and* `restored` event** —
  Google Play auto-refunds anything left unacknowledged for 3 days.
- **Never hardcode a price.** Always render `ProProduct.price`, which is
  `ProductDetails.price` — store-formatted, localised, currency-correct. The
  €1.99 / €19.99 figures exist only in the store consoles.

### Pro visual tokens
`AppColorsExtension`: `pro`, `onPro`, `proSubtle`, `proGradientStart/End`
(a purple family, kept apart from the navy `accent` so premium reads as premium).
Radii: `AppStyle.pro*BorderRadius`. Shared widgets: `features/presentation/widgets/pro_widgets.dart`.

`proGlow()` is a **deliberate, documented exception** to DESIGN.md's "depth from
1px borders, never shadows" — the coloured glow is what marks a Pro CTA. Don't
"fix" it.

### Platform setup (verified against the resolved plugins — don't cargo-cult)
- **No `AndroidManifest.xml` change.** `com.android.vending.BILLING` merges in from
  the Play Billing AAR; the plugin declares it nowhere. The "add the BILLING
  permission" advice you'll find online is obsolete.
- **No `enablePendingPurchases()`** — removed in `in_app_purchase_android` 0.5.0.
- **No Xcode capability or entitlement** — StoreKit needs none, and StoreKit 2 is
  already the plugin default.
- ⚠️ **Debug builds are `com.flockit.tornadogallery.debug`**
  (`applicationIdSuffix` in `android/app/build.gradle.kts`). Play knows nothing about
  that id, so **billing returns zero products in any debug build** and the paywall
  shows "Pro is not available right now." Android IAP must be tested on a
  release build installed from a Play track.

## Code Generation

The project uses `freezed` and `build_runner`. After modifying any file with `@freezed`, `@injectable`, or other annotations:

```bash
cd lib/app/tornado_img
flutter pub run build_runner build --delete-conflicting-outputs
```

Generated files (`*.freezed.dart`, `*.g.dart`) are committed to the repo.
