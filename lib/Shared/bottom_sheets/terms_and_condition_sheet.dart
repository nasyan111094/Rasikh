import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';

import '../../config/localization/loc_keys.dart';

class TermsAndCondSheets extends StatelessWidget {
  const TermsAndCondSheets({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 30.w),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(
              10.h,
            ),
            Text(
              Loc.terms_and_conditions(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Gap(
              20.h,
            ),
            Text(
              textAlign: TextAlign.right,
              Loc.terms_and_condition_content(),
            ),
          ],
        ),
      ),
    );
  }
}
