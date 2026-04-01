import 'package:equatable/equatable.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';

class DearchivingState with EquatableMixin {
  final int totalImages;
  final List<GalleryImage> dearchivedImages;
  final List<GalleryImage> failedImages;

  DearchivingState({
    required this.totalImages,
    required this.dearchivedImages,
    required this.failedImages,
  });

  @override
  List<Object?> get props => [totalImages, dearchivedImages, failedImages];
}
