

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import '../../config/theme/colors.dart';
import '../utils/get_asset_path.dart';

class AppDottedBorder extends StatelessWidget {
   AppDottedBorder({super.key , required this.child});

  Widget child  ;

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: borderColor,
      strokeWidth: 1.2,
      dashPattern: const [3, 3],
      borderType: BorderType.RRect,
      radius: const Radius.circular(10),
      child: child,
    );
  }
}
