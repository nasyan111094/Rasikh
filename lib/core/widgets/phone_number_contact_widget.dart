import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';


import '../utils/get_asset_path.dart';
import '../utils/phone_number.dart';

class PhoneNumberContactWidget extends StatelessWidget {
  const PhoneNumberContactWidget({super.key, required this.phoneNumber});

  final String phoneNumber;
  @override
  Widget build(BuildContext context) {
    final parts = CustomPhoneNumber.separatePhoneNumbers(phoneNumber);
    return Container(
      decoration: const BoxDecoration(
        color: greyContact,
        borderRadius: BorderRadius.all(
          Radius.circular(
            20,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10.0.h,
          horizontal: 20.w,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                text: ' ${parts['localNumber'] ?? phoneNumber}',
                style: getMediumBlack14Style(),
                children: <TextSpan>[
                  if (parts['countryCode']!.isNotEmpty)
                    TextSpan(
                      text: ' (${parts['countryCode']}+)',
                      style: getRegularGreen14Style(),
                    )
                ],
              ),
            ),
            Gap(
              10.w,
            ),
            Picture(
              getAssetIcon(
                'phone.svg',
              ),
              color: heavyGreenColorNew,
            )
          ],
        ),
      ),
    );
  }
}
