import 'package:logger/logger.dart';
import 'package:test/test.dart';

void main() {
  group('AppLogger.log', () {
    test('records a plain log under the given layer', () {
      final logger = AppLogger();
      logger.log('hello', LogLayer.repository);

      expect(logger.allLogs, hasLength(1));
      final entry = logger.allLogs.single;
      expect(entry.message, 'hello');
      expect(entry.layer, LogLayer.repository);
      expect(entry.error, isNull);
      expect(entry.stackTrace, isNull);
    });

    test('records an error log when error is provided', () {
      final logger = AppLogger();
      logger.log('boom', LogLayer.usecase, error: 'bad');

      final entry = logger.allLogs.single;
      expect(entry.message, 'boom');
      expect(entry.layer, LogLayer.usecase);
      expect(entry.error, 'bad');
      expect(entry.stackTrace, isNotNull);
    });

    test('caps the buffer at maxLogs entries', () {
      final logger = AppLogger();
      for (var i = 0; i < logger.maxLogs + 10; i++) {
        logger.log('m$i', LogLayer.core);
      }
      expect(logger.allLogs, hasLength(logger.maxLogs));
      // Oldest entries are dropped first.
      expect(logger.allLogs.first.message, 'm10');
    });
  });
}
