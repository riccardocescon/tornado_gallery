import 'dart:io';

abstract class AppImage {
  final String id;
  final File file;
  final DateTime date;

  String get name => file.path.replaceAll("\\", "/").split('/').last;

  const AppImage({required this.id, required this.file, required this.date});
}
