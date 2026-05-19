import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:size_config/size_config.dart';


import '../../../../config/theme/colors.dart';
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
      appBar: const HeaderCapsuleAppBar(title: 'الدعم والمساعدة'),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        children: [
          SizedBox(height: 9.h),

          /// الأسئلة الشائعة
          SupportActionRow(
            leading: SvgPicture.asset(
              'assets/icons/Question_Circle.svg',
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
            ),
            label: 'الأسئلة الشائعة',
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

          /// تواصل معنا
          SupportActionRow(
            leading: SvgPicture.asset(
              'assets/icons/Call_Chat_Rounded.svg',
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
            ),
            label: 'تواصل معنا',
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

          /// سياسة الإستخدام
          SupportActionRow(
            leading: SvgPicture.asset(
              'assets/icons/Notebook.svg',
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
            ),
            label: 'سياسة الإستخدام',
            onTap: () {
              Navigator.of(context).push(
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
              );
            },
          ),
          GeneralDivider(
            color: greyFA,
            height: 10.h,
          ),

          /// سياسة الخصوصية
          SupportActionRow(
            leading: SvgPicture.asset(
              'assets/icons/Shield.svg',
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
            ),
            label: 'سياسة الخصوصية',
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

          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
