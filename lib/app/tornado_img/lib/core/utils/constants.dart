class Constants {
  static const String appFolderName = "TornadoGallery";

  /// Free-tier limits. Tornado Gallery Pro lifts both.
  static const int maxEncryptedImages = 20;
  static const int maxArchives = 3;

  /// Supported image file extensions (lower-case, without the leading dot).
  static const Set<String> imageExtensions = {'png', 'jpg', 'jpeg'};

  // ── Store product ids (must match Play Console / App Store Connect) ─────────
  static const String proMonthlyId = 'tornado_img_pro_monthly';
  static const String proLifetimeId = 'tornado_img_pro_lifetime';
  static const Set<String> proProductIds = {proMonthlyId, proLifetimeId};

  /// An entitlement the store hasn't confirmed for this long drops back to free.
  /// Applies to both SKUs: it is how a cancelled subscription or a refunded
  /// lifetime is detected, since the store only ever reports *active* purchases.
  static const Duration proGracePeriod = Duration(days: 7);

  // Manage-subscription deep links (the plugin exposes no API for this).
  static const String manageSubscriptionIos =
      'https://apps.apple.com/account/subscriptions';
  static const String manageSubscriptionAndroid =
      'https://play.google.com/store/account/subscriptions';

  // Legal links required on the paywall (App Store guideline 3.1.2).
  static const String termsUrl =
      'https://github.com/riccardocescon/tornado_gallery/blob/subscription_plan/TERMS.md';
  static const String privacyUrl =
      'https://github.com/riccardocescon/tornado_gallery/blob/subscription_plan/PRIVACY.md';
}
