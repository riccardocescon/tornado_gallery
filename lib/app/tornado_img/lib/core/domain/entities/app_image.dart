import 'dart:io';

import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';

abstract class AppImage {
  final String id;
  final File file;
  final DateTime date;

  String get name => FileNameUtils.basename(file.path);

  /// Mirrors [EncryptedImage.isVideo] for the pre-encryption side: routes
  /// picker selections by extension (encryption is byte-level and doesn't
  /// care, but callers do — e.g. which use case to dispatch to).
  bool get isVideo =>
      Constants.videoExtensions.contains(FileNameUtils.extensionOf(file.path));

  const AppImage({required this.id, required this.file, required this.date});
}
