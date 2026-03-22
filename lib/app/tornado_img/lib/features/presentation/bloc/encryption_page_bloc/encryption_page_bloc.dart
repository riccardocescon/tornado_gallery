import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/injection_container.dart';
part 'encryption_page_bloc.freezed.dart';
part 'encryption_page_event.dart';
part 'encryption_page_state.dart';

class EncryptionPageBloc
    extends Bloc<EncryptionPageEvent, EncryptionPageState> {
  final images = <GalleryImage>[];

  String password = '';

  // Settings
  bool galleryVisible = false;
  String outputFolder = '';
  bool deleteOriginals = false;

  EncryptionPageBloc() : super(const EncryptionPageState.initial()) {
    on<_Setup>((event, emit) async {
      images.addAll(event.images);
      emit(EncryptionPageState.ui(images: images));

      outputFolder = await _getOutputFolderRoot();
      _emitSettings(emit);
    });
    on<_SetPassword>((event, emit) async {
      password = event.password;
    });
    on<_ToggleGalleryVisibility>((event, emit) async {
      galleryVisible = !galleryVisible;

      outputFolder = await _getOutputFolderRoot();
      _emitSettings(emit);
    });
    on<_ToggleDeleteOriginals>((event, emit) async {
      deleteOriginals = !deleteOriginals;
      _emitSettings(emit);
    });
    on<_Encrypt>((event, emit) async {
      emit(const EncryptionPageState.encrypting());

      if (password.isEmpty) {
        emit(
          const EncryptionPageState.failure(
            message: 'Password cannot be empty',
          ),
        );
        return;
      }

      final galleryBloc = getIt.get<GalleryBloc>();

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
            if (value.encrypted.length + value.failed.length == images.length) {
              return true;
            }
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

  void _emitSettings(Emitter<EncryptionPageState> emit) {
    emit(
      EncryptionPageState.settingsUi(
        galleryVisible: galleryVisible,
        outputFolder: outputFolder,
        deleteOriginals: deleteOriginals,
      ),
    );
  }

  Future<String> _getOutputFolderRoot() async {
    if (galleryVisible) {
      final root = await getExternalStorageDirectory();
      if (root != null) return '${root.path}/TornadoGallery';
    }

    final root = await getApplicationDocumentsDirectory();
    return '${root.path}/encrypted';
  }
}
