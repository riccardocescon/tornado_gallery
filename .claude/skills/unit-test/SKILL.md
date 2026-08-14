---
name: unit-test
description: Use when adding tests for a function, use case, repository or bloc in the Flutter app. Creates the test under test/ mirroring the source path, covers positive and negative cases, tests callees first, and writes an integration-style test (real components, only the outermost boundary mocked) when the unit is a bloc→usecase/repository/api flow.
---

# unit-test — write a test that actually pins the behaviour down

Goal: a new test file that mirrors the source tree, covers every branch (happy
and sad), and — for anything bigger than one function — proves the real wiring
end to end. Match the repo's existing style exactly; do not invent a new one.

Stack (already in `lib/app/tornado_img`, do NOT add anything): `flutter_test`,
`bloc_test`, `mocktail`. **Mocks are mocktail, hand-declared — never mockito, never
`build_runner`/`.mocks.dart` codegen.**

## Rules

1. **Mirror the path.** A source at `lib/<p>/foo.dart` gets a test at
   `test/<p>/foo_test.dart` — same tree, `_test.dart` suffix. Blocs live at
   `test/.../bloc/<name>/<name>_test.dart`.
2. **Positive *and* negative.** Every behaviour needs both: the value/`Right`
   path and the empty/error/`Left` path, plus the boundary (exactly at a cap vs
   one past it — mind `>` vs `>=`).
3. **Test the callees first.** If the target calls other project functions,
   each needs its own `_test.dart`. If one is missing, **write that test first**,
   then the target. A pure helper with a `now`/seam parameter is tested directly
   with no mocks — prefer that seam over faking time.
4. **Big flow ⇒ integration test.** When the unit spans
   bloc → usecase / repository / api, write an integration-style test in `test/`
   that wires the **real** objects together and mocks **only the outermost
   boundary** (datasource / platform channel / `in_app_purchase` / `File`).
   Cover the positive and negative path of the whole chain, not just one layer.

## How to write it (mocktail)

1. Declare mocks as private classes at the top:
   ```dart
   class _MockPurchaseRepository extends Mock implements PurchaseRepository {}
   ```
   For a type you `extends Fake implements X` when you only need to satisfy a
   fallback (see `_FakePurchaseDetails` in the repo test).
2. In `setUpAll`, `registerFallbackValue(...)` every custom type passed to
   `any()`/captured by `when`/`verify`.
3. In `setUp`, new up fresh mocks and stub streams:
   `when(() => bloc.stream).thenAnswer((_) => const Stream.empty());`. A local
   `makeBloc({...})` / `makeSut()` factory builds the subject.
4. Sync getter logic → plain `group`/`test`. Event→state flows →
   `blocTest<Bloc, State>('desc', build:, act:, expect:, verify:)`. Assert
   `dartz` results with `Right(...)`, `.isLeft()`, `.fold(...)`.
5. Drive async streams with a `StreamController` and pump with
   `await Future<void>.delayed(Duration.zero);`. Close controllers in `tearDown`.
6. Name tests as behavioural sentences ("returns Left when the store is
   unavailable", "a free user one past the cap is blocked").

## Reference (copy the style from these)

- Bloc + cap logic: `test/features/presentation/bloc/encryption_page_bloc/encryption_page_bloc_test.dart`
- Repository + stream + `SharedPreferences.setMockInitialValues`:
  `test/core/data/repositories/purchase_repository_impl_test.dart`
- Use case + `Either`: `test/core/domain/usecases/create_folder_usecase_test.dart`

## Verify

```bash
cd lib/app/tornado_img
flutter test test/<p>/foo_test.dart
dart analyze --fatal-infos test/<p>/foo_test.dart
```

Then run the full suite (`flutter test`) once to confirm no regressions.
