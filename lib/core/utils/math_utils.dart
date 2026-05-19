import 'dart:math';

double doubleInRange(Random source, num start, num end) {
  return source.nextDouble() * (end - start) + start;
}

double degToRad(double deg) => (deg * pi) / 180;

double radToDeg(double rad) => (rad * 180) / pi;
