import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/features/User/profile/widgets/transaction_card.dart';
import 'package:size_config/size_config.dart';

import '../../../../Shared/widgets/icon_with_bg.dart';
import '../../../../config/navigation/nav.dart';
import '../../../../config/theme/colors.dart' as colors;
import '../../../User/profile/widgets/header_capsule_appbar_widget.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(

      appBar: const HeaderCapsuleAppBar(
        title: 'المحفظة',
        icon: Icons.arrow_back_ios_rounded,
      ),

      bottomNavigationBar:    Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0.w),
        child: SizedBox(
          width: double.infinity,
          height: 45,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline, size: 18 , color: primary,),
            label:  Text('إضافة حساب جديد' , style: Theme.of(context).textTheme.titleSmall!.copyWith(color: primary),),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.primary.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),

      body: ListView(
        padding: EdgeInsets.all(16.w ),
        children: [
          // 💰 الرصيد الحالي
          _buildBalanceCard(theme, colorScheme, textTheme , context)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🟤 عنوان القسم مع الأيقونة
            Row(
              children: [
                Picture(
                  getAssetIcon("dot.svg"),
                  width: 20.h,
                  height: 20.h,
                ),
                Gap(6.w),
                Text(
                  'العمليات الأخيرة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // 🟠 زر عرض الكل
            InkWell(
              borderRadius: BorderRadius.circular(12.h),
              onTap: () {
                // TODO: هنا تحط التنقل أو الأكشن المطلوب
                print('تم الضغط على عرض الكل');
              },
              child: Row(
                children: [
                  Text(
                    'عرض الكل',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: const Color(0xFFC7A47B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                ],
              ),
            ),
          ],
        ) ,
        Gap(12.h ) ,

        TransactionCard(id: "1234567", title: "عملية سحب", amountText: " 342 ريال ", date: "12/11/2025", status: TxStatus.paid)
              .animate(delay: 100.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Picture(getAssetIcon("dot.svg") , width: 20.h , height:  20.h ,) ,
              Gap(5.w )  ,
              Text('الحسابات البنكية',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12.h),
          _buildBankAccountsCard(theme, colorScheme, textTheme , context)
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  // ------------------ 💰 الرصيد الحالي ------------------
  Widget _buildBalanceCard(
      ThemeData theme, ColorScheme colors, TextTheme text , BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.disabledColor.withOpacity(.05)),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary.withOpacity(.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Picture(getAssetIcon("wallet.svg")),
          ),
          Gap(10.h) ,
          Text('رصيدك الحالي', style: text.bodyMedium),
          const SizedBox(height: 8),
          Text(
            '1320 ريال',
            style: text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFC7A47B), // اللون الذهبي مثل الصورة
            ),
          ),
          GeneralDivider(height: 20.h,) ,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text('الرصيد المتاح',
                      style: text.bodySmall?.copyWith(color: colors.onSurface)),
                  const SizedBox(height: 4),
                  Text(
                    '950 ريال',
                    style: text.bodyMedium?.copyWith(
                        color: Colors.green, fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              Container(
                width: 1,
                height: 40,
                color: theme.disabledColor.withOpacity(.05),
              ),

              Column(
                children: [
                  Text('الرصيد المعلق',
                      style: text.bodySmall?.copyWith(color: colors.onSurface)),
                  const SizedBox(height: 4),
                  Text(
                    '370 ريال',
                    style: text.bodyMedium?.copyWith(
                        color: Colors.redAccent, fontWeight: FontWeight.w500),
                  ),
                ],
              ),

            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: ()
              {
                Nav.withdrawRequestScreen(context) ;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC7A47B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:  Text('طلب سحب',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ 🧾 العمليات الأخيرة ------------------


  Widget _buildTransactionItem(
      ThemeData theme, ColorScheme colors, TextTheme text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // حالة العملية
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('قيد المراجعة',
                style: TextStyle(color: Colors.orange, fontSize: 12)),
          ),
          const SizedBox(width: 12),

          // تفاصيل العملية
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('عملية سحب',
                    style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text('950 ريال', style: text.bodyMedium),
              ],
            ),
          ),

          // تاريخ ورقم العملية
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('#9010982',
                  style:
                      text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text('16 / 10 / 2025',
                  style:
                      text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------ 🏦 الحسابات البنكية ------------------
  Widget _buildBankAccountsCard(
      ThemeData theme, ColorScheme colors, TextTheme text , BuildContext context) {
    final accounts = [
      {'bank': 'بنك الأهلي السعودي', 'iban': 'SA1234567890123456789012'},
      {'bank': 'بنك الراجحي', 'iban': 'SA1234567890123456789012'},
    ];

    return Container(
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(16),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          // قائمة الحسابات
          ...accounts.map(
            (acc) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildBankItem(acc, colors, text),
            ),
          ),

          // زر الإضافة
          const SizedBox(height: 8),

        ],
      ),
    );
  }

  Widget _buildBankItem(
      Map<String, String> acc, ColorScheme colors, TextTheme text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleIconContainer(
            icon: "transactions.svg",
            size: 40,
            backgroundColor: const Color(0xffF7F4F0),
            iconColor: const Color(0xFFC7A47B),
            iconSize: 20,
            hasShadow: false,
          ),
         Gap(5.w) ,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(acc['bank']!,
                    style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(acc['iban']!, style: text.labelLarge),
              ],
            ),
          ),
          CircleIconContainer(
            icon: "edit.svg",
            size: 40,
            backgroundColor: Colors.green.withOpacity(.1),
            iconColor:  Colors.green,
            iconSize: 20,
            hasShadow: false,
            borderRadius: 15,

          ),
          Gap(5.w) ,
          CircleIconContainer(
            icon: "Trash_Bin.svg",
            size: 40,
            backgroundColor: Colors.red.withOpacity(.1),
            iconColor:  Colors.red,
            iconSize: 20,
            hasShadow: false,
            borderRadius: 15,
          ),
        ],
      ),
    );
  }
}
