import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/extentions.dart';

class LoadingContainer extends StatelessWidget {
  const LoadingContainer({super.key, this.width = 80, this.height = 16});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ClipRRect(
        borderRadius: AppStyle.cardBorderRadius,
        child: Container(
          width: width,
          height: height,
          color: context.colorScheme.surface,
        ),
      ),
    );
  }
}
