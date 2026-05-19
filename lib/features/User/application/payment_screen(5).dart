import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:rasikh/core/theme/font_weights.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';
import '../../../core/theme/sizes.dart';
import '../../../core/utils/get_asset_path.dart';
import '../../../core/widgets/auth_stepper.dart';
import '../../../core/widgets/auth_stepper.dart';
import '../../../core/widgets/general_app_bar.dart';
import '../../../core/widgets/general_divider.dart';
import 'consultation_type_screen(2).dart';

class PaymentScreen extends StatefulWidget {
  PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int currentSelectedIndex  = 0 ;




  Future<void> showOrderConfirmedDialog1(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    int secondsLeft = 10; // countdown start
    Timer? timer;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // Use StatefulBuilder to update countdown text inside dialog
        return StatefulBuilder(
          builder: (context, setState) {
            // Start countdown only once
            timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (secondsLeft > 0) {
                setState(() => secondsLeft--);
              } else {
                t.cancel();
                Navigator.pop(dialogContext); // Close the dialog
                Nav.connectingToLawyerScreen(context); // Navigate to your next screen
              }
            });

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.h),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ Lottie animation
                    Lottie.asset(
                      'assets/anims/success.json', // your Lottie success file
                      width: 120.w,
                      height: 120.h,
                      repeat: false,
                    ),
                    SizedBox(height: 12.h),

                    // Title
                    Text(
                      "تم تأكيد طلبك",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFAE895D),
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),

                    // Subtitle with countdown
                    Text(
                      "تم تأكيد طلبك... سنربطك الآن بأفضل محامي متاح (حتى $secondsLeft ثانية).",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),

                    // Optional manual close button

                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  Future<void> showOrderConfirmedDialog2(BuildContext context) async {
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Green Check Icon
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2E7D32), // green background
                  ),
                  padding: const EdgeInsets.all(18),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ Title
                Text(
                  "تم تأكيد طلبك",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFAE895D),
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // ✅ Subtitle
                Text(
                  "تم حجز موعدك بنجاح",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // ✅ Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAE895D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Nav.layout(context); // navigate to main screen
                    },
                    child: const Text(
                      "العودة للرئيسية",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const GeneralAppBar(title: "الدفع"),
        body: Column(
          children: [
            Padding(
              padding:  EdgeInsets.symmetric(vertical: 24.h , horizontal: 16.w),
              child: const AuthStepperWidget(activeStep: 5, totalSteps: 5),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:  EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    /// Payment notice container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "قم بالدفع الآن وسيتم تحويلك مباشرة إلى المحادثة مع المحامي المختص.",
                        style: textTheme.titleSmall?.copyWith(
                          color: Colors.green,
                          fontSize: 11.sp ,
                          fontWeight: fw700
                        ),
                      ),
                    ),



                    /// Service details card
                    buildAnimatedCard(
                      title: "تفاصيل الخدمة",
                      titleIconPath: "file.svg",
                      index: 1,
                      showStatus: true,
                      children: [
                        rowItem("نوع الإستشارة", "كتابيه"),
                        rowItem("التخصص", "تجارية"),
                        rowItem("مدة الجلسة", "15 دقيقة"),
                        rowItem("إسم المحامي", "فهد بن نواف الشمري", hasDivider: false),
                      ],
                    ),
                    Gap(10.h) ,
                    buildAnimatedCard(
                      title: "تفاصيل الفاتوره",
                      titleIconPath: "wallet.svg",
                      index: 1,
                      showStatus: true,
                      children: [
                        rowItem("السعر الأساسي", "1200 ريال"),
                        rowItem("الضريبه", "0 ريال"),
                        rowItem("الإجمالي", "1200 ريال", hasDivider: false , valueColor: theme.colorScheme.primary),
                      ],
                    ),
                    /// Payment methods header
                    Text(
                      "طرق الدفع المتاحة*",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "اختر طريقة الدفع:",
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// Apple Pay option
                    _PaymentOption(

                      selected: currentSelectedIndex == 0? true : false , title: 'أبل باي', assetPath: 'apple_pay.png', onTap: () { setState(() {
                        currentSelectedIndex = 0  ;
                      }); },
                    ),
                    const SizedBox(height: 12),

                    /// Mada/Visa/Mastercard option
                    _PaymentOption(

                      selected: currentSelectedIndex == 1? true : false, title: 'مدي / فيزا / ماستر كارد', assetPath: 'mada_visa_master.png', onTap: () { setState(() {
                        currentSelectedIndex = 1 ;
                      });  },
                    ),


                    Gap(10.h) ,
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 16.w,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12.h),
                      ),
                      child: Text(
                        'لحماية حقوقك وضمان جودة الخدمة، تأكد من إتمام الدفع داخل المنصة فقط. '
                            'لسنا مسؤولين عن أي مبالغ تدفع للمحامين خارج المنصة.',
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: 12 .sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ) ,
                    Gap(10.h) ,
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0 , vertical: 3),
                child: ElevatedButton(
                  onPressed: ()
                  {
                    if(selectedTypeIndex == 0 || selectedTypeIndex == 1 )
                    showOrderConfirmedDialog1(context) ;
                    else
                     showOrderConfirmedDialog2(context) ;



                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "ادفع الآن",
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated Card (right-to-left slide + staggered children)
Widget buildAnimatedCard({
  required String title,
  String ? titleIconPath ,
  required List<Widget> children,
  required int index,
  bool showStatus = false,
}) {
  return AnimationConfiguration.staggeredList(
    position: index,
    duration: const Duration(milliseconds: 500),
    child: SlideAnimation(
      horizontalOffset: 120.0,
      curve: Curves.easeOutCubic,
      child: FadeInAnimation(
        child: Builder(builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final textTheme = theme.textTheme;

          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(12.h),
              border: Border.all(color: theme.disabledColor.withOpacity(.05),),

            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (titleIconPath!= null)
                      Container(

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.h),
                          color: theme.colorScheme.primary.withOpacity(.1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Picture(
                            getAssetIcon(titleIconPath),
                            width: 20.h,
                            height: 20.h,
                            fit: BoxFit.cover,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    Gap(10.w),
                    Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold , color: theme.colorScheme.primary)),
                  ],
                ),
                GeneralDivider(height: h20),
                AnimationLimiter(
                  child: Column(
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 400),
                      childAnimationBuilder: (child) => SlideAnimation(
                        horizontalOffset: 60.0,
                        curve: Curves.easeOut,
                        child: FadeInAnimation(child: child),
                      ),
                      children: children,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    ),
  );
}

/// Info Row inside card
Widget rowItem(
    String label,
    String value, {
      bool hasDivider = true,
      bool isPrice = false,
      String? iconPath,
      bool? blackDivider = false,
      Color? valueColor,
    }) {
  return Builder(builder: (context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Row(
          children: [
            if (iconPath != null)
              Picture(
                getAssetIcon(iconPath),
                width: 20.h,
                height: 20.h,
                fit: BoxFit.cover,
                color: colorScheme.onSurfaceVariant,
              ),
            Gap(6.w),
            Text(
              label,
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: valueColor ?? colorScheme.onSurface,
                    ),
                  ),
                  if (isPrice)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SvgPicture.asset(
                        "assets/icons/sr.svg",
                        width: 20.h,
                        height: 20.h,
                        color: valueColor ?? colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        hasDivider ?  GeneralDivider(height: 16.h,) : const SizedBox(),
      ],
    );
  });
}

class _PaymentOption extends StatelessWidget {
  final String title;
  final String assetPath;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.title,
    required this.assetPath,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colorScheme.primary : theme.colorScheme.surface,
            width: selected ? 1 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                color: selected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer() ,
            Picture(
              getAssetImage(assetPath) ,
              width: 150.w,
              height: 40.h,
            ),
    
            
         
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off_outlined,
              color: selected ? colorScheme.primary : colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

