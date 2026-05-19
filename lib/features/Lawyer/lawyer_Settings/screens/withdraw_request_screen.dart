import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';
import '../../../../Shared/widgets/icon_with_bg.dart';
import '../../../User/profile/widgets/header_capsule_appbar_widget.dart';

class WithdrawRequestScreen extends StatelessWidget {
  const WithdrawRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SafeArea(
      child: Scaffold(
        appBar: const HeaderCapsuleAppBar(
          title: 'طلب سحب',
          icon: Icons.arrow_back_ios_rounded,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 💰 الرصيد المتاح للسحب
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12.h),
                  border: Border.all(color: theme.disabledColor.withOpacity(.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleIconContainer(
                          icon: "wallet.svg",
                          backgroundColor: const Color(0xffF7F4F0),
                          iconColor: const Color(0xFFC7A47B),
                          size: 40.w,
                          iconSize: 20.w,
                          hasShadow: false,
                        ),
                        Gap(10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "الرصيد المتاح للسحب",
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Gap(3.h),
                            Text(
                              "950 ريال",
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFC7A47B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      
              Gap(40.h),
      
              // 🏦 اختيار الحساب البنكي
              Text(
                "اختر الحساب البنكي *",
                style: textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap(15.h),
              Container(
                height: 60.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.h),
                  border: Border.all(color: theme.disabledColor.withOpacity(.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance, color: Colors.grey),
                    Gap(8.w),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: 'بنك الأهلي السعودي',
                          items: const [
                            DropdownMenuItem(
                              value: 'بنك الأهلي السعودي',
                              child: Text('بنك الأهلي السعودي'),
                            ),
                            DropdownMenuItem(
                              value: 'بنك الراجحي',
                              child: Text('بنك الراجحي'),
                            ),
                          ],
                          onChanged: (value) {},
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      
              Gap(40.h),
      
              // 💵 المبلغ المطلوب للسحب
              Text(
                "المبلغ المطلوب للسحب *",
                style: textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap(20.h),
              Container(
                height: 60.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.h),
                  border: Border.all(color: theme.disabledColor.withOpacity(.2)),
                ),
                child: Row(
                  children: [
                    Picture(
                      getAssetIcon("riyal.svg"),
                      width: 18.w,
                      height: 18.w,
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.00',
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        style: textTheme.bodyMedium,
                      ),
                    ),

                  ],
                ),
              ),
      
              const Spacer(),
      
              // 🟡 زر تأكيد السحب
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC7A47B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.h),
                    ),
                  ),
                  child: Text(
                    'تأكيد السحب',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Gap(10.h),
            ],
          ),
        ),
      ),
    );
  }
}
