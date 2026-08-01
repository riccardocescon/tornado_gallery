import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_image_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/encrypt_image_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/encrypt_video_usecase.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/core/domain/entities/archiving_state.dart';
import 'package:tornado_img_app/core/domain/entities/dearchiving_state.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/entities/encryption_settings.dart';
import 'package:tornado_img_app/core/domain/entities/gallery_image.dart';

part 'gallery_bloc.freezed.dart';
part 'gallery_event.dart';
part 'gallery_state.dart';

/// Fetches the poster thumbnail bytes for a video asset by id. Real runs use
/// [_defaultVideoPosterFetcher] (a `photo_manager` platform-channel call);
/// tests inject a fake so [GalleryBloc]'s routing logic stays testable
/// without a device — same reasoning as why [EncryptVideoParams] takes
/// `posterBytes` instead of resolving the asset itself.
typedef VideoPosterFetcher = Future<Uint8List?> Function(String assetId);

Future<Uint8List?> _defaultVideoPosterFetcher(String assetId) async {
  final asset = await AssetEntity.fromId(assetId);
  if (asset == null) return null;
  return asset.thumbnailDataWithSize(const ThumbnailSize(720, 720));
}

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final EncryptImageUseCase encryptUseCase;
  final EncryptVideoUseCase encryptVideoUseCase;
  final DecryptImageUseCase decryptUseCase;

  final AppBloc appBloc;
  final VideoPosterFetcher _fetchVideoPoster;

  GalleryBloc({
    required this.encryptUseCase,
    required this.encryptVideoUseCase,
    required this.decryptUseCase,
    required this.appBloc,
    VideoPosterFetcher fetchVideoPoster = _defaultVideoPosterFetcher,
  }) : _fetchVideoPoster = fetchVideoPoster,
       super(const GalleryState.initial()) {
    on<_EncryptImages>(_onEncryptImages);
    on<_DecryptImages>(_onDecryptImages);
  }

  Future<void> _onEncryptImages(
    _EncryptImages event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryState.loadingEncryption(total: event.images.length));

    final encrypted = <EncryptedImage>[];
    final failed = <GalleryImage>[];
    final skippedImages = <GalleryImage>[];

    for (final entry in event.images.entries) {
      final image = entry.key;
      final filename = entry.value;
      final isVideo = image.isVideo;

      final skipped = _isSkipped(
        event.settings.overrideImage,
        event.settings.destinationPath,
        image.id,
        isVideo ? 'mp4' : 'png',
      );

      if (skipped) {
        skippedImages.add(image);
        appLogger.log(
          'Encryption skipped for ${image.file.path}: File already exists and override is disabled',
          LogLayer.bloc,
        );
      } else if (isVideo) {
        // TODO(monetization): gate here — if !purchaseBloc.isPro, skip the
        // encryptVideoUseCase call below, add `image` to `failed` (or a new
        // "requires Pro" bucket the UI can special-case) and emit a
        // paywall-offer signal instead of silently proceeding. This is the
        // per-asset dispatch point the Pro gate needs to intercept.
        final posterBytes = await _fetchVideoPoster(image.id);
        if (posterBytes == null) {
          failed.add(image);
          appLogger.log(
            'Video encryption failed for ${image.file.path}: could not read a poster thumbnail (corrupt or cloud-only asset?)',
            LogLayer.bloc,
          );
        } else {
          final result = await encryptVideoUseCase.call(
            EncryptVideoParams(
              file: image.file,
              password: event.password,
              fileId: filename ?? image.id,
              posterBytes: posterBytes,
              destinationPath: event.settings.destinationPath,
              // Gallery-visible videos go to the public album on Android only.
              // iOS stays private for v1: its public paths are virtual, which
              // playback can't open, and it is unverified whether PhotoKit
              // preserves our custom `uuid` boxes when re-importing an mp4 —
              // if it re-encodes, the ciphertext is gone. When galleryVisible
              // is true destinationPath is null, which EncryptVideoUseCase
              // already resolves to the private root.
              publicRelativeAlbum:
                  event.settings.galleryVisible && Platform.isAndroid
                      ? event.settings.publicRelativeAlbum
                      : null,
            ),
          );

          result.fold(
            (error) {
              failed.add(image);
              appLogger.log(
                'Video encryption failed for ${image.file.path}',
                LogLayer.bloc,
                error: error.message,
              );
            },
            (encryptedImage) {
              encrypted.add(encryptedImage);
              appBloc.add(AppEvent.addEncryptedImage(image: encryptedImage));
            },
          );
        }
      } else {
        final result = await encryptUseCase.call(
          EncryptImageParams(
            file: image.file,
            password: event.password,
            fileId: filename ?? image.id,
            settings: event.settings,
            assetId: image.id,
          ),
        );

        result.fold(
          (error) {
            failed.add(image);
            appLogger.log(
              'Encryption failed for ${image.file.path}',
              LogLayer.bloc,
              error: error.message,
            );
          },
          (encryptedImage) {
            encrypted.add(encryptedImage);
            appBloc.add(AppEvent.addEncryptedImage(image: encryptedImage));
          },
        );
      }

      final archivingState = ArchivingState(
        archivedImages: List<EncryptedImage>.from(encrypted),
        failedImages: List<GalleryImage>.from(failed),
        skippedImages: List<GalleryImage>.from(skippedImages),
        totalImages: event.images.length,
      );
      emit(GalleryState.encrypted(archivingState: archivingState));
    }
  }

  Future<void> _onDecryptImages(
    _DecryptImages event,
    Emitter<GalleryState> emit,
  ) async {
    // Videos never go through the image pipeline: their file is mostly
    // ciphertext and may be gigabytes, and playback owns that path
    // (VideoPlayerPage → DecryptVideoUseCase). Dropping them here keeps a
    // future bulk-decrypt caller from reading one whole into memory.
    final images = event.image.where((e) => !e.isVideo).toList();
    final totalImages = images.length;
    emit(GalleryState.loadingDecryption(total: totalImages));

    final loading = images.where((e) => e.decryptInfo == null).toList();
    final dearchived = images.where((e) => e.decryptInfo != null).toList();
    final failed = <EncryptedImage>[];

    emit(
      GalleryState.decrypted(
        dearchivingState: DearchivingState(
          totalImages: totalImages,
          loadingImages: loading.toList(),
          dearchivedImages: dearchived.toList(),
          failedImages: failed.toList(),
        ),
      ),
    );

    for (final image in images) {
      final result = await decryptUseCase.call(
        DecryptImageParams(
          file: image.storagePath.file,
          password: event.password,
          assetId: image.storagePath.assetId,
        ),
      );

      loading.remove(image);

      if (result.isLeft()) {
        failed.add(image);
      } else {
        final updatedImage = image.copyWith(decryptInfo: result.right);
        dearchived.add(updatedImage);
        appBloc.add(
          AppEvent.setDecryptedInfo(
            path: updatedImage.storagePath.path,
            decryptedInfo: result.right,
          ),
        );
      }

      emit(
        GalleryState.decrypted(
          dearchivingState: DearchivingState(
            totalImages: totalImages,
            loadingImages: loading.toList(),
            dearchivedImages: dearchived.toList(),
            failedImages: failed.toList(),
          ),
        ),
      );
    }
  }

  /// [extension] is the output file's extension without the dot — `png` for
  /// images, `mp4` for videos (the cosmetic wrapper is always `.mp4`
  /// regardless of the source container).
  bool _isSkipped(
    bool overrideImage,
    String? destinationPath,
    String imageId,
    String extension,
  ) {
    if (overrideImage) return false;
    if (destinationPath == null || destinationPath.isEmpty) return false;

    final safeStem = FileNameUtils.sanitizeFileStem(imageId);

    final encryptedImages = appBloc.encryptedImages;
    final exists = encryptedImages.any(
      (img) =>
          img.storagePath.file.path == '$destinationPath/$safeStem.$extension',
    );
    return exists;
  }
}
