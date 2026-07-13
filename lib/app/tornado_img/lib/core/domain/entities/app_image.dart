import 'dart:io';

import 'package:tornado_img_app/core/utils/file_name_utils.dart';

abstract class AppImage {
  final String id;
  final File file;
  final DateTime date;

  String get name => FileNameUtils.basename(file.path);

  const AppImage({required this.id, required this.file, required this.date});
}
