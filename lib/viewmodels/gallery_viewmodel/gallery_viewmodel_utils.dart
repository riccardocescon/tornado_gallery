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
