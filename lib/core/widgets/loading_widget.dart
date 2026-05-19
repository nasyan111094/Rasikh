import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:size_config/size_config.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.loadingColor,
    this.size,
    this.assetPath = "assets/anims/loading.json",
  });

  final Color? loadingColor;
  final double? size;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final double loaderSize = size ?? 40.h;

    return Center(
      child: SizedBox(
        width: loaderSize,
        height: loaderSize,
        child: Lottie.asset(
          assetPath,
          fit: BoxFit.contain,
          repeat: true,
          reverse: true,
        ),
      ),
    );
  }
}
