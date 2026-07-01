import 'dart:developer' as developer;

class AppLogger {
  bool showPrints = false;
  final int maxLogs = 1000;
  final List<AppLog> _logs = [];

  /// Records [message] under [layer]. Pass [error] to record it as an error
  /// log (with a stack trace) instead of a plain log.
  ///
  /// This single entry point replaces the former per-layer `logUi`/`logBloc`/…
  /// convenience methods. It calls straight into [_addLog]/[_addErrorLog] so
  /// the caller location captured by [AppLog] is unaffected.
  void log(String message, LogLayer layer, {String? error}) => error == null
      ? _addLog(message, layer)
      : _addErrorLog(message, error, layer);

  List<AppLog> get allLogs => List.unmodifiable(_logs);

  void _addLog(String message, LogLayer layer) {
    if (_logs.length >= maxLogs) {
      _logs.removeAt(0);
    }
    _logs.add(AppLog.log(message, layer));

    if (showPrints) developer.log('[${layer.name.toUpperCase()}] $message');
  }

  void _addErrorLog(String message, Object error, LogLayer layer) {
    if (_logs.length >= maxLogs) {
      _logs.removeAt(0);
    }
    _logs.add(AppLog.error(message, error, layer));

    developer.log(
      '[ERROR] [${layer.name.toUpperCase()}] $message - Error: $error',
      stackTrace: StackTrace.current,
    );
  }
}

class AppLog {
  final String file;
  final String function;
  final String message;
  final LogLayer layer;
  final String? error;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  const AppLog._({
    required this.file,
    required this.function,
    required this.message,
    required this.layer,
    required this.error,
    required this.stackTrace,
    required this.timestamp,
  });

  factory AppLog.log(String message, LogLayer layer) {
    final location = _getLocation;

    return AppLog._(
      file: location.$1,
      function: location.$2,
      message: message,
      layer: layer,
      timestamp: DateTime.now(),
      error: null,
      stackTrace: null,
    );
  }

  factory AppLog.error(String message, Object error, LogLayer layer) {
    final location = _getLocation;
    return AppLog._(
      file: location.$1,
      function: location.$2,
      message: message,
      layer: layer,
      timestamp: DateTime.now(),
      error: error.toString(),
      stackTrace: StackTrace.current,
    );
  }

  static (String, String) get _getLocation {
    final trace = StackTrace.current;
    final frames = trace.toString().split('\n');
    final callerFrame = frames.length > 2 ? frames[2] : null;

    String file = 'unknown';
    String function = 'unknown';

    if (callerFrame != null) {
      final match = RegExp(
        r'#\d+\s+(.+?)\s+\((.+?):\d+:\d+\)',
      ).firstMatch(callerFrame);
      if (match != null) {
        function = match.group(1) ?? 'unknown';
        file = match.group(2) ?? 'unknown';
      }
    }

    return (file, function);
  }
}

enum LogLayer { ui, pageBloc, bloc, repository, usecase, api, core }
