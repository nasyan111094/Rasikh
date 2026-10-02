import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:size_config/size_config.dart';

class MainWidget extends StatelessWidget {
  const MainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipPath(
            clipper: SquareWithHoleClipper(),
            child: Container(
              width: 200.w,
              height: 200.h,
              color: primary,
              child: Center(
                child: Text(
                  Loc.squareText(),
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
          const Positioned(
            top: -40,
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.red,
              child: Icon(
                Icons.rocket,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SquareWithHoleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 40.0;
    Path path = Path();

    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    path.addOval(Rect.fromCircle(
      center: Offset(size.width / 2, 0),
      radius: radius,
    ));

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
