import 'dart:convert' as json;

import 'package:easy_localization/easy_localization.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/core/utils/safe_utils.dart';

bool validString(dynamic src) =>
    src != null && src.toString().trim().isNotEmpty == true;

String validateString(dynamic src, [String def = '']) =>
    validString(src) ? src : def;

bool validList<E>(dynamic src) =>
    src != null && src is List<E> && src.isNotEmpty;

bool validateBool(dynamic o,
        [bool def = false, bool Function(dynamic o)? validator]) =>
    (validator?.call(o) ?? validBool(o) ? o : def);

bool validBool(dynamic o) => o != null && o is bool;

bool isArabic(String text) {
  // final englishPattern = RegExp(r'^[a-zA-Z0-9!@#\$&*~]+$');
  final arabicPattern = RegExp(
      r'^[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]+$');
  // debugPrint('isArabic: ${arabicPattern.hasMatch(text)}');
  // var locale = const Locale('ar'); // Set the locale to Arabic
  Bidi.hasAnyRtl(
    text,
  );
  return Bidi.hasAnyRtl(
    text,
  );
}

bool validNationalId(String src) => src.length == 10;

List<E> validateList<E>(dynamic src, [List<E> def = const []]) =>
    validList(src) ? src : def;

bool validMap<K, V>(dynamic src) =>
    src != null && src is Map<K, V> && src.isNotEmpty;

Map<K, V> validateMap<K, V>(dynamic src, [Map<K, V> def = const {}]) =>
    validMap(src) ? src : def;

bool validInt(dynamic src) => int.tryParse(src.toString()) != null;

int validateInt(dynamic src, [int def = 0]) =>
    int.tryParse(validateString(src?.toString())) ?? def;

bool validDouble(dynamic src) => double.tryParse(src.toString()) != null;

double validateDouble(dynamic src, [double def = 0]) =>
    double.tryParse(validateString(src)) ?? def;

E validateEnum<E extends Enum>(List<E> enums, dynamic src) =>
    enums.safeFirstWhere((e) => e.name == src.toString()) ?? enums.first;

bool isTrue(dynamic src) => src?.toString() == 'true' || src?.toString() == '1';

T? validateJson<T>(
        dynamic src, T Function(Map<String, dynamic> json) fromJson) =>
    validMap<String, dynamic>(src) ? fromJson(src) : null;

List<T> validateJsonList<T>(
        dynamic src, T Function(Map<String, dynamic> e) fromJson) =>
    validList<Map<String, dynamic>>(src)
        ? (src as List<Map<String, dynamic>>).map(fromJson).cast<T>().toList()
        : <T>[];

bool validEmail(String src) => RegExp(
        r"""^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+""")
    .hasMatch(src);

bool validPassword(String src) => src.length >= 6;

String prettify(val) => const json.JsonEncoder.withIndent('  ').convert(val);

bool validatePassword(String value) {
  String pattern =
      r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$";
  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(convertSpace(value));
}

String convertSpace(String value) => value
    .replaceAll(String.fromCharCode(8206), ' ')
    .replaceAll(String.fromCharCode(8207), ' ')
    .replaceAll(String.fromCharCode(32), ' ');

bool isPhoneNumberValid(String? phoneNo, String countryCode) {
  if (phoneNo == null) return false;
  final RegExp regExp;
  // debugPrint(countryCode);
// if (countryCode == '966') {
// regExp = RegExp(r'(^(?:[+0]9)?[0-9]{9}$)');
// } else
//
  if (countryCode == '20') {
    // regExp = RegExp(r'(^(?:[+0]9)?[0-9]{11}$)');
    regExp = RegExp(r'^(010|011|012|015|10|11|12|15)[0-9]{8}$');
  } else {
    regExp = RegExp(r'(^(?:[+0]9)?[0-9]{10}$)');
  }
  return regExp.hasMatch(phoneNo);
}

/// Validate Saudi phone number format
String? validateSaudiPhoneNumber(String? phoneNumber) {
  final RegExp saudiPhoneRegex = RegExp(r'^05[0-9]{8}$');
  if (phoneNumber == null || phoneNumber.trim().isEmpty) {
    return Loc.emptyPhoneNumber();
  } else if (!saudiPhoneRegex.hasMatch(phoneNumber)) {
    return Loc.generalUnvaildPhoneNumber();
  }

  return null; // Invalid phone number
}

String? validateName(String? name) {
  if (name == null || name.trim().isEmpty) {
    return Loc.emptyName();
  } else if (name.length < 3) {
    return Loc.invalidName();
  }
  return null;
}
