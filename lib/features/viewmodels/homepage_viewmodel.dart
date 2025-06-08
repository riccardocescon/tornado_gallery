import 'package:flutter/material.dart';
import 'package:tornado_img/features/viewmodels/encrypted_gallery_viewmodel.dart';
import 'package:tornado_img/features/viewmodels/gallery_viewmodel/gallery_viewmodel.dart';

class HomepageViewmodel extends ChangeNotifier {
  final _galleryViewModel = GalleryViewModel();
  final _encryptedGalleryViewModel = EncryptedGalleryViewModel();

  GalleryViewModel get galleryViewModel => _galleryViewModel;
  EncryptedGalleryViewModel get encryptedGalleryViewModel =>
      _encryptedGalleryViewModel;

  Future<void> init() async {
    await _galleryViewModel.init();
    await _encryptedGalleryViewModel.init();
    notifyListeners();
  }
}
