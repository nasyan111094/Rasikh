import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart' show getAssetIcon;
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:rasikh/core/widgets/general_option_card.dart';
import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';
import '../../../config/theme/colors.dart';
import '../../../core/widgets/picture.dart' show Picture;
import 'end_session_screen.dart';

class EndSessionScreen extends StatelessWidget {
  const EndSessionScreen({super.key});




  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GeneralAppBar(
        title: 'إنهاء الجلسة',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(12.h),
          GeneralOptionCard(
            title: 'فتح منازعة',
            icon:  Picture(getAssetIcon("doc_add.svg") , width: 25.h,height: 25.h,) ,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const OpenDisputeDialog(),
              );
            },
          ),
          GeneralDivider() ,
          GeneralOptionCard(
            title: 'تقييم الجلسة',
            icon: Picture(getAssetIcon("Stars.svg") , width: 25.h,height: 25.h,) ,
            onTap: () {
              showRateExperienceBottomSheet(context) ;

            },
          ),
          const Spacer(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16.h ,left: 16.w ,right: 16.w),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.h),
                    ),
                  ),
                  onPressed: () {
                    // TODO: navigate back to home
                    Nav.layout(context);
                  },
                  child: Text(
                    'الرجوع للرئيسية',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class GeneralOptionCard extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback? onTap;

  const GeneralOptionCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0.h),


        ),
        child: Padding(
          padding:  EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            children: [
              icon ,

              Gap(8.w),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Gap(8.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.w,
                color: theme.iconTheme.color?.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class OpenDisputeDialog extends StatefulWidget {
  const OpenDisputeDialog({super.key});

  @override
  State<OpenDisputeDialog> createState() => _OpenDisputeDialogState();
}

class _OpenDisputeDialogState extends State<OpenDisputeDialog> {
  String? selectedReason;
  final TextEditingController detailsController = TextEditingController();

  final List<String> disputeReasons = [
    'المعلم لم يحضر',
    'خدمة غير مرضية',
    'مشكلة في الوقت',
    'أخرى',
  ];

  Future<void> SendDisputeDialog(BuildContext context) async {
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
                  "تم إرسال طلبك , سنراجع طلبك خلال 72 –48 ساعة.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // ✅ Button

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

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.h),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    'فتح منازعة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: greyFA,
                    child: IconButton(
                      icon:  Icon(Icons.close , color: Colors.black,),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 20,
                    ),
                  ),// balance close button width
                ],
              ),
              Gap(16.h),

              /// --- Reason Dropdown ---
              Text(
                'سبب المنازعة *',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Gap(6.h),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.h),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal  :10.w),
                      child: Picture(getAssetIcon("doc_add.svg") , width: 25.h,height: 25.h,),
                    ) ,
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,

                        ),

                        icon: Padding(
                          padding:  EdgeInsets.symmetric(horizontal  :10.w),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: theme.iconTheme.color?.withOpacity(0.6),
                          ),
                        ),
                        value: selectedReason,
                        hint: Text(
                          'اختر سبب المنازعة',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        dropdownColor: theme.scaffoldBackgroundColor,
                        items: disputeReasons.map((reason) {
                          return DropdownMenuItem<String>(
                            value: reason,
                            child: Text(reason),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedReason = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Gap(16.h),

              /// --- Details TextField ---
              Text(
                'تفاصيل المنازعة *',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Gap(6.h),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.h),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.5),
                  ),
                ),
                child: TextField(
                  controller: detailsController,
                  maxLines: 5,

                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'اكتب هنا ...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                  ),
                ),
              ),

              Gap(20.h),

              /// --- Submit Button ---
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    theme.colorScheme.primary.withOpacity(0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.h),
                    ),
                  ),
                  onPressed: () {
                    if (selectedReason == null ||
                        detailsController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('الرجاء إدخال جميع الحقول المطلوبة'),
                        ),
                      );
                      return;
                    }

                    // TODO: handle dispute submission
                    Navigator.pop(context);
                    SendDisputeDialog( context)  ;
                  },
                  child: Text(
                    'إرسال الآن!',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


void showRateExperienceBottomSheet(BuildContext context) {
  final theme = Theme.of(context);
  final textTheme = theme.textTheme;
  double rating = 0.0;
  final TextEditingController feedbackController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    
    backgroundColor: theme.scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: CircleAvatar(
                      backgroundColor:greyFA,
                      child: IconButton(
                        icon: Icon(Icons.close , color: Colors.black,),
                                       onPressed:()=> Navigator.pop(context),
                      ),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                    backgroundColor: Colors.transparent,
                  ),
                  const Gap(12),
                  Text(
                    'قَيِّم تجربتك معنا',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(6),
                  Text(
                    'تقييمك يعكس مدى رضاك ويساعدنا على التحسين.',
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  GeneralDivider(height: 26.h,) ,
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    glowColor: Colors.yellow,
                    glow: true ,
              
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    unratedColor: theme.disabledColor.withOpacity(0.2),
                    itemBuilder: (context, _) => Picture(getAssetIcon("star.svg") , color: theme.primaryColor),
                    onRatingUpdate: (r) => setState(() => rating = r),
                  ),
                  const Gap(20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'كيف كانت تجربتك؟ أحكي لنا',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  const Gap(8),
                  TextField(
                    controller: feedbackController,
                    maxLines: 3,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'اكتب هنا ...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: greyFA,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: greyFA,
                        ),
                      ),
                      enabledBorder:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.disabledColor.withOpacity(.05),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                  const Gap(20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (rating == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('الرجاء اختيار تقييم')),
                          );
                          return;
                        }
              
                        // TODO: handle submit logic here (API call, etc.)
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم إرسال تقييمك بنجاح')),
                        );
                      },
                      child: Text(
                        'إرسال الآن',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
