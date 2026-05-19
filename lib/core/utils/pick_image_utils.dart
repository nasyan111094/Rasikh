import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

final ImagePicker picker = ImagePicker();

Future<MultipartFile> prepareImageForUpload(File image) async {
  String fileName = image.path.split('/').last;

  return await MultipartFile.fromFile(
    image.path,
    filename: fileName,
  );
}

Future<MultipartFile> prepareXFileForUpload(XFile image) async {
  String fileName = image.path.split('/').last;

  return await MultipartFile.fromFile(
    image.path,
    filename: fileName,
  );
}
