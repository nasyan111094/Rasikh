import 'package:rasikh/config/localization/loc_keys.dart';

String? getArabicNumber(int index) {
  String? r;
  final i = index + 1;
  final String x1 = Loc.ordinalFirst();
  final String x2 = Loc.ordinalSecond();
  final String x3 = Loc.ordinalThird();
  final String x4 = Loc.ordinalFourth();
  final String x5 = Loc.ordinalFifth();
  final String x6 = Loc.ordinalSixth();
  final String x7 = Loc.ordinalSeventh();
  final String x8 = Loc.ordinalEighth();
  final String x9 = Loc.ordinalNinth();
  final String x10 = Loc.ordinalTenth();
  final String x20 = Loc.ordinalTwentieth();
  final String x30 = Loc.ordinalThirtieth();
  final String x40 = Loc.ordinalFortieth();
  final String x50 = Loc.ordinalFiftieth();
  final String x60 = Loc.ordinalSixtieth();
  final String x70 = Loc.ordinalSeventieth();
  final String x80 = Loc.ordinalEightieth();
  final String x90 = Loc.ordinalNinetieth();
  final String x100 = Loc.ordinalHundredth();
  final x = [
    '',
    x1,
    x2,
    x3,
    x4,
    x5,
    x6,
    x7,
    x8,
    x9,
    x10,
  ];
  final xx = [
    '',
    x10,
    x20,
    x30,
    x40,
    x50,
    x60,
    x70,
    x80,
    x90,
  ];
  if (i <= 10) {
    return x[i];
  }
  if (i < 100) {
    final n = i % 10;
    final nn = i ~/ 10;
    if (nn == 1) {
      if (n == 1) {
        return Loc.ordinalEleventh();
      }
      return Loc.ordinalTeen(x[n]);
    }
    if (n == 0) {
      return xx[nn];
    }
    return Loc.ordinalCompound(n == 1 ? Loc.ordinalOne() : x[n], xx[nn]);
  }
  if (i == 100) {
    return x100;
  }
  return r;
}
