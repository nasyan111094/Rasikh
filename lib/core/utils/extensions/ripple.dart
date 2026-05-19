import 'package:flutter/material.dart';

extension WidgetModifier on Widget {
  Widget ripple({Function()? onPressed, BorderRadiusGeometry borderRadius = const BorderRadius.all(Radius.circular(10))}) => Stack(
        children: <Widget>[
          this,
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: TextButton(
              onPressed: onPressed,
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                  borderRadius: borderRadius,
                )),
                overlayColor: WidgetStateColor.resolveWith((states) => Colors.grey.withOpacity(0.2)),
              ),
              child: Container(
                decoration: BoxDecoration(borderRadius: borderRadius),
              ),
            ),
          )
        ],
      );
}
