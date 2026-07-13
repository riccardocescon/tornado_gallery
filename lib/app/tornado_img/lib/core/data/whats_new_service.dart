import 'package:shared_preferences/shared_preferences.dart';

/// Decides whether the "What's New" popup should be shown after an app update.
///
/// The popup appears only on real updates: a previously stored version must
/// exist AND differ from the current one. Fresh installs are seeded silently so
/// the very next update — not the first launch — triggers the popup.
class WhatsNewService {
  WhatsNewService(this._prefs);

  static const _key = 'whats_new_last_version';

  final SharedPreferences _prefs;

  /// Returns true when [currentVersion] differs from a previously stored
  /// version. Returns false on a fresh install (nothing stored yet).
  bool shouldShow(String currentVersion) {
    final stored = _prefs.getString(_key);
    return stored != null && stored != currentVersion;
  }

  /// Persists [currentVersion] so the popup is only shown once per update.
  Future<void> markShown(String currentVersion) async {
    await _prefs.setString(_key, currentVersion);
  }
}
