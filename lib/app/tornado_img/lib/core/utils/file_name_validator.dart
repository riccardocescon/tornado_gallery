final _fileNameRegex = RegExp(r'^[a-zA-Z0-9_\-()\[\]{}]+$');

String? validateFileName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Name cannot be empty';
  }
  if (!_fileNameRegex.hasMatch(value)) {
    return 'Name can only contain letters, numbers, _, -, and parentheses';
  }
  return null;
}
