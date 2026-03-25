import 'package:equatable/equatable.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';

class ArchivingState with EquatableMixin {
  final int totalImages;
  final List<GalleryImage> archivedImages;
  final List<GalleryImage> failedImages;

  ArchivingState({
    required this.totalImages,
    required this.archivedImages,
    required this.failedImages,
  });

  @override
  List<Object?> get props => [totalImages, archivedImages, failedImages];
}
