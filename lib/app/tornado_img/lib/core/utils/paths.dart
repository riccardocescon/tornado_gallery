import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<List<String>> getFolderPaths() async {
  // Get the application documents directory
  final appDir = await getApplicationDocumentsDirectory();
  String path = '${appDir.path}/encrypted';
  final encryptedDir = Directory(path);
  if (!encryptedDir.existsSync()) {
    await encryptedDir.create(recursive: true);
  }

  final folders = encryptedDir.listSync(recursive: true).whereType<Directory>();
  return folders.map((dir) => dir.path).toList();
}
