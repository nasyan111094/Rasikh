import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/config/navigation/nav.dart';
import 'package:separated_row/separated_row.dart';
import 'package:size_config/size_config.dart';


class MediaPicker extends StatefulWidget {
  const MediaPicker({super.key});

  static Future<String?> pickImage(BuildContext context) async {
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => const MediaPicker(),
    );
    if (src != null) {
      final image = await ImagePicker().pickImage(source: src);
      if (image != null) {
        return image.path;
      }
    }
    return null;
  }

  static Future<String?> pickAndCropImage(BuildContext context) async {
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => const MediaPicker(),
    );
    if (src != null) {
      final image = await ImagePicker().pickImage(source: src);
      if (image != null) {
        final imageData = await image.readAsBytes();
        if (!context.mounted) return null;
        final croppedImage = await Nav.crop(context, imageData);
        if (croppedImage != null) {
          final newFile = File(image.path);
          await newFile.writeAsBytes(croppedImage);
          return newFile.path;
        }
      }
    }
    return null;
  }

  @override
  State<MediaPicker> createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  late final ValueNotifier<ImageSource?> mediaSrcCtl;

  @override
  void initState() {
    super.initState();
    mediaSrcCtl = ValueNotifier(null);
  }

  @override
  void dispose() {
    mediaSrcCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
            ),
            child: Text(
              Loc.pick_file_source(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                  horizontal: 10.0.w,
                ) +
                EdgeInsets.only(
                  bottom: 10.h,
                ),
            child: SeparatedRow(
              separatorBuilder: (context, index) => SizedBox(
                width: 10.w,
              ),
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildItem(
                  id: ImageSource.gallery,
                  title: Loc.gallery(),
                  icon: Icons.folder_copy_outlined,
                ),
                _buildItem(
                  id: ImageSource.camera,
                  title: Loc.camera(),
                  icon: Icons.camera_alt_outlined,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required ImageSource id,
    required String title,
    required IconData icon,
  }) =>
      Builder(
        builder: (context) => Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pop(
              context,
              id,
            ),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    10,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 40.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 48.sp,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
