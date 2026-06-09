# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tornado IMG is a Flutter mobile app for local image encryption. Users select images from their device, encrypt them with AES-256-CTR (via a native C++ FFI library), and manage them through a folder-based UI. The workspace is a **Melos monorepo** with three packages:

- `lib/app/tornado_img/` — main Flutter application
- `lib/packages/tornado_img_crypto/` — FFI wrapper for the C++ encryption engine
- `lib/packages/logger/` — shared logging utility

## Commands

All commands run from the repo root via Melos.

```bash
# Install dependencies
melos exec -- flutter pub get

# Run the app
melos app:run

# Analyze (fatal on infos)
melos exec -- dart analyze --fatal-infos .

# Format
melos exec -- dart format .

# Run all tests
melos exec --fail-fast -- dart test --reporter=expanded

# Run crypto package tests only
melos crypto:test

# Build Android APK (debug)
melos app:build:android

# Build Android release (ignores crypto package — built separately)
melos exec --flutter --no-private --ignore="*crypto*" -- flutter build apk

# Build iOS release
melos exec --flutter --no-private --ignore="*crypto*" -- flutter build ios
```

The crypto package native binary is compiled separately:
- Windows: `lib/packages/tornado_img_crypto/scripts/build_release.ps1`
- Unix: `lib/packages/tornado_img_crypto/scripts/build_release.sh`

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
`go_router` with named routes. Complex objects (e.g., `EncryptedImage`) are passed between routes via `state.extra`, not URL params.

### Key Patterns
- **Either**: `dartz` `Either<Failure, T>` is the return type for all repository and use case calls.
- **Freezed sealed classes**: `AppState`, `HomepageState`, etc. use `@freezed` union types. Always run `flutter pub run build_runner build` after modifying a `@freezed` class.
- **Lazy decryption**: `EncryptedImage.decryptInfo` starts as `null`. Decrypted bytes are populated on-demand by `GalleryBloc._onDecryptImages` to avoid loading all images into memory at once.
- **FFI encryption**: The `tornado_img_crypto` package exposes a Dart interface over a C++ AES-256-CTR engine compiled via CMake per platform.

## Code Generation

The project uses `freezed` and `build_runner`. After modifying any file with `@freezed`, `@injectable`, or other annotations:

```bash
cd lib/app/tornado_img
flutter pub run build_runner build --delete-conflicting-outputs
```

Generated files (`*.freezed.dart`, `*.g.dart`) are committed to the repo.
