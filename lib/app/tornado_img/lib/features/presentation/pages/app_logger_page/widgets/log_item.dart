part of '../app_logger_page.dart';

class _LogItem extends StatelessWidget {
  const _LogItem({required this.log});

  final AppLog log;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(log.message, style: context.textTheme.bodyMedium),
          if (log.error != null) ...[
            Text(
              'Error: ${log.error}',
              style: context.textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
            Text(
              'Stack Trace: ${log.stackTrace}',
              style: context.textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
          ],
          Text(
            'File: ${log.file}',
            style: context.textTheme.bodySmall?.copyWith(color: Colors.blue),
          ),
          Text(
            'Function: ${log.function}',
            style: context.textTheme.bodySmall?.copyWith(color: Colors.orange),
          ),
          Text(
            'Time: ${DateFormat("HH:mm:ss.SSS").format(log.timestamp)}',
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
