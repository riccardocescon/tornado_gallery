import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_app/core/utils/seek_queue.dart';

/// A seek that only completes when the test says so, so the "in flight" window
/// can be controlled exactly.
class _FakeSeek {
  final List<Duration> calls = <Duration>[];
  final List<Completer<void>> _completers = <Completer<void>>[];

  Future<void> call(Duration target) {
    calls.add(target);
    final completer = Completer<void>();
    _completers.add(completer);
    return completer.future;
  }

  /// Completes the oldest in-flight seek.
  Future<void> finishOne() async {
    _completers.removeAt(0).complete();
    // Let the queue's drain loop resume.
    await Future<void>.delayed(Duration.zero);
  }

  int get inFlight => _completers.length;
}

void main() {
  test('sends the first target immediately', () async {
    final seek = _FakeSeek();
    final queue = SeekQueue(seek.call);

    queue.request(const Duration(seconds: 5));

    expect(seek.calls, [const Duration(seconds: 5)]);
    expect(queue.isSeeking, isTrue);
  });

  test(
    'collapses requests made while a seek is in flight — latest wins',
    () async {
      final seek = _FakeSeek();
      final queue = SeekQueue(seek.call);

      queue.request(const Duration(seconds: 1));
      queue.request(const Duration(seconds: 2));
      queue.request(const Duration(seconds: 3));
      queue.request(const Duration(seconds: 4));

      // Only the first went out; the rest collapsed into one pending target.
      expect(seek.calls, [const Duration(seconds: 1)]);
      expect(seek.inFlight, 1);

      await seek.finishOne();

      // The dropped middles are gone: 2s and 3s were never sent.
      expect(seek.calls, [
        const Duration(seconds: 1),
        const Duration(seconds: 4),
      ]);
      expect(queue.requested, 4);
      expect(queue.issued, 2);
    },
  );

  test('request future completes only when the queue has drained', () async {
    final seek = _FakeSeek();
    final queue = SeekQueue(seek.call);

    queue.request(const Duration(seconds: 1));
    var drained = false;
    final pending = queue.request(const Duration(seconds: 9))
      ..whenComplete(() => drained = true);

    await seek.finishOne(); // 1s done, 9s goes out
    expect(drained, isFalse, reason: 'the last target is still in flight');

    await seek.finishOne(); // 9s done
    await pending;

    expect(drained, isTrue);
    expect(queue.isSeeking, isFalse);
    expect(seek.calls.last, const Duration(seconds: 9));
  });

  test('a request after draining starts a fresh drain', () async {
    final seek = _FakeSeek();
    final queue = SeekQueue(seek.call);

    await Future.wait([
      queue.request(const Duration(seconds: 1)),
      seek.finishOne(),
    ]);
    expect(queue.isSeeking, isFalse);

    queue.request(const Duration(seconds: 2));
    expect(seek.calls, [
      const Duration(seconds: 1),
      const Duration(seconds: 2),
    ]);
    expect(queue.isSeeking, isTrue);
  });
}
