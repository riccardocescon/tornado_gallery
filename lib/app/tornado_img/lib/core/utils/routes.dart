/// Centralised route names and paths for the app's [GoRouter].
///
/// Navigation uses **named** routes everywhere so call sites are independent
/// of where they are triggered from (no more mix of absolute `/encryption`
/// and relative `./encrypted_image_page` pushes).
class Routes {
  Routes._();

  // ── Route names (use with context.pushNamed / goNamed) ────────────────────
  static const String home = 'home';
  static const String logger = 'logger';
  static const String encryption = 'encryption';
  static const String archive = 'archive';
  static const String encryptedImagePage = 'encrypted_image_page';
  static const String videoPlayer = 'video_player';

  // ── Route paths (use in GoRoute path: definitions) ────────────────────────
  static const String homePath = '/';
  static const String loggerPath = '/logger';
  static const String encryptionPath = 'encryption';
  static const String archivePath = 'archive';
  static const String encryptedImagePagePath = 'encrypted_image_page';
  static const String videoPlayerPath = 'video_player';
}
