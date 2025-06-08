import 'dart:io';

abstract class AppImage {
  final String id;
  final File file;
  final DateTime date;

  const AppImage({required this.id, required this.file, required this.date});
}
