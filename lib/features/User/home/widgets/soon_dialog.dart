import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:flutter/material.dart';
import 'package:size_config/size_config.dart';

import '../../../../config/theme/colors.dart';



class SoonDialog extends StatefulWidget {
  const SoonDialog({super.key});

  @override
  State<SoonDialog> createState() => _SoonDialogState();
}

class _SoonDialogState extends State<SoonDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 10,
      actionsPadding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 30.w),
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.h)),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: greyF4,
                ),
                child: const Icon(Icons.clear)),
          ),
          Expanded(
              child: Picture(
            getAssetIcon("soon.svg"),
            fit: BoxFit.fill,
          )),
        ],
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(Loc.soon(), style: getBoldPrimary16Style()),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  Loc.soonSubtitle(),
                  textAlign: TextAlign.center,
                  style: getRegularGreyA414Style(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
