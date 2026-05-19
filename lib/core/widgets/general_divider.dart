import 'package:flutter/material.dart';

class GeneralDivider extends StatelessWidget {
  final Color? color;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final double? height;

  const GeneralDivider({
    super.key,
    this.color, // remove fixed default color
    this.thickness = 1.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.height = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Divider(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: theme.disabledColor.withOpacity(.05),
    );
  }
}
