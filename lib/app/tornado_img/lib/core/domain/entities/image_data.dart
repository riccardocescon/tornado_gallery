import 'dart:io';

class ImageData {
  final String id;
  final File file;
  final DateTime date;

  const ImageData({required this.id, required this.file, required this.date});

  @override
  String toString() => 'ImageData(id: $id, file: ${file.path}, date: $date)';
}
