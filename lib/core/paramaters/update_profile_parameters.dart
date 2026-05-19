import 'dart:io';

class UpdateProfileParam {
  String? name;
  String? email;
  String? phone;
  String? nationalId;
  String? nationalityId;
  File? file;
  int? gender;

  UpdateProfileParam({
    this.name,
    this.phone,
    this.email,
    this.nationalId,
    this.nationalityId,
    this.file,
    this.gender,
  });
}
