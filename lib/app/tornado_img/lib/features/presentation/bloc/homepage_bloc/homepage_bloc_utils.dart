part of 'homepage_bloc.dart';

sealed class _HomepageStream {}

class _FolderStream extends _HomepageStream {
  final EncryptedFolder privateFolder;
  final EncryptedFolder? publicFolder;

  _FolderStream({required this.privateFolder, this.publicFolder});
}

class _GalleryStream extends _HomepageStream {
  final GalleryState galleryState;

  _GalleryStream(this.galleryState);
}

class _AppStream extends _HomepageStream {
  final AppState appState;

  _AppStream(this.appState);
}
