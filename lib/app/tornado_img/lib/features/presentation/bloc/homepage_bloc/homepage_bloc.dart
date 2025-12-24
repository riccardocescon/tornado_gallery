import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/managers/stream_manager.dart';
import 'package:tornado_img_app/core/presentation/bloc/encrypted_gallery_bloc/encrypted_gallery_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/injection_container.dart';
import 'package:rxdart/rxdart.dart';

part 'homepage_bloc.freezed.dart';
part 'homepage_event.dart';
part 'homepage_state.dart';

class HomepageBloc extends Bloc<HomepageEvent, HomepageState> {
  StreamManager? _streamManager;

  @override
  Future<void> close() {
    _streamManager?.dispose();
    return super.close();
  }

  HomepageBloc() : super(const HomepageState.initial()) {
    on<_Setup>((event, emit) async {
      final galleryBloc = getIt<GalleryBloc>();
      final encryptedGalleryBloc = getIt<EncryptedGalleryBloc>();

      galleryBloc.add(const GalleryEvent.setup());
      encryptedGalleryBloc.add(const EncryptedGalleryEvent.setup());
      List<GalleryImage>? images;
      List<EncryptedImage>? latestEncryptedImages;

      final mergeStream = Rx.combineLatest2(
        galleryBloc.stream,
        encryptedGalleryBloc.stream,
        (galleryState, encyrptedState) {
          final galleryImages = galleryState.maybeMap(
            loaded: (value) {
              images = value.images;
              return images;
            },
            orElse: () => null,
          );

          final encryptedImages = encyrptedState.maybeMap(
            loaded: (value) {
              latestEncryptedImages = value.images;
              return latestEncryptedImages;
            },
            orElse: () => null,
          );

          emit(
            HomepageState.loaded(
              images: galleryImages ?? images,
              encryptedImages: encryptedImages ?? latestEncryptedImages,
            ),
          );
        },
      );

      _streamManager?.addStream(mergeStream);

      await for (final _ in mergeStream) {
      }

      await _streamManager?.dispose();
      _streamManager = null;
    });
  }
}
