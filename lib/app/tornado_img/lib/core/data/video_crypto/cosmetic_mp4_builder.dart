// Builds the "cosmetic" mp4 that Task 4 embeds real ciphertext behind: a
// silent ~3 s clip of a single scrambled poster frame. The scrambling itself
// is not reimplemented here — it's the exact pipeline `EncryptImageUseCase`
// uses via [ImageProcessingRepository]. This file only turns the resulting
// scrambled PNG into a tiny playable video.

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

/// Rounds odd dimensions up to the next even number. H.264 encoders
/// (including the native ones behind `flutter_quick_video_encoder`) require
/// even width/height; even inputs pass through unchanged.
(int, int) evenDimensions(int w, int h) =>
    (w.isOdd ? w + 1 : w, h.isOdd ? h + 1 : h);

/// Builds a silent, ~3 s mp4 showing a single scrambled poster frame.
///
/// Binding constraints from the video-encryption plan: one scrambled frame,
/// ~3 s at 5 fps, max 720 px on the long side, no audio track.
class CosmeticMp4Builder {
  CosmeticMp4Builder({required ImageProcessingRepository imageRepo})
    : _imageRepo = imageRepo;

  final ImageProcessingRepository _imageRepo;

  static const int _fps = 5;
  static const int _frameCount = 15; // 15 frames @ 5 fps == 3s
  static const int _maxLongSide = 720;
  static const int _videoBitrate = 1000000;

  /// Scrambles [posterBytes] through the app's image pipeline
  /// (`decodeBytes` → `encrypt` → `encode`) and encodes the result as a
  /// silent mp4.
  ///
  /// [posterBytes]: jpeg/png thumbnail of the source video (max 720 px long
  /// side). A larger poster is downscaled here rather than trusted — the 720
  /// cap is a binding constraint of the plan, not just a caller convention.
  ///
  /// Throws a [StateError] if the poster can't be decoded or the scrambling
  /// pipeline produces no output. Task 4 wraps this call in `guardEither`,
  /// which turns the exception into a `Left`.
  Future<Uint8List> build({
    required Uint8List posterBytes,
    required String password,
  }) async {
    final decoded = await _imageRepo.decodeBytes(
      posterBytes,
      extension: 'jpg',
    );
    if (decoded == null) {
      throw StateError('CosmeticMp4Builder: could not decode poster bytes');
    }

    final scrambled = await _imageRepo.encrypt(decoded, password);
    final encodedPng = await _imageRepo.encode(scrambled);
    if (encodedPng == null) {
      throw StateError(
        'CosmeticMp4Builder: scrambling pipeline produced no output',
      );
    }

    var frame = img.decodePng(encodedPng);
    if (frame == null) {
      throw StateError(
        'CosmeticMp4Builder: could not decode scrambled poster PNG',
      );
    }

    frame = _downscaleIfOversize(frame);

    final (w, h) = evenDimensions(frame.width, frame.height);
    if (w != frame.width || h != frame.height) {
      frame = img.copyExpandCanvas(
        frame,
        newWidth: w,
        newHeight: h,
        position: img.ExpandCanvasPosition.topLeft,
        backgroundColor: img.ColorRgb8(0, 0, 0),
      );
    }

    final rgba = frame.getBytes(order: img.ChannelOrder.rgba);
    final outPath = await _newTempPath();

    try {
      await FlutterQuickVideoEncoder.setup(
        width: w,
        height: h,
        fps: _fps,
        videoBitrate: _videoBitrate,
        profileLevel: ProfileLevel.any,
        // No audio track: zero out every audio param instead of calling
        // appendAudioFrame.
        audioChannels: 0,
        audioBitrate: 0,
        sampleRate: 0,
        filepath: outPath,
      );

      for (var i = 0; i < _frameCount; i++) {
        await FlutterQuickVideoEncoder.appendVideoFrame(rgba);
      }

      await FlutterQuickVideoEncoder.finish();

      return await File(outPath).readAsBytes();
    } finally {
      final f = File(outPath);
      if (await f.exists()) await f.delete();
    }
  }

  img.Image _downscaleIfOversize(img.Image image) {
    final longSide = image.width > image.height ? image.width : image.height;
    if (longSide <= _maxLongSide) return image;

    appLogger.log(
      'CosmeticMp4Builder: poster exceeds ${_maxLongSide}px long side '
      '(${image.width}x${image.height}) — downscaling',
      LogLayer.repository,
    );

    return image.width >= image.height
        ? img.copyResize(image, width: _maxLongSide)
        : img.copyResize(image, height: _maxLongSide);
  }

  Future<String> _newTempPath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/cosmetic_${DateTime.now().microsecondsSinceEpoch}.mp4';
  }
}
