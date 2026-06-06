import 'package:equatable/equatable.dart';

class EncryptionSettings with EquatableMixin {
  final bool galleryVisible;
  final String outputFolder;
  final bool overrideImage;
  final bool deleteOriginals;

  String? get destinationPath => galleryVisible ? null : outputFolder;

  EncryptionSettings({
    required this.galleryVisible,
    required this.outputFolder,
    required this.overrideImage,
    required this.deleteOriginals,
  });

  factory EncryptionSettings.init() {
    return EncryptionSettings(
      galleryVisible: false,
      outputFolder: '',
      overrideImage: true,
      deleteOriginals: false,
    );
  }

  EncryptionSettings copyWith({
    bool? galleryVisible,
    String? outputFolder,
    bool? overrideImage,
    bool? deleteOriginals,
  }) {
    return EncryptionSettings(
      galleryVisible: galleryVisible ?? this.galleryVisible,
      outputFolder: outputFolder ?? this.outputFolder,
      overrideImage: overrideImage ?? this.overrideImage,
      deleteOriginals: deleteOriginals ?? this.deleteOriginals,
    );
  }

  @override
  List<Object?> get props => [
    galleryVisible,
    outputFolder,
    overrideImage,
    deleteOriginals,
  ];
}
