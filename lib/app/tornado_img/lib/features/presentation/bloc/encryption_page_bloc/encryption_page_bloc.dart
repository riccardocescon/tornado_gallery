import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/core/utils/providers.dart';
import 'package:tornado_img_app/features/domain/entities/archiving_state.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/injection_container.dart';
part 'encryption_page_bloc.freezed.dart';
part 'encryption_page_event.dart';
part 'encryption_page_state.dart';

class EncryptionPageBloc
    extends Bloc<EncryptionPageEvent, EncryptionPageState> {
  final images = <GalleryImage>[];

  String password = '';

  final AppBloc appBloc;
  final GalleryBloc galleryBloc;

  // Settings
  bool galleryVisible = false;
  String outputFolder = '';
  bool overrideImage = true;
  bool deleteOriginals = false;

  EncryptionPageBloc({required this.appBloc, required this.galleryBloc})
    : super(const EncryptionPageState.initial()) {
    on<_Setup>((event, emit) async {
      images.addAll(event.images);
      final size = images.first.file.lengthSync();
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
          size: sizeText,
          dateTime: dateTime.toString(),
        ),
      );

      outputFolder = await GalleryPathProvider.getOutputFolderRoot(
        galleryVisible: galleryVisible,
      );
      _emitSettings(emit);
    });
    on<_SetPassword>((event, emit) async {
      password = event.password;
    });
    on<_ToggleGalleryVisibility>((event, emit) async {
      galleryVisible = !galleryVisible;

      outputFolder = await GalleryPathProvider.getOutputFolderRoot(
        galleryVisible: galleryVisible,
      );
      _emitSettings(emit);
    });
    on<_SetOutputFolder>((event, emit) async {
      outputFolder = event.outputFolder;
      _emitSettings(emit);
    });
    on<_ToggleOverrideImage>((event, emit) async {
      overrideImage = !overrideImage;
      _emitSettings(emit);
    });
    on<_ToggleDeleteOriginals>((event, emit) async {
      deleteOriginals = !deleteOriginals;
      _emitSettings(emit);
    });
    on<_Encrypt>((event, emit) async {
      emit(
        EncryptionPageState.encrypting(
          archivingState: ArchivingState(
            totalImages: images.length,
            archivedImages: [],
            failedImages: [],
          ),
        ),
      );

      if (password.isEmpty) {
        emit(
          const EncryptionPageState.failure(
            message: 'Password cannot be empty',
          ),
        );
        return;
      }

      final archivedImages = <String>[];

      galleryBloc.add(
        GalleryEvent.encryptImages(
          images: images,
          password: password,
          path: outputFolder,
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
            if (state.archivedImages.length + state.failedImages.length ==
                state.totalImages) {
              return true;
            }

            emit(EncryptionPageState.encrypting(archivingState: state));
            return false;
          },
          encryptionFailure: (value) => true,
          orElse: () => false,
        );

        if (completed) break;
      }

      emit(EncryptionPageState.encrypted());
    });
  }

  void _syncNewArchivedImages(
    List<EncryptedImage> newlyArchived,
    List<String> alreadyArchivedImages,
  ) {
    final toUpdate =
        newlyArchived
            .where((img) => !alreadyArchivedImages.contains(img.name))
            .toList();
    for (final newArchive in toUpdate) {
      
      alreadyArchivedImages.add(newArchive.path);
      appBloc.add(AppEvent.addEncryptedImage(image: newArchive));
    }
  }

  void _emitSettings(Emitter<EncryptionPageState> emit) {
    emit(
      EncryptionPageState.settingsUi(
        galleryVisible: galleryVisible,
        outputFolder: outputFolder,
        overrideImage: overrideImage,
        deleteOriginals: deleteOriginals,
      ),
    );
  }
}
