import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/extentions.dart';

part 'widgets/log_item.dart';

class AppLoggerPage extends StatelessWidget {
  const AppLoggerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sortedLogs = List<AppLog>.from(appLogger.allLogs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      appBar: AppBar(
        title: Text('Logger', style: context.textTheme.headlineMedium),
      ),
      body: ListView.builder(
        itemCount: sortedLogs.length,
        itemBuilder: (context, index) {
          final log = sortedLogs[index];
          return _LogItem(log: log);
        },
      ),
    );
  }
}
