class FileNameUtils {
  /// Returns the last path segment of [path], treating both `/` and `\`
  /// as separators so it behaves consistently across platforms.
  static String basename(String path) =>
      path.replaceAll('\\', '/').split('/').last;

  /// Returns the lower-cased text after the last `.` in [path], without the
  /// leading dot. Mirrors the existing `split('.').last.toLowerCase()` usage
  /// (if there is no `.`, the whole string is returned).
  static String extensionOf(String path) => path.split('.').last.toLowerCase();

  static String sanitizeFileStem(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'image';

    // Keep filenames path-safe across platforms by replacing separators and
    // reserved characters with underscores.
    final sanitized = trimmed
        .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^\.+'), '')
        .replaceAll(RegExp(r'\.+$'), '');

    return sanitized.isEmpty ? 'image' : sanitized;
  }
}
