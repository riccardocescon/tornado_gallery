part of 'gallery_viewmodel.dart';

int _findInsertIndexDescending(List<GalleryImage> images, DateTime newDate) {
  int low = 0;
  int high = images.length;

  while (low < high) {
    final mid = (low + high) ~/ 2;

    if (images[mid].date.isAfter(newDate)) {
      // mid is newer => go right
      low = mid + 1;
    } else {
      // mid is older or equal => go left
      high = mid;
    }
  }

  return low;
}

Future<bool> _requestPermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.photos.request();
    return status.isGranted;
  } else if (Platform.isIOS) {
    final status = await Permission.photosAddOnly.request();
    return status.isGranted;
  }
  return false;
}

Future<AssetEntity?> _findSavedImageByName(String fileName) async {
  final albums = await PhotoManager.getAssetPathList(
    type: RequestType.image,
    onlyAll: true,
  );

  if (albums.isEmpty) return null;

  final recentAssets = await albums.first.getAssetListRange(
    start: 0,
    end: 50, // Scan recent 50 images
  );

  for (final asset in recentAssets) {
    final title = await asset.titleAsync;
    if (title == fileName) {
      return asset;
    }
  }

  return null;
}

@Deprecated('This is slow, use scrambleImageIsolateV2 instead')
Future<img.Image> scrambleImageIsolate(Map<String, dynamic> args) async {
  final originalBytes = args['imageBytes'] as Uint8List;
  final width = args['width'] as int;
  final height = args['height'] as int;
  final password = args['password'] as String;

  final original = img.Image.fromBytes(
    width: width,
    height: height,
    bytes: originalBytes.buffer,
  );

  final key = sha256.convert(utf8.encode(password)).bytes;
  final iv = Uint8List.fromList(List.generate(16, (i) => i));

  final pixels = original.toUint8List();

  final cipher = StreamCipher('AES/CTR')
    ..init(true, ParametersWithIV(KeyParameter(Uint8List.fromList(key)), iv));

  final scrambled = cipher.process(pixels);

  final bytesPerPixel = pixels.length ~/ (width * height); // likely 3 or 4
  final scrambledImage = img.Image(width: width, height: height);

  for (int i = 0; i < width * height; i++) {
    int base = i * bytesPerPixel;

    if (bytesPerPixel == 3) {
      scrambledImage.setPixelRgba(
        i % width,
        i ~/ width,
        scrambled[base],
        scrambled[base + 1],
        scrambled[base + 2],
        255,
      );
    } else if (bytesPerPixel == 4) {
      scrambledImage.setPixelRgba(
        i % width,
        i ~/ width,
        scrambled[base],
        scrambled[base + 1],
        scrambled[base + 2],
        scrambled[base + 3],
      );
    }
  }

  return scrambledImage;
}
