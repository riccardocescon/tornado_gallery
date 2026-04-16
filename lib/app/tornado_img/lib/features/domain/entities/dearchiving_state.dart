import 'package:equatable/equatable.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';

enum DearchivingStateType { loading, dearchived, failure }

class DearchivingState with EquatableMixin {
  final int totalImages;
  final List<EncryptedImage> loadingImages;
  final List<EncryptedImage> dearchivedImages;
  final List<EncryptedImage> failedImages;

  int get progress => failedImages.length + dearchivedImages.length;

  List<EncryptedImage> get allImages => [
    ...loadingImages,
    ...dearchivedImages,
    ...failedImages,
  ];

  DearchivingStateType getState(String path) {
    if (loadingImages.any((e) => e.file.path == path)) {
      return DearchivingStateType.loading;
    }
    if (dearchivedImages.any((e) => e.file.path == path)) {
      return DearchivingStateType.dearchived;
    }

    return DearchivingStateType.failure;
  }

  DearchivingState({
    required this.totalImages,
    required this.loadingImages,
    required this.dearchivedImages,
    required this.failedImages,
  });

  @override
  List<Object?> get props => [
    totalImages,
    loadingImages,
    dearchivedImages,
    failedImages,
  ];
}
