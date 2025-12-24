import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/presentation/bloc/encrypted_gallery_bloc/encrypted_gallery_bloc.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/injection_container.dart';

part 'encrypted_gallery_page_event.dart';
part 'encrypted_gallery_page_state.dart';
part 'encrypted_gallery_page_bloc.freezed.dart';

class EncrpytedGalleryPageBloc
    extends Bloc<EncrpytedGalleryPageEvent, EncrpytedGalleryPageState> {
  List<EncryptedImage> _images = [];
  final encryptedGalleryBloc = getIt<EncryptedGalleryBloc>();
  String? get root => encryptedGalleryBloc.root;

  EncrpytedGalleryPageBloc()
    : super(const EncrpytedGalleryPageState.initial()) {
    on<_Setup>((event, emit) async {
      _images = encryptedGalleryBloc.images;
      _emit(emit);

      await for (final galleryState in encryptedGalleryBloc.stream) {
        galleryState.maybeMap(
          loaded: (value) {
            _images = value.images;
            _emit(emit);
          },
          decrypted: (value) {
            emit(EncrpytedGalleryPageState.decrypted(data: value.data));
          },
          encryptionFailure: (value) {
            emit(
              EncrpytedGalleryPageState.failure(message: value.failure.message),
            );
          },
          permissionDenied: (value) {
            emit(
              EncrpytedGalleryPageState.failure(
                message: 'Permission denied to access gallery.',
              ),
            );
          },
          orElse: () {},
        );
      }
    });

    on<_DecryptImage>((event, emit) async {
      emit(EncrpytedGalleryPageState.loading());
      encryptedGalleryBloc.add(
        EncryptedGalleryEvent.decrytImage(
          image: event.image,
          password: event.password,
          path: event.path,
        ),
      );
    });

    on<_DecryptFolder>((event, emit) async {
      emit(EncrpytedGalleryPageState.loading());
      encryptedGalleryBloc.add(
        EncryptedGalleryEvent.decrytFolder(password: event.password),
      );
    });

    on<_DeleteFolder>((event, emit) async {
      emit(EncrpytedGalleryPageState.loading());
      encryptedGalleryBloc.add(EncryptedGalleryEvent.deleteFolder());
    });

    on<_DeleteImage>((event, emit) async {
      emit(EncrpytedGalleryPageState.loading());
      encryptedGalleryBloc.add(
        EncryptedGalleryEvent.deleteImage(image: event.image),
      );
    });

    on<_CreateFolder>((event, emit) async {
      emit(EncrpytedGalleryPageState.loading());
      encryptedGalleryBloc.add(
        EncryptedGalleryEvent.createFolder(folderName: event.folderName),
      );
    });
  }

  void _emit(Emitter<EncrpytedGalleryPageState> emit) {
    emit(
      EncrpytedGalleryPageState.loaded(
        images: List<EncryptedImage>.from(_images),
      ),
    );
  }
}
