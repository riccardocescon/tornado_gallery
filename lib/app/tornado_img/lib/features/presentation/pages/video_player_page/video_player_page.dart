import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_video_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_renamer_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/video_saver_usecase.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/pages/fullscreen_video_viewer.dart';
import 'package:tornado_img_app/core/presentation/widgets/option_item.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
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

/// Detail page for an encrypted video. Same shape as `EncryptedImagePage`:
/// preview, title row, Info card (decrypt / restore + password + file info),
/// Actions card (save, rename).
///
/// Decryption writes the plaintext to a temp file, plays it, and deletes it on
/// the way out.
///
/// ponytail: no bloc. The only state that outlives a frame is the player
/// controller, which is widget-lifecycle bound anyway; add one if this page
/// ever needs more than the [AppBloc] nudge the rename already does.
class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({
    super.key,
    required this.image,
    this.decryptUseCase,
    this.saveUseCase,
    this.renameUseCase,
  });

  final EncryptedImage image;

  /// Injectable for widget tests; real runs resolve them from `get_it`.
  final DecryptVideoUseCase? decryptUseCase;
  final VideoSaverUseCase? saveUseCase;
  final ImageRenamerUseCase? renameUseCase;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final DecryptVideoUseCase _decryptUseCase;
  late final VideoSaverUseCase _saveUseCase;
  late final ImageRenamerUseCase _renameUseCase;

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
  }

  /// Clears plaintext a previous crash left behind, right before writing new
  /// plaintext into the same directory.
  ///
  /// ponytail: whole-directory sweep, fine while only one player can be open;
  /// move to per-file lifecycle if that ever stops being true.
  Future<void> _sweepTempDir() async {
    final dir = Directory('${Directory.systemTemp.path}/tornado_video');
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    // Plaintext must not outlive the page (see the plan's v1 decision to
    // decrypt to disk rather than stream on the fly).
    _tempFile?.delete().ignore();
    super.dispose();
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

    await _sweepTempDir();

    final result = await _decryptUseCase.call(
      DecryptVideoParams(
        encryptedPath: _image.storagePath.path,
        password: _password,
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
        final controller = VideoPlayerController.file(file);
        await controller.initialize();
        if (!mounted) {
          await controller.dispose();
          await file.delete();
          return;
        }
        await controller.setLooping(true);
        await controller.play();
        setState(() {
          _decrypting = false;
          _tempFile = file;
          _controller = controller;
        });
      },
    );
  }

  /// Drops the player and the plaintext temp file — back to the poster.
  void _restore() {
    final controller = _controller;
    final tempFile = _tempFile;
    setState(() {
      _controller = null;
      _tempFile = null;
      _error = null;
    });
    controller?.dispose();
    tempFile?.delete().ignore();
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
