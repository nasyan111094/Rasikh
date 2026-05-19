import 'package:rasikh/core/utils/vaildData/valid_data.dart';

String formatDuration(Duration duration) {
  String negativeSign = duration.isNegative ? '-' : '';
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
  return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

DateTime? parseDateTime(String? src) {
  try {
    if (!validString(src)) {
      throw '$src';
    }
    src!;
    final srcInt = int.tryParse(src);
    if (srcInt != null) {
      return DateTime.fromMillisecondsSinceEpoch(srcInt);
    }
    return DateTime.tryParse(src);
  } catch (e) {
    return null;
  }
}
