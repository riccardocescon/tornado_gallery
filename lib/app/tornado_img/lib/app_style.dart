import 'package:flutter/widgets.dart';

class AppStyle {
  static final cardBorderRadius = BorderRadius.circular(20);
  static final detailsBorderRadius = BorderRadius.circular(14);

  // Pro surfaces. Slightly larger radii than the rest of the app on purpose —
  // the paywall is meant to feel like its own place.
  static final proCardBorderRadius = BorderRadius.circular(22);
  static final proPlanBorderRadius = BorderRadius.circular(20);
  static final proButtonBorderRadius = BorderRadius.circular(18);
  static final proChipBorderRadius = BorderRadius.circular(11);
}
