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
          // Custom square with a hole at the top
          ClipPath(
            clipper: SquareWithHoleClipper(),
            child: Container(
              width: 200.w,
              height: 200.h,
              color: primary,
              child: const Center(
                child: Text(
                  'Square Text', // Text inside the square
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
          // Circle positioned inside the "hole" at the top center
          const Positioned(
            top: -40, // Move the circle to the top
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.red,
              child: Icon(
                Icons.rocket, // Boost icon inside the circle
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

// Custom Clipper to create the square with a "hole" at the top center
class SquareWithHoleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 40.0; // Radius of the hole
    Path path = Path();

    // Draw the square
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create the cut-out at the top center
    path.addOval(Rect.fromCircle(
      center: Offset(size.width / 2, 0), // Top center of the square
      radius: radius,
    ));

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
