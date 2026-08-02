import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_app/core/utils/duration_utils.dart';

void main() {
  group('formatDuration', () {
    test('mm:ss below an hour', () {
      expect(formatDuration(Duration.zero), '0:00');
      expect(formatDuration(const Duration(seconds: 65)), '1:05');
      expect(formatDuration(const Duration(minutes: 59, seconds: 59)), '59:59');
    });

    test('h:mm:ss from an hour up', () {
      expect(formatDuration(const Duration(hours: 1)), '1:00:00');
      expect(formatDuration(const Duration(seconds: 3725)), '1:02:05');
    });

    test('negatives clamp to zero', () {
      expect(formatDuration(const Duration(seconds: -5)), '0:00');
    });
  });

  group('seekBy', () {
    const total = Duration(minutes: 2);

    test('adds and subtracts inside the video', () {
      expect(
        seekBy(const Duration(seconds: 30), const Duration(seconds: 10), total),
        const Duration(seconds: 40),
      );
      expect(
        seekBy(
          const Duration(seconds: 30),
          const Duration(seconds: -10),
          total,
        ),
        const Duration(seconds: 20),
      );
    });

    test('clamps at both ends, stopping short of the end', () {
      expect(
        seekBy(const Duration(seconds: 3), const Duration(seconds: -10), total),
        Duration.zero,
      );
      expect(
        seekBy(
          const Duration(seconds: 115),
          const Duration(seconds: 10),
          total,
        ),
        total - const Duration(milliseconds: 250),
      );
    });
  });

  group('clampSeekTarget', () {
    const total = Duration(minutes: 2);

    test('leaves targets inside the video alone', () {
      expect(
        clampSeekTarget(const Duration(seconds: 30), total),
        const Duration(seconds: 30),
      );
      expect(clampSeekTarget(Duration.zero, total), Duration.zero);
    });

    test('never lands on the end itself', () {
      // seekTo(duration) marks the controller completed and play() then
      // restarts from zero.
      expect(clampSeekTarget(total, total), lessThan(total));
      expect(
        clampSeekTarget(const Duration(hours: 1), total),
        total - const Duration(milliseconds: 250),
      );
    });

    test('negatives and sub-guard clips fall back to zero', () {
      expect(
        clampSeekTarget(const Duration(seconds: -5), total),
        Duration.zero,
      );
      expect(
        clampSeekTarget(
          const Duration(milliseconds: 100),
          const Duration(milliseconds: 200),
        ),
        Duration.zero,
      );
    });
  });
}
