class Constants {
  static const String appFolderName = "TornadoGallery";
  static const int maxEncryptedImages = 20;

  /// Supported image file extensions (lower-case, without the leading dot).
  static const Set<String> imageExtensions = {'png', 'jpg', 'jpeg'};

  // ── Video encryption ────────────────────────────────────────────────────────

  /// Supported video file extensions (lower-case, without the leading dot).
  ///
  /// Encryption is byte-level and container-agnostic; this list exists to filter
  /// the picker and to restore the right extension on decryption.
  static const Set<String> videoExtensions = {'mp4', 'mov'};

  /// Union of [imageExtensions] and [videoExtensions] — every extension a
  /// folder scan should recognize as "ours", regardless of media type.
  static const Set<String> mediaExtensions = {
    ...imageExtensions,
    ...videoExtensions,
  };

  /// Largest video accepted for encryption.
  ///
  /// The encrypted file lives in the app sandbox and is duplicated in cache
  /// while it plays, so an unbounded size fills the device instead of failing
  /// with something the user can act on.
  static const int maxVideoBytes = 2 * 1024 * 1024 * 1024;

  /// 16-byte `uuid` box usertype identifying our ciphertext box: `TORNADO-VIDEO-01`.
  static const List<int> videoBoxUserType = [
    0x54, 0x4F, 0x52, 0x4E, 0x41, 0x44, 0x4F, 0x2D, // TORNADO-
    0x56, 0x49, 0x44, 0x45, 0x4F, 0x2D, 0x30, 0x31, // VIDEO-01
  ];

  /// Payload magic `TVE1`, big-endian.
  static const int videoBoxMagic = 0x54564531;

  /// Payload header version.
  static const int videoBoxVersion = 1;
}
