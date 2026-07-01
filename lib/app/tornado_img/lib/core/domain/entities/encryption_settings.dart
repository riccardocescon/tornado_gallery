import 'package:equatable/equatable.dart';

class EncryptionSettings with EquatableMixin {
  final bool galleryVisible;

  /// Human-readable label of the chosen destination, shown in the UI subtitle.
  /// Not a filesystem path — resolve the actual path from the relative fields.
  final String outputFolder;

  /// Target private folder relative to the encrypted store root ('' = root).
  /// Only meaningful when [galleryVisible] is false. Resolved to an absolute
  /// path at save time via `GalleryPathProvider.getPrivateFolderPath`, so it
  /// stays consistent with the archive page (which is also relative-based).
  final String privateRelativeFolder;

  /// Target gallery folder relative to the public root album ('' = root album).
  /// Only meaningful when [galleryVisible] is true.
  final String publicRelativeAlbum;
  final bool overrideImage;
  final bool deleteOriginals;

  /// Absolute destination path for the encryption run. Null when the gallery is
  /// the target. Populated by `EncryptionPageBloc` just before dispatch, where
  /// [privateRelativeFolder] is resolved to an absolute path; the picker/state
  /// only ever track the relative folder, keeping it consistent with the
  /// archive page.
  String? get destinationPath => galleryVisible ? null : outputFolder;

  EncryptionSettings({
    required this.galleryVisible,
    required this.outputFolder,
    required this.privateRelativeFolder,
    required this.publicRelativeAlbum,
    required this.overrideImage,
    required this.deleteOriginals,
  });

  factory EncryptionSettings.init() {
    return EncryptionSettings(
      galleryVisible: false,
      outputFolder: '',
      privateRelativeFolder: '',
      publicRelativeAlbum: '',
      overrideImage: true,
      deleteOriginals: false,
    );
  }

  EncryptionSettings copyWith({
    bool? galleryVisible,
    String? outputFolder,
    String? privateRelativeFolder,
    String? publicRelativeAlbum,
    bool? overrideImage,
    bool? deleteOriginals,
  }) {
    return EncryptionSettings(
      galleryVisible: galleryVisible ?? this.galleryVisible,
      outputFolder: outputFolder ?? this.outputFolder,
      privateRelativeFolder:
          privateRelativeFolder ?? this.privateRelativeFolder,
      publicRelativeAlbum: publicRelativeAlbum ?? this.publicRelativeAlbum,
      overrideImage: overrideImage ?? this.overrideImage,
      deleteOriginals: deleteOriginals ?? this.deleteOriginals,
    );
  }

  @override
  List<Object?> get props => [
    galleryVisible,
    outputFolder,
    privateRelativeFolder,
    publicRelativeAlbum,
    overrideImage,
    deleteOriginals,
  ];
}
