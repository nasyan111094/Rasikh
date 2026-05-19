String? getArabicNumber(int index) {
  String? r;
  final i = index + 1;
  const String x1 = 'الاول';
  const String x2 = 'الثاني';
  const String x3 = 'الثالث';
  const String x4 = 'الرابع';
  const String x5 = 'الخامس';
  const String x6 = 'السادس';
  const String x7 = 'السابع';
  const String x8 = 'الثامن';
  const String x9 = 'التاسع';
  const String x10 = 'العاشر';
  const String x20 = 'العشرون';
  const String x30 = 'الثلاثون';
  const String x40 = 'الاربعون';
  const String x50 = 'الخمسون';
  const String x60 = 'الستون';
  const String x70 = 'السبعون';
  const String x80 = 'الثمانون';
  const String x90 = 'التسعون';
  const String x100 = 'المائة';
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
        return 'الاحدي عشر';
      }
      return '${x[n]} عشر';
    }
    if (n == 0) {
      return xx[nn];
    }
    return '${n == 1 ? 'الواحد' : x[n]} و ${xx[nn]}';
  }
  if (i == 100) {
    return x100;
  }
  return r;
}
