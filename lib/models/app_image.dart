import 'dart:io';

abstract class AppImage {
  final File file;
  final DateTime date;

  const AppImage({required this.file, required this.date});
}
