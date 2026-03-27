class AppLogger {
  final int maxLogs = 1000;
  final List<AppLog> _logs = [];

  void logUi(String message, {String? error}) =>
      error == null
          ? _addLog(message, LogLayer.ui)
          : _addErrorLog(message, error, LogLayer.ui);
  void logPageBloc(String message, {String? error}) =>
      error == null
          ? _addLog(message, LogLayer.pageBloc)
          : _addErrorLog(message, error, LogLayer.pageBloc);
  void logBloc(String message, {String? error}) =>
      error == null
          ? _addLog(message, LogLayer.bloc)
          : _addErrorLog(message, error, LogLayer.bloc);
  void logRepository(String message, {String? error}) =>
      error == null
          ? _addLog(message, LogLayer.repository)
          : _addErrorLog(message, error, LogLayer.repository);
  void logUsecase(String message, {String? error}) => error == null
      ? _addLog(message, LogLayer.usecase)
      : _addErrorLog(message, error, LogLayer.usecase);
  void logApi(String message, {String? error}) =>
      error == null
          ? _addLog(message, LogLayer.api)
          : _addErrorLog(message, error, LogLayer.api);
  void logCore(String message, {String? error}) =>
      error == null
          ? _addLog(message, LogLayer.core)
          : _addErrorLog(message, error, LogLayer.core);

  List<AppLog> get allLogs => List.unmodifiable(_logs);

  void _addLog(String message, LogLayer layer) {
    if (_logs.length >= maxLogs) {
      _logs.removeAt(0);
    }
    _logs.add(AppLog.log(message, layer));
  }

  void _addErrorLog(String message, Object error, LogLayer layer) {
    if (_logs.length >= maxLogs) {
      _logs.removeAt(0);
    }
    _logs.add(AppLog.error(message, error, layer));
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
