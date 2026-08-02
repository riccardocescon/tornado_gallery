import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/extentions.dart';

part 'widgets/log_item.dart';

/// The in-app log. Filter box + copy button, so a run can actually be searched
/// and pasted somewhere useful — plain logs never reach the console
/// (`AppLogger.showPrints` is only on in debug builds).
class AppLoggerPage extends StatefulWidget {
  const AppLoggerPage({super.key});

  @override
  State<AppLoggerPage> createState() => _AppLoggerPageState();
}

class _AppLoggerPageState extends State<AppLoggerPage> {
  final _filterController = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  List<AppLog> get _visible {
    final needle = _filter.trim().toLowerCase();
    final logs = List<AppLog>.from(appLogger.allLogs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (needle.isEmpty) return logs;
    return logs
        .where(
          (log) =>
              log.message.toLowerCase().contains(needle) ||
              (log.error?.toLowerCase().contains(needle) ?? false),
        )
        .toList();
  }

  /// Copies what is on screen, oldest first — the order you want to read.
  Future<void> _copy(List<AppLog> logs) async {
    final text = logs.reversed
        .map(
          (log) =>
              '${DateFormat("HH:mm:ss.SSS").format(log.timestamp)} '
              '[${log.layer.name}] ${log.message}'
              '${log.error == null ? '' : ' | ERROR: ${log.error}'}',
        )
        .join('\n');

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${logs.length} log lines copied')));
  }

  @override
  Widget build(BuildContext context) {
    final logs = _visible;

    return Scaffold(
      appBar: AppBar(
        title: Text('Logger', style: context.textTheme.headlineMedium),
        actions: [
          IconButton(
            tooltip: 'Copy shown logs',
            icon: const Icon(Icons.copy_rounded),
            onPressed: logs.isEmpty ? null : () => _copy(logs),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _filterController,
              onChanged: (value) => setState(() => _filter = value),
              decoration: InputDecoration(
                hintText: 'Filter logs',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon:
                    _filter.isEmpty
                        ? null
                        : IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _filterController.clear();
                            setState(() => _filter = '');
                          },
                        ),
              ),
            ),
          ),
          Expanded(
            child:
                logs.isEmpty
                    ? const Center(child: Text('No logs'))
                    : ListView.builder(
                      itemCount: logs.length,
                      itemBuilder:
                          (context, index) => _LogItem(log: logs[index]),
                    ),
          ),
        ],
      ),
    );
  }
}
