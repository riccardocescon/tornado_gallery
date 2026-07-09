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
- **Either**: `dartz` `Either<Failure, T>` is the return type for all repository and use case calls.
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

### Crypto encoding constraint (do NOT change)
`encryptor_interface.dart` `_encodePhrase` uses `String.codeUnits` (UTF-16 code
units, **not** UTF-8). Key derivation depends on these raw bytes, so changing the
encoding would break decryption of every image already encrypted with a non-ASCII
password. Any migration is a separate task with a migration strategy. The
`tornado_img_crypto` package is **gitignored** (excluded from the public repo) —
edits there apply on disk but won't be committed.

## Code Generation

The project uses `freezed` and `build_runner`. After modifying any file with `@freezed`, `@injectable`, or other annotations:

```bash
cd lib/app/tornado_img
flutter pub run build_runner build --delete-conflicting-outputs
```

Generated files (`*.freezed.dart`, `*.g.dart`) are committed to the repo.
