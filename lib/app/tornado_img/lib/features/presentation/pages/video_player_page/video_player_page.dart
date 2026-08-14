import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_video_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_renamer_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/video_saver_usecase.dart';
import 'package:tornado_img_app/core/managers/decrypted_video_cache.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/pages/fullscreen_media_viewer/fullscreen_media_viewer.dart';
import 'package:tornado_img_app/core/presentation/widgets/option_item.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/presentation/widgets/contained_item.dart';
import 'package:tornado_img_app/features/presentation/widgets/page_background.dart';
import 'package:tornado_img_app/features/presentation/widgets/password_form_field.dart';
import 'package:tornado_img_app/features/presentation/widgets/rename_bottom_sheet.dart';
import 'package:tornado_img_app/injection_container.dart';
import 'package:video_player/video_player.dart';

part 'widgets/preview.dart';
part 'widgets/info.dart';
part 'widgets/actions.dart';

/// `extra` payload of the `videoPlayer` route: the tapped video plus the archive
/// level it came from, in display order, so the fullscreen viewer can page.
typedef VideoPlayerArgs =
    ({EncryptedImage image, List<EncryptedImage> siblings});

/// Detail page for an encrypted video. Same shape as `EncryptedImagePage`:
/// preview, title row, Info card (decrypt / restore + password + file info),
/// Actions card (save, rename).
///
/// Decryption writes the plaintext to a temp file and plays it. The file and the
/// playback position are handed to [DecryptedVideoCache], so leaving and
/// re-entering the page resumes where it left off — the video counterpart of an
/// image keeping its `decryptInfo` in [AppBloc]. Only Restore (or a folder
/// re-encrypt) drops the plaintext.
///
/// ponytail: no bloc. The state that outlives the page lives in the cache
/// singleton; add one if this page ever needs more than the [AppBloc] nudge the
/// rename already does.
class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({
    super.key,
    required this.image,
    this.siblings = const [],
    this.decryptUseCase,
    this.saveUseCase,
    this.renameUseCase,
    this.videoCache,
  });

  final EncryptedImage image;

  /// The archive level this video was opened from, in display order — what the
  /// fullscreen viewer pages through. Empty means "just this one".
  final List<EncryptedImage> siblings;

  /// Injectable for widget tests; real runs resolve them from `get_it`.
  final DecryptVideoUseCase? decryptUseCase;
  final VideoSaverUseCase? saveUseCase;
  final ImageRenamerUseCase? renameUseCase;
  final DecryptedVideoCache? videoCache;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final DecryptVideoUseCase _decryptUseCase;
  late final VideoSaverUseCase _saveUseCase;
  late final ImageRenamerUseCase _renameUseCase;
  late final DecryptedVideoCache _videoCache;

  /// Mutable: renaming changes the file this page points at.
  late EncryptedImage _image;

  String _password = '';
  bool _decrypting = false;
  String? _error;
  File? _tempFile;
  VideoPlayerController? _controller;

  bool get _isDecrypted => _controller != null;

  @override
  void initState() {
    super.initState();
    _image = widget.image;
    _decryptUseCase = widget.decryptUseCase ?? getIt<DecryptVideoUseCase>();
    _saveUseCase = widget.saveUseCase ?? getIt<VideoSaverUseCase>();
    _renameUseCase = widget.renameUseCase ?? getIt<ImageRenamerUseCase>();
    _videoCache = widget.videoCache ?? getIt<DecryptedVideoCache>();

    // Already decrypted in an earlier visit: re-attach instead of asking for the
    // password again.
    final cached = _videoCache.entry(_image.storagePath.path);
    if (cached != null) {
      _decrypting = true;
      unawaited(_attachController(cached.file, at: cached.position));
    }
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null) {
      // Hand the position back so the next visit resumes here.
      _videoCache.savePosition(
        _image.storagePath.path,
        controller.value.position,
      );
      controller.dispose();
    }
    // The plaintext deliberately outlives the page — the cache owns it now.
    super.dispose();
  }

  /// Opens [file] in a player at [at] and flips the page to its unlocked state.
  /// Shared by the fresh-decrypt and the cache-hit paths.
  Future<void> _attachController(
    File file, {
    Duration at = Duration.zero,
  }) async {
    final controller = VideoPlayerController.file(file);
    try {
      await controller.initialize();
    } catch (e) {
      // Truncated or otherwise unplayable temp file: drop it and fall back to
      // the password prompt rather than spinning forever.
      await controller.dispose();
      await _videoCache.evict(_image.storagePath.path);
      if (!mounted) return;
      setState(() {
        _decrypting = false;
        _error = 'Unable to play this video';
      });
      appLogger.log('Video playback init failed', LogLayer.ui, error: '$e');
      return;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }
    // Paused on purpose: this is a still frame, playback lives in the
    // fullscreen viewer. Seeking still renders the resume position.
    if (at > Duration.zero) await controller.seekTo(at);
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() {
      _decrypting = false;
      _tempFile = file;
      _controller = controller;
    });
  }

  Future<void> _decryptAndPlay() async {
    if (_password.isEmpty) {
      setState(() => _error = 'Password cannot be empty');
      return;
    }

    setState(() {
      _decrypting = true;
      _error = null;
    });

    await _videoCache.sweepOnce();

    final result = await _decryptUseCase.call(
      DecryptVideoParams(
        encryptedPath: _image.storagePath.path,
        password: _password,
        assetId: _image.storagePath.assetId,
      ),
    );

    if (!mounted) return;

    await result.fold(
      (failure) async {
        setState(() {
          _decrypting = false;
          _error = failure.message;
        });
      },
      (file) async {
        _videoCache.put(_image.storagePath.path, file);
        await _attachController(file);
      },
    );
  }

  /// Opens the real player. The pager walks this video's archive level, live
  /// objects pulled from [AppBloc] (the siblings handed over at tap time are
  /// snapshots and may have been un/relocked since), filtered to what can
  /// actually be rendered.
  Future<void> _openFullscreen() async {
    final live = {
      for (final item in context.read<AppBloc>().encryptedImages)
        item.storagePath.path: item,
    };
    final currentPath = _image.storagePath.path;

    final ordered =
        widget.siblings.isEmpty
            ? <EncryptedImage>[_image]
            : widget.siblings.map((sibling) {
              // A rename moved this page's file; the snapshot still has the old
              // path, so redirect it to the current one.
              final path =
                  sibling.storagePath.path == widget.image.storagePath.path
                      ? currentPath
                      : sibling.storagePath.path;
              return live[path] ?? sibling;
            }).toList();

    final items = FullscreenMediaViewer.playable(ordered, _videoCache);
    final index = items.indexWhere((i) => i.storagePath.path == currentPath);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder:
            (_) => FullscreenMediaViewer(
              items: index < 0 ? [_image] : items,
              initialIndex: index < 0 ? 0 : index,
              videoCache: _videoCache,
            ),
      ),
    );

    if (!mounted) return;
    // The viewer wrote the position it left off at back to the cache; move the
    // still frame there too.
    final cached = _videoCache.entry(currentPath);
    if (cached != null) await _controller?.seekTo(cached.position);
  }

  /// Drops the player and the plaintext temp file — back to the poster.
  void _restore() {
    final controller = _controller;
    setState(() {
      _controller = null;
      _tempFile = null;
      _error = null;
    });
    controller?.dispose();
    _videoCache.evict(_image.storagePath.path).ignore();
    // A bulk decrypt also unscrambles the poster into `decryptInfo`; clear it
    // or the archive tile keeps showing this video as unlocked.
    context.read<AppBloc>().add(
      AppEvent.setDecryptedInfo(
        path: _image.storagePath.path,
        decryptedInfo: null,
      ),
    );
  }

  /// Saves the plaintext temp file when unlocked, the encrypted mp4 otherwise —
  /// the video counterpart of `decryptInfo?.bytes ?? encryptedInfo.bytes`.
  Future<void> _save() async {
    final path = _tempFile?.path ?? _image.storagePath.path;
    final result = await _saveUseCase.call(
      VideoSaverParams(filePath: path, album: Constants.appFolderName),
    );

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    result.fold(
      (failure) =>
          messenger.showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => messenger.showSnackBar(
        SnackBar(content: Text('Video saved to gallery: ${_image.name}')),
      ),
    );
  }

  Future<void> _rename(String newName) async {
    final parts = _image.storagePath.path.split('/');
    final oldFileName = parts.removeLast();
    final ext = oldFileName.split('.').last;
    final path = parts.join('/');

    final result = await _renameUseCase.call(
      ImageRenamerParams(
        path: path,
        oldFileName: oldFileName,
        newFileName: '$newName.$ext',
        assetId: _image.storagePath.assetId,
        bytes: _image.encryptedInfo.bytes,
        album: Constants.appFolderName,
      ),
    );

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final appBloc = context.read<AppBloc>();

    result.fold(
      (failure) =>
          messenger.showSnackBar(SnackBar(content: Text(failure.message))),
      (renamed) {
        if (!renamed.success) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Unable to rename this video')),
          );
          return;
        }

        final oldIdentifier =
            _image.storagePath.assetId ?? _image.storagePath.path;
        final updated = _image.copyWith(
          storagePath: _image.storagePath.copyWith(
            path: '$path/$newName.$ext',
            assetId: renamed.newAssetId ?? _image.storagePath.assetId,
          ),
        );

        appBloc.add(
          AppEvent.updateEncryptedImage(
            image: updated,
            oldIdentifier: oldIdentifier,
          ),
        );
        // The cache is keyed by the encrypted file's path — follow the rename.
        _videoCache.rekey(_image.storagePath.path, updated.storagePath.path);
        setState(() => _image = updated);
        messenger.showSnackBar(
          const SnackBar(content: Text('Video renamed successfully')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encrypted Video')),
      body: Padding(
        padding: const EdgeInsets.all(16).copyWith(bottom: 0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 16,
            children: [
              SizedBox(
                height: 300,
                child: _Preview(
                  image: _image,
                  controller: _controller,
                  decrypting: _decrypting,
                  onOpen: _openFullscreen,
                ),
              ),
              _titleRow(context),
              _Info(
                image: _image,
                isDecrypted: _isDecrypted,
                decrypting: _decrypting,
                onPasswordChanged: (value) => _password = value,
                onPressed: _isDecrypted ? _restore : _decryptAndPlay,
              ),
              if (_error != null)
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.error,
                  ),
                ),
              _Actions(image: _image, onSave: _save, onRename: _rename),
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              ContainedItem.icon(
                icon:
                    _isDecrypted ? Icons.lock_open_rounded : Icons.lock_rounded,
              ),
              Expanded(
                child: Text(
                  _image.name,
                  style: context.textTheme.headlineSmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
