import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import '../../../../Shared/widgets/account_item_widget.dart' show AccountItem;
import '../../../../config/navigation/nav.dart';
import '../../../User/profile/screens/contact_us_screen.dart';
import '../../../User/profile/screens/policy_text_screen.dart';
import '../../../User/profile/widgets/dialog_widget.dart';


class HelpingCenterScreen extends StatelessWidget {
  const HelpingCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final textSecondary = theme.textTheme.bodyMedium?.color?.withOpacity(0.7);
    final dividerColor = theme.dividerColor.withOpacity(0.2);
    final iconColor = textSecondary;
    final divider = Divider(color: dividerColor, thickness: 1, height: 1);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: GeneralAppBar(title: 'ملفي الشخصي'),
        body: SafeArea(
          child: Column(
            children: [
              divider,
              const SizedBox(height: 20),
              LawyerProfileBody(divider: divider),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class LawyerProfileBody extends StatelessWidget {
  const LawyerProfileBody({
    super.key,
    required this.divider,
  });

  final Divider divider;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          AccountItem(
            svgAsset: 'assets/icons/edit.svg',

            label:"تواصل معنا",
            trailingChevronRight: true,
            onTap: () =>Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ContactUsScreen(),
              ),
            ),
          ),
          divider,
          AccountItem(
            svgAsset: 'assets/icons/user_id.svg',

            label: 'سياسية الإستخدام',
            trailingChevronRight: true,
            onTap: () =>    Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PolicyTextScreen(
                  pageTitle: 'سياسة الإستخدام',
                  sections: [
                    PolicySection(
                      title: 'سياسة الاستخدام',
                      body:
                      'باستخدامك للتطبيق فإنك تقر بالالتزام بالقوانين المنظمة وعدم إساءة استخدام الخدمات أو العبث بآليات النظام...',
                    ),
                    PolicySection(
                      title: 'الأمان والتواصل',
                      body:
                      'نحرص على تطبيق ضوابط الأمان وحماية الحسابات. قد يتم التواصل للتحقق من نشاطات غير اعتيادية...',
                    ),
                  ],
                ),
              ),
            ) ,
          ),
          divider,
          AccountItem(
            svgAsset: 'assets/icons/mobile.svg',
            label: 'سياسة الخصوصيه',
            trailingChevronRight: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PolicyTextScreen(
                    pageTitle: 'سياسة الخصوصية',
                    sections: [
                      PolicySection(
                        title: 'سياسة الخصوصية',
                        body:
                        'نولي أهمية كبيرة لخصوصية المستخدم. قد نجمع بيانات لازمة لتحسين الخدمة وفق الأنظمة المعمول بها...',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        ],
      ),
    );
  }
}
