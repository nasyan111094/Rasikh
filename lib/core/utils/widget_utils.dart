import 'package:flutter/material.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import 'get_asset_path.dart';

Offset getWidgetPosition(GlobalKey key) {
  final renderObject = key.currentContext!.findRenderObject() as RenderBox;
  return renderObject.localToGlobal(Offset.zero);
}

Size getWidgetSize(GlobalKey key) {
  final renderObject = key.currentContext!.findRenderObject() as RenderBox;
  return renderObject.size;
}

Widget getDefaultAppPlaceHolder({double width = 20.0, double height = 20.0}) {
  return Picture(
    getAssetImage('goblin_pp.svg'),
    width: width,
    height: height,
    fit: BoxFit.cover,
  );
}

Size getTextSize({
  required BuildContext context,
  required String text,
  TextStyle? style,
  int? maxLines,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: maxLines,
    textScaler: MediaQuery.of(context).textScaler,
    textDirection: Directionality.of(context),
  );
  painter.layout();
  return painter.size;
}

double getBorderRadius() => 30;

double getLowBorderRadius() => 15;
double getCardRadius() => 20;

//fixes hero text style
Widget flightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) =>
    DefaultTextStyle(
      style: DefaultTextStyle.of(toHeroContext).style,
      child: toHeroContext.widget,
    );

enum BoxShadowElevation {
  k0,
  k1,
  k2,
  k3,
  k4,
  k6,
  k8,
  k9,
  k12,
  k16,
  k24,
}

List<BoxShadow> getCustomBoxShadows(BoxShadowElevation elevation,
        [Color? color]) =>
    kElevationToShadow[int.tryParse(elevation.name.replaceFirst('k', ''))]
        ?.map((e) => BoxShadow(
              color: color ?? Colors.black.withOpacity(.075),
              offset: e.offset,
              blurStyle: e.blurStyle,
              blurRadius: e.blurRadius,
              spreadRadius: e.spreadRadius,
            ))
        .toList() ??
    [];

extension WidgetX on Widget {
  Widget get withPadding => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: this,
      );

  Widget get asSliver => SliverToBoxAdapter(
        child: this,
      );
}
