# Design Language

Single source of truth: `lib/app/tornado_img/lib/theme/theme.dart`.
Never hardcode a colour, radius, or text style in a widget — read it from
`Theme.of(context)` or `Theme.of(context).extension<AppColorsExtension>()`.
If a value you need isn't in the theme, add it to the theme, not to the widget.

## Palette

Dark navy is the identity. Light mode leads with `primary`; **dark mode leads with
`darkAccent`** — every primary action (buttons, FAB, active nav, toggles, progress,
links) turns bright blue there, it does not stay navy.

| Role | Light | Dark |
|---|---|---|
| Accent / primary action | `primary #13233B` | `darkAccent #3B82F6` (hover `#5C97F8`) |
| Scaffold background | `#F5F7FB` | `#0A111E` |
| Surface (cards, dialogs) | `#FFFFFF` | `#141E32` |
| Surface alt (chips, inputs, soft buttons) | `#E7E9EC` | `#1E2B45` |
| Border / divider | `#E2E7F0` | `#2B3B59` |
| Text primary | `#162033` | `#F2F6FC` |
| Text secondary | `#5C6877` | `#9DB0CC` |
| Icon | `#4D5A6D` | `#C5D2E4` |

Status colours are shared across both themes: success `#2E8B57`, warning `#E7A93B`,
error `#D85C5C`.

## Shape

Radii are generous and scale by component — pick the one for the component, don't
default to a single number: **card 24 · dialog 28 · button & input 20 · chip &
text-button 16 · snackbar 18**.

Depth comes from **borders, not shadows**: `elevation: 0` everywhere,
`surfaceTintColor: transparent`, `highlightColor: transparent`. A surface is
separated from its background by a 1px border in the border colour.

Primary/outlined buttons are full-width with a fixed height of 54
(`Size.fromHeight(54)`), padding 20×16.

## Typography

High weights, negative letter-spacing on headings.

- `headlineLarge` 32 / w700 / -0.8 · `headlineMedium` 26 / w700 / -0.5
- `titleLarge` 22 / w700 / -0.3 · `titleMedium` 18 / w600 · `titleSmall` 15 / w600
- `bodyLarge` 16 / w400 · `bodyMedium` 14 / w400 — both `height: 1.4`
- `bodySmall` 13 / w400, text-secondary colour, `height: 1.35`
- `labelLarge` 15 / w600 (white, for filled buttons) · `labelMedium` 13 / w500

## AppColorsExtension

Anything the Material `ColorScheme` can't express lives in `AppColorsExtension`
(`theme/app_colors_ext.dart`): `softBackground`, `softButton`, `success`,
`successContainer`, `scaffoldBackground`, `accent`, `onAccent`, `accentSubtle`,
`heroGradientStart`, `heroGradientEnd`.

Use `accent`/`onAccent` when you need the mode-correct action colour without
branching on brightness. **Hero cards** (the highlighted call-to-action surface,
e.g. "Select Photo") use the `heroGradientStart → heroGradientEnd` gradient:
`#22427E → #15243F` in dark, `primary → primaryDark` in light.

## Components

Reuse `AppCard` (`features/presentation/widgets/app_card.dart`) for the standard
surface card rather than re-declaring `Container` + `BoxDecoration`.
