import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class EncryptedImage with EquatableMixin {
  final String path;
  final DateTime date;
  final BytesInfo encryptedInfo;
  final BytesInfo? decryptInfo;

  bool get isDecrypted => decryptInfo != null;

  File get file => File(path);

  EncryptedImage({
    required this.path,
    required this.date,
    required this.encryptedInfo,
    this.decryptInfo,
  });

  EncryptedImage copyWith({
    String? path,
    DateTime? date,
    BytesInfo? encryptedInfo,
    BytesInfo? decryptInfo,
  }) {
    return EncryptedImage(
      path: path ?? this.path,
      date: date ?? this.date,
      encryptedInfo: encryptedInfo ?? this.encryptedInfo.copyWith(),
      decryptInfo: decryptInfo ?? this.decryptInfo?.copyWith(),
    );
  }

  /// Returns a copy of this [EncryptedImage] with the provided optional values
  /// Use this instead of [copyWith] when you want to clear optionalData by passing null
  EncryptedImage overrideWith({BytesInfo? decryptInfo}) {
    return EncryptedImage(
      path: path,
      date: date,
      encryptedInfo: encryptedInfo,
      decryptInfo: decryptInfo,
    );
  }

  String get name => file.path.replaceAll("\\", "/").split('/').last;

  @override
  List<Object?> get props => [path, date, encryptedInfo, decryptInfo];
}

class BytesInfo with EquatableMixin {
  final Uint8List bytes;
  final String hash;

  const BytesInfo({required this.bytes, required this.hash});

  BytesInfo copyWith({Uint8List? bytes, String? hash}) {
    return BytesInfo(bytes: bytes ?? this.bytes, hash: hash ?? this.hash);
  }

  @override
  List<Object?> get props => [hash];
}
