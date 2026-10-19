import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:size_config/size_config.dart';


class ImageCropper extends StatefulWidget {
  const ImageCropper({super.key, required this.image});

  final Uint8List image;

  @override
  State<ImageCropper> createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  late final CropController controller;

  @override
  void initState() {
    super.initState();
    controller = CropController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              image: widget.image,
              baseColor: Colors.white,
              maskColor: Colors.white38,
              aspectRatio: 1,
              initialSize: .5,
              withCircleUi: true,
              controller: controller,
              onCropped: (image) {
                if (image.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(Loc.somethingWentWrong())),
                  );
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context, image);
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0.w),
            child: ElevatedButton(
              onPressed: () => controller.crop(),
              child: Text(
                Loc.confirm(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
