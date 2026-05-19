import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/picture.dart';

import 'package:size_config/size_config.dart';
import '../../../core/widgets/auth_stepper.dart';
import '../../../core/widgets/general_option_card.dart';
import 'dialogs/ChooseLawyerMethodDialog.dart';
// reuse the previous general widget

class ConsultationDetailsScreen extends StatefulWidget {
  const ConsultationDetailsScreen({super.key});

  @override
  State<ConsultationDetailsScreen> createState() =>
      _ConsultationDetailsScreenState();
}

class _ConsultationDetailsScreenState extends State<ConsultationDetailsScreen> {
  String selectedDuration = '15';
  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: GeneralAppBar(title: "تفاصيل الإستشارة"),
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding:  EdgeInsets.symmetric(vertical: 24.h , horizontal: 16.w ),
              child: AuthStepperWidget( activeStep: 3, totalSteps: 5,),
            )   ,

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal:  16.w),
                child: ListView(
                  children: [
                    // ---------------- Duration Selection ----------------
                    Text(
                      'اختر مدة الاستشارة *',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 12.h),

                    OptionCard(
                      value: '15',
                      isHorizontal: true ,
                      icon: Icon(
                        Icons.access_time,
                        color: selectedDuration == '15'
                            ? colorScheme.primary
                            : theme.hintColor,
                      ),
                      title: '15 دقيقة',
                      subtitle: '150 ريال',
                      isSelected: selectedDuration == '15',
                      onTap: () => setState(() => selectedDuration = '15'),
                    ),
                    OptionCard(
                      value: '30',
                      isHorizontal: true ,
                      icon: Icon(
                        Icons.access_time,
                        color: selectedDuration == '30'
                            ? colorScheme.primary
                            : theme.hintColor,
                      ),
                      title: '30 دقيقة',
                      subtitle: '250 ريال',
                      isSelected: selectedDuration == '30',
                      onTap: () => setState(() => selectedDuration = '30'),
                    ),
                    OptionCard(
                      value: '45',
                      isHorizontal: true ,
                      icon: Icon(
                        Icons.access_time,
                        color: selectedDuration == '45'
                            ? colorScheme.primary
                            : theme.hintColor,
                      ),
                      title: '45 دقيقة',
                      subtitle: '300 ريال',
                      isSelected: selectedDuration == '45',
                      onTap: () => setState(() => selectedDuration = '45'),
                    ),

                    SizedBox(height: 24.h),

                    // ---------------- Title Field ----------------
                    Text(
                      'عنوان الاستشارة *',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: titleController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'مثال: نزاع عقد إيجار لشقة سكنية',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.h),
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // ---------------- Details Field ----------------
                    Text(
                      'تفاصيل الاستشارة *',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: detailsController,
                      maxLines: 5,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'اكتب هنا ...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.h),
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ---------------- Voice Note ----------------
                    Text(
                      'مذكرة صوتية',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(12.h),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'إمكانية تسجيل صوتي أقصى مدة 5 دقائق',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: colorScheme.primary,
                            radius: 20.h,
                            child: Picture(getAssetIcon("mic.svg")),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ---------------- Attachments ----------------
                    Text(
                      'المرفقات',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.dividerColor,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12.h),

                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Picture(getAssetIcon("upload.svg") , width: 40.h,height: 40.h,) ,
                          SizedBox(height: 20.h),
                          Text(
                            'ارفع ملفك من هنا',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'صيغ MP4، PDF، PNG، JPEG بحد أقصى 15 ميجابايت.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20.h),
                          OutlinedButton(
                            onPressed: () {
                              // handle file upload
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: theme.dividerColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.h),
                              ),
                            ),
                            child: Text(
                              'اختر ملف',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // ---------------- Next Button ----------------

                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0.w ),
              child: SizedBox(
                height: 48.h,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.h),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const ChooseLawyerMethodDialog(),
                    );
                  },
                  child: Text(
                    'التالي',
                    style: theme.textTheme.titleMedium?.copyWith(
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
