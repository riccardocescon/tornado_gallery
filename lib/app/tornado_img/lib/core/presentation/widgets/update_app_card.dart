import 'package:flutter/material.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/extentions.dart';

class UpdateAppCard extends StatelessWidget {
  const UpdateAppCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!upgrader.isUpdateAvailable()) {
      return const SizedBox();
    }

    return SizedBox(
      width: double.maxFinite,
      child: FilledButton(
        onPressed: () => upgrader.sendUserToAppStore(),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colorScheme.primaryContainer.withValues(
            alpha: 0.6,
          ),
          foregroundColor: context.colorScheme.onPrimaryContainer,
        ),
        child: Row(
          spacing: 12,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.update, color: context.colorScheme.onPrimaryContainer),
            Flexible(
              child: Text(
                "New version available! Tap to update",
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
