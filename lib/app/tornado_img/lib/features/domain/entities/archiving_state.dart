import 'package:equatable/equatable.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';

class ArchivingState with EquatableMixin {
  final int totalImages;
  final List<EncryptedImage> archivedImages;
  final List<GalleryImage> failedImages;
  final List<GalleryImage> skippedImages;

  int get progress =>
      archivedImages.length + failedImages.length + skippedImages.length;

  ArchivingState({
    required this.totalImages,
    required this.archivedImages,
    required this.failedImages,
    required this.skippedImages,
  });

  factory ArchivingState.init({required int totalImages}) {
    return ArchivingState(
      totalImages: totalImages,
      archivedImages: [],
      failedImages: [],
      skippedImages: [],
    );
  }

  @override
  List<Object?> get props => [
    totalImages,
    archivedImages,
    failedImages,
    skippedImages,
  ];
}
