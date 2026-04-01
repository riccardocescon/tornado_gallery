import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';

part 'encrypted_image_page_bloc.freezed.dart';
part 'encrypted_image_page_event.dart';
part 'encrypted_image_page_state.dart';

class EncryptedImagePageBloc
    extends Bloc<EncryptedImagePageEvent, EncryptedImagePageState> {
  String password = '';
  late GalleryImage image;

  late AppBloc appBloc;
  late GalleryBloc galleryBloc;

  EncryptedImagePageBloc({required this.appBloc, required this.galleryBloc})
    : super(const EncryptedImagePageState.initial()) {
    on<_Setup>((event, emit) async {
      emit(const EncryptedImagePageState.loading());

      image = appBloc.encryptedImages.firstWhere(
        (img) => img.file.path == event.imagePath,
      );

      emit(EncryptedImagePageState.ui(image: image));
    });
    on<_UpdatePassword>((event, emit) => password = event.password);
    on<_Decrypt>((event, emit) async {
      emit(const EncryptedImagePageState.loading());

      if (password.isEmpty) {
        emit(
          const EncryptedImagePageState.failure(
            message: 'Password cannot be empty',
          ),
        );
        return;
      }

      galleryBloc.add(
        GalleryEvent.decryptImage(image: image, password: password),
      );

      await for (final state in galleryBloc.stream) {
        final completed = state.maybeMap(
          decrypted: (value) {
            final decryptedImage = value.archivingState.dearchivedImages
                .firstWhereOrNull((e) => e.file.path == image.file.path);
            if (decryptedImage != null) {
              emit(EncryptedImagePageState.ui(image: decryptedImage));
            }
            return decryptedImage != null;
          },
          decryptionFailure: (value) {
            emit(
              EncryptedImagePageState.failure(message: value.failure.message),
            );
            return true;
          },
          orElse: () => false,
        );

        if (completed) break;
      }
      
    });
  }
}
