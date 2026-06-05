import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

/// Provides image picking from the system gallery via [AssetPicker].
class PicturesProvider {
  PicturesProvider._();

  static Future<Either<String?, List<AssetEntity>>> pickImagesFromGallery(
    BuildContext context,
  ) async {
    final permissionState = await PhotoManager.requestPermissionExtend();
    if (!context.mounted) return const Left(null);
    if (!permissionState.isAuth && !permissionState.isLimited) {
      return const Left('Permission to access photos was denied');
    }

    final assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(
        requestType: RequestType.image,
        maxAssets: 100,
      ),
    );
    if (!context.mounted) return const Left(null);
    if (assets?.isEmpty ?? true) {
      return const Left('No images selected');
    }

    return Right(assets!);
  }
}
