import 'package:flutter/material.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Archive Page',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
