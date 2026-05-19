import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import '../utils/get_asset_path.dart';

class UpdateContactsCardWidget extends StatelessWidget {
  const UpdateContactsCardWidget({
    super.key,
    required this.phoneNumber,
    required this.personName,
    this.imageUrl,
  });

  final String phoneNumber;
  final String personName;

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 24.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl == null)
            Picture(
              getAssetIcon('person-tie.svg'),
              width: 55.w,
              height: 55.h,
            ),
          Gap(20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  personName,
                  style: getBoldBlack20Style(),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                Row(
                  children: [
                    Picture(
                      color: primary,
                      getAssetIcon(
                        'phone.svg',
                      ),
                    ),
                    Gap(10.w),
                    Text(
                      phoneNumber,
                      style: getRegularBlack14Style(),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
