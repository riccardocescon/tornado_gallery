import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/injection_container.dart';

part 'gallery_page_bloc.freezed.dart';
part 'gallery_page_event.dart';
part 'gallery_page_state.dart';

class GalleryPageBloc extends Bloc<GalleryPageEvent, GalleryPageState> {
  List<GalleryImage> _images = [];
  final galleryBloc = getIt<GalleryBloc>();

  GalleryPageBloc() : super(const GalleryPageState.initial()) {
    on<_Setup>((event, emit) async {
      galleryBloc.state.maybeMap(
        loaded: (value) {
          _images = value.images;
          _emit(emit);
        },
        encrypted: (value) {
          emit(const GalleryPageState.encrypted());
        },
        orElse: () {},
      );

      await for (final galleryState in galleryBloc.stream) {
        galleryState.maybeMap(
          loaded: (value) {
            _images = value.images;
            _emit(emit);
          },
          encryptionFailure: (value) {
            emit(GalleryPageState.failure(message: value.failure.message));
          },
          permissionDenied: (value) {
            emit(
              GalleryPageState.failure(
                message: 'Permission denied to access gallery.',
              ),
            );
          },
          orElse: () {},
        );
      }
    });

    on<_PickFiles>((event, emit) async {
      galleryBloc.add(const GalleryEvent.pickFiles());
    });

    on<_EncryptImage>((event, emit) async {
      galleryBloc.add(
        GalleryEvent.encryptImage(
          image: event.image,
          password: event.password,
          path: event.path,
        ),
      );
    });

    on<_LoadNextPage>((event, emit) async {
      galleryBloc.add(const GalleryEvent.loadNextPage());
    });

    on<_DeleteImage>((event, emit) async {
      galleryBloc.add(GalleryEvent.deleteImage(image: event.image));
    });
  }

  void _emit(Emitter<GalleryPageState> emit) {
    emit(GalleryPageState.loaded(images: _images.toList()));
  }
}
