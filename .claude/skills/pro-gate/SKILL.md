---
name: pro-gate
description: Use when adding or changing a free-tier limit or Pro-gated feature in Tornado IMG (new cap, new premium-only action, paywall trigger), or when a limit incorrectly shows an error toast instead of the paywall.
---

# Add or change a Pro gate

A limit is an **offer, not an error**: hitting a cap must lead to the paywall,
never to an error toast. Read the **Monetization** section of `CLAUDE.md` first —
especially "Enforcement" and "Entitlement rules".

## The pattern (copy the existing gates)

Working precedents to imitate:
- Images: `EncryptionPageBloc.exceedsFreeLimit` in
  [encryption_page_bloc.dart](../../../lib/app/tornado_img/lib/features/presentation/bloc/encryption_page_bloc/encryption_page_bloc.dart)
- Archives: `ArchivePageBloc.exceedsFreeLimit` (checked in `_onCreateFolder`) in
  [archive_page_bloc.dart](../../../lib/app/tornado_img/lib/features/presentation/bloc/archive_page_bloc/archive_page_bloc.dart)

Steps:

1. **Cap constant** in
   [constants.dart](../../../lib/app/tornado_img/lib/core/utils/constants.dart)
   next to `maxEncryptedImages` / `maxArchives`.
2. **One choke point.** Find the *single* bloc handler through which the action
   flows (verify it is the only path — if there are two, that's the bug to fix
   first). Add an `exceedsFreeLimit` getter there: read **`PurchaseBloc.isPro`**
   — never `prefs`, never the store, never a copied flag.
3. **`limitReached` state**, not `failure`: add the case to the bloc's `@freezed`
   state union, `emit` it when the cap is hit, then run the `regen` skill.
4. **UI answers with the paywall**: in the page's `BlocListener`,
   `limitReached: (_) => context.pushNamed(Routes.pro)` (see
   `encryption_page.dart` for the exact precedent). Where possible also disable
   the triggering button up front via `exceedsFreeLimit`, so the user never taps
   something that can only fail.
5. **Test it**: follow the `unit-test` skill; `premium_gate_integration_test.dart`
   shows the integration-style approach for gates.

## Never

- Re-derive entitlement outside `PurchaseBloc.isPro`.
- Hardcode a price anywhere (render `ProProduct.price`).
- Emit `failure` for a cap, or show a toast/snackbar for it.
- Add a second cap check "for safety" somewhere else — one choke point per action.
