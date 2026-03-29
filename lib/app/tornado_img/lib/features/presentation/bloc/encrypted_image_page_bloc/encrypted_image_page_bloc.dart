import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/injection_container.dart';

part 'encrypted_image_page_bloc.freezed.dart';
part 'encrypted_image_page_event.dart';
part 'encrypted_image_page_state.dart';

class EncryptedImagePageBloc
    extends Bloc<EncryptedImagePageEvent, EncryptedImagePageState> {
  EncryptedImagePageBloc() : super(const EncryptedImagePageState.initial()) {
    on<_Setup>((event, emit) async {
      emit(const EncryptedImagePageState.loading());

      final appBloc = getIt<AppBloc>();
      final image = appBloc.encryptedImages.firstWhere(
        (img) => img.file.path == event.imagePath,
      );

      emit(EncryptedImagePageState.ui(image: image));
    });
  }
}
