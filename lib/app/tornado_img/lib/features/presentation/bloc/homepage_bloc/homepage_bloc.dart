import 'dart:io';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tornado_img_app/core/managers/stream_manager.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_entity.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/features/presentation/bloc/gallery_page_bloc/gallery_page_bloc.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/injection_container.dart';

part 'homepage_bloc.freezed.dart';
part 'homepage_event.dart';
part 'homepage_state.dart';
part 'homepage_bloc_utils.dart';

class HomepageBloc extends Bloc<HomepageEvent, HomepageState> {
  StreamManager? _streamManager;

final _HomepageBlocUtils _utils = _HomepageBlocUtils();

  @override
  Future<void> close() {
    _streamManager?.dispose();
    return super.close();
  }

  HomepageBloc() : super(const HomepageState.initial()) {
    on<_Setup>((event, emit) async {
      final galleryPageBloc = getIt<GalleryPageBloc>();

      galleryPageBloc.add(const GalleryPageEvent.setup());

      // Load latest encrypted images directly
      final latestEncryptedImages = await _utils.loadLatestEncryptedImages(
        limit: 3,
      );
      
      List<GalleryImage>? images;

      final galleryStream = galleryPageBloc.stream.map((galleryPageState) {
        return galleryPageState.maybeMap(
          loaded: (value) {
            images = value.images;
            return HomepageState.loaded(
              images: images,
              encryptedImages: latestEncryptedImages,
            );
          },
          orElse:
              () => HomepageState.loaded(
                images: images,
                encryptedImages: latestEncryptedImages,
              ),
        );
      });

      _streamManager?.addStream(galleryStream);

      await for (final state in galleryStream) {
        emit(state);
      }

      await _streamManager?.dispose();
      _streamManager = null;
    });
  }
}
