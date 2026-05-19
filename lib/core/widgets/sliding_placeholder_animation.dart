import 'dart:ui';

import 'package:flutter/material.dart';

class SlidingPlaceholderAnimation extends StatelessWidget {
  const SlidingPlaceholderAnimation({
    super.key,
    required this.child,
    required this.animation,
    required this.placeholder,
    this.isGrid = false,
  });

  final Widget child;
  final Widget placeholder;
  final Animation<double> animation;
  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.drive(CurveTween(curve: Curves.easeInOut)).value;
        return Stack(
          alignment: Alignment.center,
          fit: isGrid ? StackFit.expand : StackFit.loose,
          children: [
            Transform.translate(
              offset: Offset(lerpDouble(0, -screenSize.width, value) ?? 0, 0),
              child: Opacity(
                opacity: lerpDouble(1, 0, value)?.clamp(0, 1) ?? 0,
                child: placeholder,
              ),
            ),
            Transform.translate(
              offset: Offset(lerpDouble(screenSize.width, 0, value) ?? 0, 0),
              child: Opacity(
                opacity: lerpDouble(0, 1, value)?.clamp(0, 1) ?? 0,
                child: child!,
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}
