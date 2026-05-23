

import 'dart:io';

class UpdateProfileParam {
  final String fullName;
  final String email;
  final String city;
  final File? avatar; // optional – multipart avatar field

  const UpdateProfileParam({
    required this.fullName,
    required this.email,
    required this.city,
    this.avatar,
  });
}
