import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/theme.dart';
import 'package:size_config/size_config.dart';



class InterlacedAvatars extends StatelessWidget {
  InterlacedAvatars({super.key, required this.images});

  final List<String> images;

  static const int maxAvatarsNumber = 4;

  int get avatarsNumber => images.length.clamp(0, maxAvatarsNumber);
  final imageSize = 24.w;
  final imageGap = 16.w;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox();
    }
    if (images.length == 1) {
      return buildImage(0);
    }
    return SizedBox(
      width: ((avatarsNumber + 1) * imageSize) - ((avatarsNumber - 1) * imageGap) + (13.w),
      height: imageSize,
      child: Stack(
        children: <Widget>[
          for (int i = 0; i < avatarsNumber; i++)
            PositionedDirectional(
              start: i * imageGap,
              bottom: 0,
              top: 0,
              child: buildImage(i),
            ),
        ],
      ),
    );
  }

  Container buildImage(int i) {
    final isEnd = (avatarsNumber >= maxAvatarsNumber) && (i == avatarsNumber - 1);
    return Container(
      width: imageSize,
      height: imageSize,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsetsDirectional.only(start: isEnd ? 10.w : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isEnd ? white : null,
        border: !isEnd
            ? null
            : Border.all(
                color: primary,
                width: 1,
              ),
        image: isEnd
            ? null
            : DecorationImage(
                image: NetworkImage(images[i]),
                fit: BoxFit.cover,
              ),
      ),
      alignment: Alignment.center,
      child: isEnd
          ? Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '+${images.length - (maxAvatarsNumber - 1)}',
                style: TextStyle(
                  fontFamily: numbersFontFamily,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : null,
    );
  }
}
