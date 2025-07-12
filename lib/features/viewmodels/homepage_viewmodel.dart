import 'package:flutter/material.dart';
import 'package:tornado_img/features/viewmodels/encrypted_gallery_viewmodel.dart';
import 'package:tornado_img/features/viewmodels/gallery_viewmodel/gallery_viewmodel.dart';

class HomepageViewmodel extends ChangeNotifier {
  final _galleryViewModel = GalleryViewModel();
  final _encryptedGalleryViewModel = EncryptedGalleryViewModel(root: null);

  GalleryViewModel get galleryViewModel => _galleryViewModel;
  EncryptedGalleryViewModel get encryptedGalleryViewModel =>
      _encryptedGalleryViewModel;

  void _onChildChanged() {
    notifyListeners();
  }

  Future<void> init() async {
    await _galleryViewModel.init();
    await _encryptedGalleryViewModel.init();

    _galleryViewModel.addListener(_onChildChanged);
    _encryptedGalleryViewModel.addListener(_onChildChanged);

    notifyListeners();
  }

  @override
  void dispose() {
    _galleryViewModel.removeListener(_onChildChanged);
    _encryptedGalleryViewModel.removeListener(_onChildChanged);
    _galleryViewModel.dispose();
    _encryptedGalleryViewModel.dispose();
    super.dispose();
  }
}
