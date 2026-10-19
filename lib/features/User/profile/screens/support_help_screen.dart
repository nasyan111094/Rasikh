import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:size_config/size_config.dart';


import '../../../../config/theme/colors.dart';
import '../../../../core/widgets/general_app_bar.dart';
import '../widgets/header_capsule_appbar_widget.dart';
import '../widgets/support_action_row.dart';
import 'question_screen.dart';
import 'policy_text_screen.dart';
import 'contact_us_screen.dart';

class SupportHelpScreen extends StatelessWidget {
  const SupportHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar:  GeneralAppBar(title: Loc.supportAndHelp()),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        children: [
          SizedBox(height: 9.h),

          SupportActionRow(
            leading: SvgPicture.asset(
              'assets/icons/Question_Circle.svg',
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
            ),
            label: Loc.faq(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FaqScreen(),
                ),
              );
            },
          ),

          GeneralDivider(
            color: greyFA,
            height: 10.h,
          ),

          SupportActionRow(
            leading: SvgPicture.asset(
              'assets/icons/Call_Chat_Rounded.svg',
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
            ),
            label: Loc.contactUs(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ContactUsScreen(),
                ),
              );
            },
          ),
          GeneralDivider(
            color: greyFA,
            height: 10.h,
          ),

          SupportActionRow(
            leading: SvgPicture.asset(
              'assets/icons/Notebook.svg',
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
            ),
            label: Loc.termsOfUse(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PolicyTextScreen(
                    pageTitle: Loc.termsOfUse(),
                    sections: [
                      PolicySection(
                        title: Loc.termsOfUseAlt(),
                        body:
                        Loc.termsOfUseSummary(),
                      ),
                      PolicySection(
                        title: Loc.securityAndCommunication(),
                        body:
                        Loc.securitySummary(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          GeneralDivider(
            color: greyFA,
            height: 10.h,
          ),

          SupportActionRow(
            leading: SvgPicture.asset(
              'assets/icons/Shield.svg',
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
            ),
            label: Loc.privacyPolicy(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PolicyTextScreen(
                    pageTitle: Loc.privacyPolicy(),
                    sections: [
                      PolicySection(
                        title: Loc.privacyPolicy(),
                        body:
                        Loc.privacySummary(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
