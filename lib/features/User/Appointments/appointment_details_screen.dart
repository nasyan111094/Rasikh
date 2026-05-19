import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/widgets/general_divider.dart';

import 'package:size_config/size_config.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  const AppointmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// -------- Header ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تفاصيل الموعد',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    height: 32.h,
                    width: 32.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16.w,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Gap(20.h),

              /// -------- Lawyer Info ----------
              Text(
                'المحامي',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              Gap(8.h),

              Row(
                children: [
                  CircleAvatar(
                    radius: 22.h,
                    backgroundImage: const AssetImage('assets/images/lawyer.png'),
                  ),
                  Gap(10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'عبدالله بن فهد الشمري',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'التخصص : بيع وشراء',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Gap(24.h),

              /// -------- Description ----------
              Text(
                'وصف للاستشارة',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap(8.h),
              Text(
                'محامي متخصص يقدم استشارات قانونية شاملة للأفراد والشركات. '
                    'يمتاز بخبرة واسعة في حل القضايا المختلفة وإعداد العقود، مع '
                    'التركيز على حماية حقوق موكليه وتقديم حلول قانونية سريعة وفعالة.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                  height: 1.6,
                ),
              ),

              Gap(24.h),

              /// -------- Date & Duration ----------
              Text(
                'التاريخ والوقت والمدة',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              GeneralDivider(height: 40.h,) ,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// ----- Column 1 -----
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تاريخ الجلسة',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        Gap(4.h),
                        Text(
                          '16 \\ 08 \\ 2025',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Vertical Divider
                  Container(
                    width: 1.w,
                    height: 35.h,
                    color: Colors.grey.shade300,
                  ),

                  /// ----- Column 2 -----
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'وقت البدء',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        Gap(4.h),
                        Text(
                          '10:30 صباحاً',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Vertical Divider
                  Container(
                    width: 1.w,
                    height: 35.h,
                    color: Colors.grey.shade300,
                  ),

                  /// ----- Column 3 -----
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'مدة الجلسة',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        Gap(4.h),
                        Text(
                          '30 دقيقة',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              GeneralDivider(height: 30.h,) ,


              Gap(24.h),

              /// -------- Voice Note ----------
              Text(
                'مذكرة صوتية',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap(10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12.h),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.play_arrow_rounded,
                        size: 28.w, color: theme.colorScheme.primary),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Container(
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2.h),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '00:12',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),

              Gap(24.h),

              /// -------- Attachments ----------
              Text(
                'المرفقات',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap(12.h),
              Row(
                children: List.generate(
                  4,
                      (index) => Padding(
                    padding: EdgeInsetsDirectional.only(end: 8.w),
                    child: Container(
                      height: 64.h,
                      width: 64.w,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12.h),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/file.svg',
                          height: 30.h,
                          width: 30.w,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Gap(40.h),

              /// -------- Button ----------
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.h),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'العودة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Gap(30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow(ThemeData theme, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
