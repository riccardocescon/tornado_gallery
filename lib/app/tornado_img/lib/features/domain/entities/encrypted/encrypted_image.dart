import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class EncryptedImage with EquatableMixin {
  final String path;
  final DateTime date;
  final BytesInfo encryptedInfo;
  final BytesInfo? decryptInfo;
  final bool isPrivateFolder;
  final String? assetId;

  bool get isDecrypted => decryptInfo != null;

  File get file => File(path);

  EncryptedImage({
    required this.path,
    required this.date,
    required this.encryptedInfo,
    required this.isPrivateFolder,
    this.decryptInfo,
    this.assetId,
  });

  EncryptedImage copyWith({
    String? path,
    DateTime? date,
    BytesInfo? encryptedInfo,
    BytesInfo? decryptInfo,
    bool? isPrivateFolder,
    String? assetId,
  }) {
    return EncryptedImage(
      path: path ?? this.path,
      date: date ?? this.date,
      encryptedInfo: encryptedInfo ?? this.encryptedInfo.copyWith(),
      decryptInfo: decryptInfo ?? this.decryptInfo?.copyWith(),
      isPrivateFolder: isPrivateFolder ?? this.isPrivateFolder,
      assetId: assetId ?? this.assetId,
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
      isPrivateFolder: isPrivateFolder,
      assetId: assetId,
    );
  }

  String get name {
    final raw = file.path.replaceAll("\\", "/").split('/').last;
    // Normalize double extension e.g. "188.png.png" -> "188.png"
    final lower = raw.toLowerCase();
    for (final ext in ['.png', '.jpg', '.jpeg']) {
      if (lower.endsWith('$ext$ext')) {
        return raw.substring(0, raw.length - ext.length);
      }
    }
    return raw;
  }

  @override
  List<Object?> get props => [
    path,
    date,
    encryptedInfo,
    decryptInfo,
    isPrivateFolder,
    assetId,
  ];
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
