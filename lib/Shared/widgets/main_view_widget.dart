import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:size_config/size_config.dart';

class MainViewContainer extends StatelessWidget {
  const MainViewContainer({
    super.key,
    required this.mainWidget,
    required this.appBarHeight,
    this.cardHeight,
    this.position,
    this.titleWidget,
    required this.cardWidth,
  });

  final Widget mainWidget;
  final double appBarHeight;
  final double? cardHeight;
  final double cardWidth;
  final double? position;
  final Widget? titleWidget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PositionedDirectional(
          top: 0,
          start: 0,
          end: 0,
          child: SvgPicture.asset(
            'auth_bg.svg',
            fit: BoxFit.fill,
          ),
        ),
        if (titleWidget != null)
          PositionedDirectional(
            top: 30.h,
            start: 0,
            end: 0,
            child: SizedBox(child: titleWidget),
          ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.primaryContainer,
                height: cardHeight ?? 500.h,
                child: mainWidget,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
