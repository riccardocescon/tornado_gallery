import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_app/core/managers/decrypted_video_cache.dart';

void main() {
  late Directory tempDir;
  late DecryptedVideoCache cache;

  setUp(() async {
    tempDir = await DecryptedVideoCache.tempDir.create(recursive: true);
    cache = DecryptedVideoCache();
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Future<File> makePlaintext(String name) async {
    final file = File('${tempDir.path}/$name');
    await file.writeAsBytes(<int>[1, 2, 3]);
    return file;
  }

  test('entry returns the cached file and position after put', () async {
    final file = await makePlaintext('a.mp4');
    cache.put('/enc/a.mp4', file);

    final entry = cache.entry('/enc/a.mp4');
    expect(entry, isNotNull);
    expect(entry!.file.path, file.path);
    expect(entry.position, Duration.zero);
  });

  test('entry is null for an unknown path', () {
    expect(cache.entry('/enc/nope.mp4'), isNull);
  });

  test('savePosition is returned by the next entry lookup', () async {
    final file = await makePlaintext('b.mp4');
    cache.put('/enc/b.mp4', file);

    cache.savePosition('/enc/b.mp4', const Duration(seconds: 42));

    expect(cache.entry('/enc/b.mp4')!.position, const Duration(seconds: 42));
  });

  test('entry evicts when the temp file vanished under us', () async {
    final file = await makePlaintext('c.mp4');
    cache.put('/enc/c.mp4', file);
    await file.delete();

    expect(cache.entry('/enc/c.mp4'), isNull);
    // Evicted, not just reported missing: re-creating the file must not
    // resurrect the entry.
    await makePlaintext('c.mp4');
    expect(cache.entry('/enc/c.mp4'), isNull);
  });

  test('rekey moves the entry and keeps the position', () async {
    final file = await makePlaintext('d.mp4');
    cache.put('/enc/d.mp4', file);
    cache.savePosition('/enc/d.mp4', const Duration(seconds: 5));

    cache.rekey('/enc/d.mp4', '/enc/renamed.mp4');

    expect(cache.entry('/enc/d.mp4'), isNull);
    expect(
      cache.entry('/enc/renamed.mp4')!.position,
      const Duration(seconds: 5),
    );
  });

  test('evict deletes the plaintext and drops the entry', () async {
    final file = await makePlaintext('e.mp4');
    cache.put('/enc/e.mp4', file);

    await cache.evict('/enc/e.mp4');

    expect(await file.exists(), isFalse);
    expect(cache.entry('/enc/e.mp4'), isNull);
    // Miss is a no-op, not a throw.
    await cache.evict('/enc/e.mp4');
  });

  test(
    'sweepOnce wipes leftovers once, then leaves live entries alone',
    () async {
      await makePlaintext('crash-leftover.mp4');

      await cache.sweepOnce();
      expect(await tempDir.exists(), isFalse);

      // A file decrypted after the sweep must survive every later call.
      await tempDir.create(recursive: true);
      final file = await makePlaintext('f.mp4');
      cache.put('/enc/f.mp4', file);

      await cache.sweepOnce();

      expect(await file.exists(), isTrue);
      expect(cache.entry('/enc/f.mp4'), isNotNull);
    },
  );

  test('clear deletes every cached plaintext', () async {
    cache.put('/enc/g.mp4', await makePlaintext('g.mp4'));
    cache.put('/enc/h.mp4', await makePlaintext('h.mp4'));

    await cache.clear();

    expect(cache.entry('/enc/g.mp4'), isNull);
    expect(cache.entry('/enc/h.mp4'), isNull);
    expect(await File('${tempDir.path}/g.mp4').exists(), isFalse);
    expect(await File('${tempDir.path}/h.mp4').exists(), isFalse);
  });
}
