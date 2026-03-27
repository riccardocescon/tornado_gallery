import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/features/presentation/bloc/archive_page_bloc/archive_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/widgets/contained_icon.dart';
import 'package:tornado_img_app/features/presentation/widgets/page_title.dart';

part 'widgets/archived_tile.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: const SizedBox(height: 18)),
          SliverToBoxAdapter(
            child: PageTitle(
              title: "Archive",
              subtitle: "View and manage your archived images",
              icon: Icons.archive,
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Container(
              width: double.maxFinite,
              child: Row(children: [_encryptedFiles()]),
            ),
          ),
          _images(),
        ],
      ),
    );
  }

  Widget _images() {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      builder: (context, state) {
        return state.maybeWhen(
          ui: (images) {
            if (images.isEmpty) {
              return const Center(child: Text("No archived images found"));
            }

            return SliverList.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    _ArchivedTile(image: images[index]),
                    if (index != images.length - 1)
                      Divider(
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                      ),
                  ],
                );
              },
            );
          },
          orElse: () => SliverToBoxAdapter(child: const SizedBox()),
        );
      },
    );
  }

  Widget _encryptedFiles() {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen:
          (previous, current) => current.maybeWhen(
            ui:
                (images) => previous.maybeWhen(
                  ui: (prevImages) => prevImages.length != images.length,
                  orElse: () => true,
                ),
            orElse: () => false,
          ),
      builder: (context, state) {
        return state.maybeWhen(
          ui: (images) {
            final encryptedCount = images.length;
            if (encryptedCount == 0) return const SizedBox();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                "$encryptedCount archived ${encryptedCount == 1 ? "file" : "files"}",
                style: context.textTheme.labelMedium!.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
          orElse: () => const SizedBox(),
        );
      },
    );
  }
}
