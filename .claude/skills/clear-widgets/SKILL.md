---
name: clear-widgets
description: Use when a page or widget file is getting long and hard to read and you want to split it into its own /widgets folder. Breaks a page's build tree into small private widget classes under a per-page /widgets folder using the `part of` pattern, reusing existing widgets and promoting cross-page ones to features/presentation/widgets.
---

# clear-widgets — split a heavy page into readable widget files

Goal: keep page files light and readable by moving each section of the build
tree into its own file, grouped by concern. Behaviour never changes — this is a
pure structural refactor.

## Rules

1. **Never leave one huge file.** Split the build tree into small widgets, one
   concern per file. Widgets that serve the same concern live in the same file.
2. **Structure, per page:**
   - Create a `widgets/` folder next to the page file.
   - Each section file starts with `part of '../<page>.dart';` and holds a
     private `_Section extends StatelessWidget`. Tiny sub-pieces stay as helper
     methods inside that class (like `info_cards.dart`'s `_card`).
   - The page declares `part 'widgets/<file>.dart';` under its imports — so the
     page sits at the level of its `widgets/` folder and owns them.
   - Parts share the page's imports. **Never** add `import`/`library` directives
     inside a part file.
3. **Cross-page widgets** → `features/presentation/widgets/` as a **public** class
   with its own imports (not `part of`), so other pages can import it.
4. **Reuse first.** Prefer an existing widget over a new one. If an existing
   widget is almost right, add a parameter to it rather than clone it. Create a
   new widget only when nothing fits.

## How to apply

1. Read the page. List its build-tree sections — usually the `_foo(context)`
   helper methods already present in the `State`.
2. For each section decide: page-specific (→ a `part` file) or reusable across
   pages (→ `features/presentation/widgets/`).
3. Add `part 'widgets/<file>.dart';` lines under the page's imports.
4. Move each section into its part file as `class _Section extends
   StatelessWidget`. Pass any page state (selected value, busy flag) and
   callbacks (`onSelect`, `onBuy`) as constructor params. Sections that only
   need `context` (they can `context.read` a bloc themselves) take no params and
   become `const _Foo()`.
5. In the page `build`, replace each old `_foo(context)` call with
   `const _Foo()` / `_Foo(...)`.
6. **Keep in the page:** `State` fields, `initState`, bloc listeners
   (`_onState`), and anything that mutates state.

## Reference (copy this exactly)

- Pattern: `settings_page.dart` (`part 'widgets/info_cards.dart';`) +
  `widgets/info_cards.dart` (`part of '../settings_page.dart';`, private
  `_InfoCards`), and the private `_ThemeSwitcher` in the same page.
- Never hardcode a colour, radius or text style — use the theme tokens
  (`context.appColors`, `AppStyle.*`, `context.textTheme`). See `DESIGN.md`.

## Verify

```bash
cd lib/app/tornado_img
dart analyze --fatal-infos lib/features/presentation/pages/<page-dir>
```

Analyzer clean confirms the `part`/private-class wiring. The build tree, state
flow and behaviour are unchanged.
