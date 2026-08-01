import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/gallery_path_provider.dart';
import 'package:tornado_img_app/core/domain/entities/archiving_state.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/entities/encryption_settings.dart';
import 'package:tornado_img_app/core/domain/entities/gallery_image.dart';
part 'encryption_page_bloc.freezed.dart';
part 'encryption_page_event.dart';
part 'encryption_page_state.dart';

class EncryptionPageBloc
    extends Bloc<EncryptionPageEvent, EncryptionPageState> {
  final images = <GalleryImage>[];

  String password = '';
  Map<int, String> fileNames = {};
  int selectedImageIndex = 0;

  final AppBloc appBloc;
  final GalleryBloc galleryBloc;

  EncryptionSettings settings = EncryptionSettings.init();

  EncryptionPageBloc({required this.appBloc, required this.galleryBloc})
    : super(const EncryptionPageState.initial()) {
    on<_Setup>((event, emit) async {
      images.addAll(event.images);
      for (int i = 0; i < images.length; i++) {
        fileNames[i] = images[i].file.path.split('/').last.split('.').first;
      }

      // Preload data as soon as they are available
      _emitImageData(emit);

      settings = settings.copyWith(
        privateRelativeFolder: '',
        outputFolder:
            settings.galleryVisible ? 'Device Gallery' : _privateLabel(''),
      );
      _emitSettings(emit);
    });
    on<_SetPassword>((event, emit) async {
      password = event.password;
    });
    on<_SetFileName>((event, emit) async {
      fileNames[selectedImageIndex] = event.name;
      _emitImageData(emit);
    });
    on<_ToggleGalleryVisibility>((event, emit) async {
      final newGalleryVisible = !settings.galleryVisible;
      settings = settings.copyWith(
        galleryVisible: newGalleryVisible,
        privateRelativeFolder: '',
        publicRelativeAlbum: '',
        outputFolder: newGalleryVisible ? 'Device Gallery' : _privateLabel(''),
      );
      _emitSettings(emit);
    });
    on<_SetOutputFolder>((event, emit) async {
      settings = settings.copyWith(
        privateRelativeFolder: event.relative,
        outputFolder: event.label,
      );
      _emitSettings(emit);
    });
    on<_SetPublicAlbum>((event, emit) async {
      settings = settings.copyWith(
        publicRelativeAlbum: event.relative,
        outputFolder: event.label,
      );
      _emitSettings(emit);
    });
    on<_ToggleOverrideImage>((event, emit) async {
      settings = settings.copyWith(overrideImage: !settings.overrideImage);
      _emitSettings(emit);
    });
    on<_ToggleDeleteOriginals>((event, emit) async {
      settings = settings.copyWith(deleteOriginals: !settings.deleteOriginals);
      _emitSettings(emit);
    });
    on<_SelectImage>((event, emit) async {
      selectedImageIndex = event.index;
      _emitImageData(emit);
    });
    on<_Encrypt>((event, emit) async {
      emit(
        EncryptionPageState.encrypting(
          archivingState: ArchivingState.init(
            totalImages: images.length,
          ),
        ),
      );


      final totalEncrytped = appBloc.encryptedImages.length + images.length;
      if (totalEncrytped > Constants.maxEncryptedImages) {
        emit(
          const EncryptionPageState.failure(
            message:
                'Encryption limit reached. Please delete some encrypted images to continue.',
          ),
        );
        return;
      }

      // TODO(monetization): before dispatching, check whether `images`
      // contains a video (GalleryImage.isVideo / Constants.videoExtensions)
      // and !purchaseBloc.isPro; if so, emit a paywall-offer failure/state
      // here instead of proceeding — same early-return shape as the
      // encryption-limit check above. The actual per-asset video dispatch
      // this gate needs to guard lives in GalleryBloc._onEncryptImages
      // (core/presentation/bloc/gallery_bloc/gallery_bloc.dart), not here —
      // this bloc only forwards the whole batch via GalleryEvent.encryptImages.
      if (password.isEmpty) {
        emit(
          const EncryptionPageState.failure(
            message: 'Password cannot be empty',
          ),
        );
        return;
      }

      final archivedImages = <String>[];

      // Resolve the relative private folder to an absolute destination for this
      // run only. State keeps the relative path (consistent with the archive
      // page); the absolute path is materialised fresh here so it never goes
      // stale (e.g. iOS container path changes between launches).
      final runSettings =
          settings.galleryVisible
              ? settings
              : settings.copyWith(
                outputFolder: await GalleryPathProvider.getPrivateFolderPath(
                  relative: settings.privateRelativeFolder,
                ),
              );

      galleryBloc.add(
        GalleryEvent.encryptImages(
          images: Map.fromEntries(
            images.map(
              (galleryImage) => MapEntry(
                galleryImage,
                fileNames[images.indexOf(galleryImage)],
              ),
            ),
          ),
          password: password,
          settings: runSettings,
        ),
      );
      await for (final state in galleryBloc.stream) {
        final completed = state.maybeMap(
          encrypted: (value) {

            _syncNewArchivedImages(
              value.archivingState.archivedImages,
              archivedImages,
            );

            final state = value.archivingState;
            emit(EncryptionPageState.encrypting(archivingState: state));

            final elaboratedImages = state.progress;

            final encryptedEverything = elaboratedImages == state.totalImages;
            return encryptedEverything;
          },
          orElse: () => false,
        );

        if (completed) break;
      }

      emit(EncryptionPageState.encrypted());
    });
  }

  /// UI label for a private destination identified by its [relative] path.
  String _privateLabel(String relative) =>
      relative.isEmpty ? 'Root (encrypted)' : relative;

  void _syncNewArchivedImages(
    List<EncryptedImage> newlyArchived,
    List<String> alreadyArchivedImages,
  ) {
    final toUpdate =
        newlyArchived
            .where((img) => !alreadyArchivedImages.contains(img.name))
            .toList();
    for (final newArchive in toUpdate) {
      
      alreadyArchivedImages.add(newArchive.storagePath.path);
      appBloc.add(AppEvent.addEncryptedImage(image: newArchive));
    }
  }

  void _emitImageData(Emitter<EncryptionPageState> emit) {
    final size = images[selectedImageIndex].file.lengthSync();
    String sizeText;
    if (size < 1024 * 1024) {
      final sizeInKB = size / 1024;
      sizeText = '${sizeInKB.toStringAsFixed(2)} KB';
    } else {
      final sizeInMB = size / (1024 * 1024);
      sizeText = '${sizeInMB.toStringAsFixed(2)} MB';
    }

    final dateTime = DateFormat(
      "dd MM yyyy",
    ).format(images.first.file.lastModifiedSync());
    emit(
      EncryptionPageState.ui(
        images: images,
        fileName: fileNames[selectedImageIndex]!,
        size: sizeText,
        dateTime: dateTime.toString(),
      ),
    );
  }

  void _emitSettings(Emitter<EncryptionPageState> emit) {
    emit(
      EncryptionPageState.settingsUi(
        settings: settings
      ),
    );
  }
}
