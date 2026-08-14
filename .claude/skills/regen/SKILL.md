---
name: regen
description: Use after modifying any @freezed class (bloc states/events, entities) in the Tornado IMG app, or when the analyzer reports missing *.freezed.dart / undefined union members, part-of errors, or stale generated code. Runs build_runner in the right package and verifies with analyze.
---

# Regenerate freezed code (build_runner)

Only the **app package** (`lib/app/tornado_img`) uses `freezed`/`build_runner`.
The crypto and logger packages have no codegen — never run build_runner there.
Do not run it via `melos exec` either (stale glob matches zero packages and
silently no-ops).

## Steps

```bash
cd lib/app/tornado_img
flutter pub run build_runner build --delete-conflicting-outputs
dart analyze --fatal-infos .
```

Both steps, always: build_runner can succeed while the analyzer still fails
(e.g. a `when`/`map` call site now missing the new union case). Fix every
call site the analyzer reports — adding a state/event is not done until all
`when`/`map` handlers cover it.

## When this applies

- Edited any `@freezed` union: `*_state.dart`, `*_event.dart`, entities.
- Errors like `The name '_LimitReached' isn't defined`, `Target of URI hasn't
  been generated`, `part 'x.freezed.dart' not found`.

## Notes

- Generated `*.freezed.dart` files are **committed** — include them in the same
  commit as the source change.
- Never hand-edit a `*.freezed.dart` file.
