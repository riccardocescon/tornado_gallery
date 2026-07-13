import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/purchase_bloc/purchase_bloc.dart';
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
  final PurchaseBloc purchaseBloc;

  EncryptionSettings settings = EncryptionSettings.init();

  /// Encrypting this selection would take a free user past the image cap.
  ///
  /// The UI disables the Encrypt button on this and offers Pro instead, so the
  /// user never reaches a dead end; the `_Encrypt` handler re-checks it because
  /// the archive can grow underneath an open encryption page.
  bool get exceedsFreeLimit {
    if (purchaseBloc.isPro) return false;
    return appBloc.encryptedImages.length + images.length >
        Constants.maxEncryptedImages;
  }

  EncryptionPageBloc({
    required this.appBloc,
    required this.galleryBloc,
    required this.purchaseBloc,
  }) : super(const EncryptionPageState.initial()) {
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
      // Validate before announcing any work: emitting `encrypting` first and
      // then failing flashes the progress UI for a frame.
      if (exceedsFreeLimit) {
        emit(const EncryptionPageState.limitReached());
        return;
      }

      if (password.isEmpty) {
        emit(
          const EncryptionPageState.failure(
            message: 'Password cannot be empty',
          ),
        );
        return;
      }

      emit(
        EncryptionPageState.encrypting(
          archivingState: ArchivingState.init(totalImages: images.length),
        ),
      );

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
    emit(EncryptionPageState.settingsUi(settings: settings));
  }
}
