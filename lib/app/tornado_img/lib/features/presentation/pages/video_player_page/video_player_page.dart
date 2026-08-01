import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_video_usecase.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/presentation/widgets/password_form_field.dart';
import 'package:tornado_img_app/injection_container.dart';
import 'package:video_player/video_player.dart';

/// Plays an encrypted video: asks for the password, decrypts the embedded
/// ciphertext to a temp file, plays that, and deletes it on the way out.
///
/// ponytail: no bloc. The only state that outlives a frame is the player
/// controller, which is widget-lifecycle bound anyway; add one if this page
/// ever needs to talk to `AppBloc`.
class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.image, this.decryptUseCase});

  final EncryptedImage image;

  /// Injectable for widget tests; real runs resolve it from `get_it`.
  final DecryptVideoUseCase? decryptUseCase;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final DecryptVideoUseCase _decryptUseCase;

  String _password = '';
  bool _decrypting = false;
  String? _error;
  File? _tempFile;
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _decryptUseCase = widget.decryptUseCase ?? getIt<DecryptVideoUseCase>();
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
        encryptedPath: widget.image.storagePath.path,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.image.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            spacing: 16,
            children: [
              SizedBox(height: 300, child: _preview()),
              if (_controller == null) ...[
                SizedBox(height: 48, child: PasswordFormField(
                  onChanged: (value) => _password = value,
                )),
                FilledButton.icon(
                  onPressed: _decrypting ? null : _decryptAndPlay,
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  label: Text(_decrypting ? 'Decrypting…' : 'Decrypt and play'),
                ),
              ],
              if (_error != null)
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _preview() {
    final controller = _controller;

    if (controller == null) {
      // Before decryption there is nothing to play — show the same scrambled
      // poster the archive tile shows, with the cosmetic clip's play hint.
      return ClipRRect(
        borderRadius: AppStyle.cardBorderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(widget.image.encryptedInfo.bytes, fit: BoxFit.cover),
            if (_decrypting)
              const Center(child: CircularProgressIndicator())
            else
              Center(
                child: Icon(
                  Icons.lock_rounded,
                  size: 48,
                  color: context.appColors.onAccent,
                ),
              ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: AppStyle.cardBorderRadius,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          VideoProgressIndicator(controller, allowScrubbing: true),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  controller.value.isPlaying
                      ? controller.pause()
                      : controller.play();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
