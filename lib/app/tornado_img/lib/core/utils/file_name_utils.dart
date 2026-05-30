class FileNameUtils {
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