import 'dart:async';
import 'dart:collection';

import 'package:tornado_img_app/core/domain/entities/dearchiving_state.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_image_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_video_usecase.dart';
import 'package:tornado_img_app/core/managers/decrypted_video_cache.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

/// Owns background decrypt jobs, one per archive folder, independent of the
/// serialized [GalleryBloc] event queue so several folders decrypt in parallel.
///
/// Jobs survive navigation (this is an app-wide singleton). Each decrypted image
/// is committed to the canonical [AppBloc] via [AppEvent.setDecryptedInfo], so
/// the decrypted state persists even after a job finishes and its progress entry
/// is dropped. Progress for the UI is exposed as [DearchivingState] snapshots via
/// [jobState]; [updates] ticks whenever any job changes.
class DecryptJobManager {
  DecryptJobManager({
    required DecryptImageUseCase decryptUseCase,
    required DecryptVideoUseCase decryptVideoUseCase,
    required DecryptedVideoCache videoCache,
    required AppBloc appBloc,
    int maxConcurrent = 3,
  }) : _decryptUseCase = decryptUseCase,
       _decryptVideoUseCase = decryptVideoUseCase,
       _videoCache = videoCache,
       _appBloc = appBloc,
       _maxConcurrent = maxConcurrent;

  final DecryptImageUseCase _decryptUseCase;
  final DecryptVideoUseCase _decryptVideoUseCase;
  final DecryptedVideoCache _videoCache;
  final AppBloc _appBloc;

  /// Upper bound on concurrent [DecryptImageUseCase] calls across all jobs, to
  /// keep the number of live `compute` isolates in check.
  final int _maxConcurrent;
  int _inFlight = 0;
  final Queue<Completer<void>> _waiters = Queue<Completer<void>>();

  final Map<String, _DecryptJob> _jobs = <String, _DecryptJob>{};

  final StreamController<void> _updates = StreamController<void>.broadcast();

  /// Ticks whenever any job's state changes. Consumers read snapshots via
  /// [jobState] / [isRunning].
  Stream<void> get updates => _updates.stream;

  /// Builds the job key for a folder (store + path relative to the store root).
  static String keyFor({
    required bool isPrivate,
    required String relativePath,
  }) => '${isPrivate ? 1 : 0}:$relativePath';

  /// Current progress snapshot for [key], or null if no job is tracked.
  DearchivingState? jobState(String key) => _jobs[key]?.snapshot;

  /// Whether a job for [key] is still processing images.
  bool isRunning(String key) => _jobs[key]?.isRunning ?? false;

  /// Starts (or resumes) a background decrypt for the [images] under [key].
  /// Already-decrypted images are skipped. If a job for [key] is still running
  /// this is a no-op. Returns immediately; observe progress via [updates].
  void start({
    required String key,
    required List<EncryptedImage> images,
    required String password,
  }) {
    if (isRunning(key)) return;

    final pending = images.where((img) => img.decryptInfo == null).toList();
    final done = images.where((img) => img.decryptInfo != null).toList();
    if (pending.isEmpty) return;

    final job = _DecryptJob(
      loading: pending,
      dearchived: done,
      failed: <EncryptedImage>[],
    );
    _jobs[key] = job;
    _tick();

    unawaited(_run(key, job, password));
  }

  /// Requests cancellation of the job for [key]. Images already decrypted stay
  /// committed; remaining ones are skipped.
  void cancel(String key) {
    final job = _jobs[key];
    if (job == null) return;
    job.cancelled = true;
  }

  Future<void> _run(String key, _DecryptJob job, String password) async {
    final pending = List<EncryptedImage>.from(job.loading);

    for (final image in pending) {
      if (job.cancelled) break;

      await _acquire();
      try {
        // A video's plaintext goes to a temp file the cache owns, so opening it
        // plays straight away. Done first: it verifies the password from the
        // box's KCV, so a wrong one fails here instead of silently producing a
        // garbage poster.
        final videoFailure =
            image.isVideo ? await _decryptVideoFile(image, password) : null;

        if (videoFailure != null) {
          job.loading.remove(image);
          job.failed.add(image);
          appLogger.log(
            'DecryptJobManager: video decrypt failed',
            LogLayer.bloc,
            error: '${image.storagePath.path}: $videoFailure',
          );
        } else {
          // For a video this unscrambles the poster box, not the whole file —
          // see DecryptImageUseCase.
          final result = await _decryptUseCase.call(
            DecryptImageParams(
              file: image.storagePath.file,
              password: password,
              assetId: image.storagePath.assetId,
            ),
          );

          job.loading.remove(image);
          result.fold(
            (failure) {
              job.failed.add(image);
              appLogger.log(
                'DecryptJobManager: decrypt failed',
                LogLayer.bloc,
                error: '${image.storagePath.path}: ${failure.message}',
              );
            },
            (bytes) {
              job.dearchived.add(image.copyWith(decryptInfo: bytes));
              _appBloc.add(
                AppEvent.setDecryptedInfo(
                  path: image.storagePath.path,
                  decryptedInfo: bytes,
                ),
              );
            },
          );
        }
      } finally {
        _release();
      }
      _tick();
    }

    // Job finished (or cancelled): drop the progress entry. Decrypted bytes
    // remain in AppBloc, so the folder still shows as decrypted.
    _jobs.remove(key);
    _tick();
  }

  /// Writes a video's plaintext to a temp file and hands it to
  /// [DecryptedVideoCache], the file-level counterpart of `decryptInfo`.
  /// Returns the failure message, or null on success (a cache hit included).
  Future<String?> _decryptVideoFile(
    EncryptedImage image,
    String password,
  ) async {
    final path = image.storagePath.path;
    if (_videoCache.entry(path) != null) return null;

    // Same ordering VideoPlayerPage uses: drop a previous run's leftovers
    // before the first plaintext of this session lands in the temp dir.
    await _videoCache.sweepOnce();

    final result = await _decryptVideoUseCase.call(
      DecryptVideoParams(
        encryptedPath: path,
        password: password,
        assetId: image.storagePath.assetId,
      ),
    );
    return result.fold((failure) => failure.message, (file) {
      _videoCache.put(path, file);
      return null;
    });
  }

  // ── Concurrency gate ────────────────────────────────────────────────────────

  Future<void> _acquire() {
    if (_inFlight < _maxConcurrent) {
      _inFlight++;
      return Future<void>.value();
    }
    final waiter = Completer<void>();
    _waiters.add(waiter);
    return waiter.future;
  }

  void _release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete();
      return;
    }
    _inFlight--;
  }

  void _tick() {
    if (!_updates.isClosed) _updates.add(null);
  }

  Future<void> dispose() async {
    for (final job in _jobs.values) {
      job.cancelled = true;
    }
    _jobs.clear();
    await _updates.close();
  }
}

/// Mutable in-progress bookkeeping for a single folder decrypt.
class _DecryptJob {
  _DecryptJob({
    required this.loading,
    required this.dearchived,
    required this.failed,
  }) : total = loading.length + dearchived.length + failed.length;

  final List<EncryptedImage> loading;
  final List<EncryptedImage> dearchived;
  final List<EncryptedImage> failed;
  final int total;
  bool cancelled = false;

  bool get isRunning => !cancelled && loading.isNotEmpty;

  DearchivingState get snapshot => DearchivingState(
    totalImages: total,
    loadingImages: loading.toList(),
    dearchivedImages: dearchived.toList(),
    failedImages: failed.toList(),
  );
}
