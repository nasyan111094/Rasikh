class CustomPhoneNumber {
  static final RegExp _regex = RegExp(
    r'^(?:\+?(966|2|971|962))(\d+)$',
    caseSensitive: false,
  );

  static Map<String, String> separatePhoneNumbers(String phoneNumber) {
    final cleanedNumber = phoneNumber.replaceAll('-', '').replaceAll(' ', ''); // Remove dashes and spaces
    final match = _regex.firstMatch(cleanedNumber);
    if (match != null) {
      late String phoneNumberWithoutCountryCode = match.group(2) ?? '';
      final String countryCode = match.group(1) ?? '';
      if (phoneNumberWithoutCountryCode.startsWith(countryCode)) {
        phoneNumberWithoutCountryCode = phoneNumberWithoutCountryCode.substring(countryCode.length);
      }
      return {
        'countryCode': match.group(1) ?? '',
        'localNumber': phoneNumberWithoutCountryCode,
      };
    }
    return {
      'countryCode': '',
      'localNumber': cleanedNumber,
    };
  }
}
