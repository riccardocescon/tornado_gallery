import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class EncryptedImage with EquatableMixin {
  final DateTime date;
  final BytesInfo encryptedInfo;
  final BytesInfo? decryptInfo;
  final StoragePath storagePath;

  bool get isDecrypted => decryptInfo != null;

  EncryptedImage({
    required this.storagePath,
    required this.date,
    required this.encryptedInfo,
    this.decryptInfo,
  });

  EncryptedImage copyWith({
    StoragePath? storagePath,
    DateTime? date,
    BytesInfo? encryptedInfo,
    BytesInfo? decryptInfo,
    bool? isPrivateFolder,
    String? assetId,
  }) {
    return EncryptedImage(
      storagePath: storagePath ?? this.storagePath.copyWith(),
      date: date ?? this.date,
      encryptedInfo: encryptedInfo ?? this.encryptedInfo.copyWith(),
      decryptInfo: decryptInfo ?? this.decryptInfo?.copyWith(),
    );
  }

  /// Returns a copy of this [EncryptedImage] with the provided optional values
  /// Use this instead of [copyWith] when you want to clear optionalData by passing null
  EncryptedImage overrideWith({BytesInfo? decryptInfo}) {
    return EncryptedImage(
      storagePath: storagePath,
      date: date,
      encryptedInfo: encryptedInfo,
      decryptInfo: decryptInfo,
    );
  }

  String get name {
    final raw = storagePath.file.path.replaceAll("\\", "/").split('/').last;
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
    storagePath,
    date,
    encryptedInfo,
    decryptInfo,
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

class StoragePath {
  final String path;
  final String? assetId;
  final bool isPrivateFolder;

  File get file => File(path);

  const StoragePath({
    required this.path,
    required this.isPrivateFolder,
    required this.assetId,
  });

  StoragePath copyWith({String? path, String? assetId, bool? isPrivateFolder}) {
    return StoragePath(
      assetId: assetId ?? this.assetId,
      isPrivateFolder: isPrivateFolder ?? this.isPrivateFolder,
      path: path ?? this.path,
    );
  }
}
