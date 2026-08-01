import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:tornado_img_app/core/utils/picture_provider/selection_picker.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

/// Provides image and video picking from the system gallery via [AssetPicker].
class PicturesProvider {
  PicturesProvider._();

  static Future<Either<String?, List<AssetEntity>>> pickMediaFromGallery(
    BuildContext context,
  ) async {
    final permissionState = await PhotoManager.requestPermissionExtend();
    if (!context.mounted) return const Left(null);
    if (!permissionState.isAuth && !permissionState.isLimited) {
      return const Left('Permission to access photos was denied');
    }

    final provider = DefaultAssetPickerProvider(
      // TODO(monetization): make conditional on Pro status —
      // `purchaseBloc.isPro ? RequestType.common : RequestType.image`. Free
      // users should keep the image-only picker; video selection is a Pro
      // feature.
      requestType: RequestType.common,
      maxAssets: 100,
    );

    final delegate = TapToSelectPickerDelegate(
      provider: provider,
      initialPermission: permissionState,
      gridCount: 3,
      themeColor: context.colorScheme.tertiary,
      locale: Localizations.localeOf(context),
    );

    final List<AssetEntity>? assets = await AssetPicker.pickAssetsWithDelegate<
      AssetEntity,
      AssetPathEntity,
      DefaultAssetPickerProvider,
      TapToSelectPickerDelegate
    >(context, delegate: delegate);

    if (!context.mounted) return const Left(null);
    if (assets?.isEmpty ?? true) {
      return const Left(null);
    }

    return Right(assets!);
  }
}
