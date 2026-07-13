import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';

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
  EncryptedImage copyWithDecryptInfo({BytesInfo? decryptInfo}) {
    return EncryptedImage(
      storagePath: storagePath,
      date: date,
      encryptedInfo: encryptedInfo,
      decryptInfo: decryptInfo,
    );
  }

  String get name {
    final raw = FileNameUtils.basename(storagePath.file.path);
    // Normalize double extension e.g. "188.png.png" -> "188.png"
    final lower = raw.toLowerCase();
    for (final ext in Constants.imageExtensions.map((e) => '.$e')) {
      if (lower.endsWith('$ext$ext')) {
        return raw.substring(0, raw.length - ext.length);
      }
    }
    return raw;
  }

  /// Directory of this image relative to its store root ('' for the root).
  /// Private store is rooted at `encrypted/`, the gallery at `TornadoGallery`.
  String get storeRelativeDir {
    final marker =
        storagePath.isPrivateFolder ? 'encrypted' : Constants.appFolderName;
    final parts = storagePath.path.replaceAll('\\', '/').split('/');
    final idx = parts.lastIndexOf(marker);
    if (idx == -1 || idx + 1 >= parts.length) return '';
    final after = parts.skip(idx + 1).toList()..removeLast(); // drop filename
    return after.where((p) => p.trim().isNotEmpty).join('/');
  }

  int get safeSizeBytes {
    final stats = _safeStats();
    final size = stats?.size;
    if (size != null && size >= 0) {
      return size;
    }
    return encryptedInfo.bytes.length;
  }

  DateTime get safeCreatedAt {
    final stats = _safeStats();
    final changed = stats?.changed;
    if (changed != null && changed.year > 1980) {
      return changed;
    }
    return date;
  }

  FileStat? _safeStats() {
    try {
      return storagePath.file.statSync();
    } catch (_) {
      return null;
    }
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
