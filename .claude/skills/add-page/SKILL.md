---
name: add-page
description: Use when adding a new page/screen to the Tornado IMG app, or when a new route, paywall-style destination, or navigable dialog-replacement is needed. Covers the four files a page touches (page folder, Routes constants, GoRouter table, DI) so none is forgotten.
---

# Add a new page + route

Every page in the app touches exactly **four places**. Skipping one produces a
runtime "unknown route" or a bloc that can't be resolved — not a compile error —
so follow the list in order.

## Steps

1. **Page widget** — create `features/presentation/pages/<page>/<page>.dart`
   (package `tornado_img_app`, base path `lib/app/tornado_img/lib/`).
   Sub-widgets go in `<page>/widgets/` using the `part of` pattern — see the
   `clear-widgets` skill. Read `DESIGN.md` first; use theme tokens, never
   hardcoded colors/radii.

2. **Route constants** — in
   [core/utils/routes.dart](../../../lib/app/tornado_img/lib/core/utils/routes.dart)
   add a **pair**: a name (`static const String myPage = 'my_page';`) and a path
   (`myPagePath`). Nested routes use a relative path (`'my_page'`), top-level
   routes an absolute one (`'/my_page'`). Top-level is only for pages pushed
   from multiple parents (precedent: `proPath` — see its doc comment).

3. **GoRoute** — in
   [routes.dart](../../../lib/app/tornado_img/lib/routes.dart) (package root)
   add a `GoRoute(path: r.Routes.myPagePath, name: r.Routes.myPage, ...)`.
   Complex objects arrive via `state.extra` and are cast in the builder; if the
   page needs a bloc, wrap it there in a `BlocProvider(create: (_) => getIt<MyPageBloc>())`.

4. **DI** — if a bloc was created, register it in
   [injection_container.dart](../../../lib/app/tornado_img/lib/injection_container.dart)
   as a **`registerFactory`** (feature blocs are factories; only app-wide blocs
   like `AppBloc`/`PurchaseBloc` are lazy singletons).

Navigation from call sites: `context.pushNamed(Routes.myPage, extra: obj)` —
never raw path strings.

## Verify

```bash
cd lib/app/tornado_img
dart analyze --fatal-infos .
```

Then navigate to the page in-app (`melos app:run`) — route wiring errors only
surface at runtime.

## Common mistakes

- Adding the name but not the path constant (or vice versa) — always the pair.
- Registering a feature bloc as a singleton — two pushes of the same route then
  share state.
- Passing data via URL params — this app passes objects through `state.extra`.
