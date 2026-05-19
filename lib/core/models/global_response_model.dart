import 'package:rasikh/core/utils/translation_helper.dart';

class GlobalResponseModel {
  final String? errors;
  final String? message;
  final bool status;
  final dynamic data;

  GlobalResponseModel(
      {this.status = false, this.errors, this.message, this.data});

  static fromJson(Map<String, dynamic> data) {
    // print(data);
    return GlobalResponseModel(
      status: data["status"] ?? false,
      message: data["message"],
      data: data["data"],
    );
  }

  showError() {
    return status == false
        ? message!.isEmpty
            ? getServerError()
            : getError(message)
        : null;
  }

  static String getError(data) {
    String error = '';
    if (data is Map) {
      for (int i = 0; i < ((data)).keys.length; i++) {
        final f = (((data))[((data)).keys.elementAt(i)]);

        error += "\n" + ((f is List) ? f.first : f);
      }
    }
    return error;
  }
}
