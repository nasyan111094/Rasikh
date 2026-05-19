import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/navigation/nav.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/picture.dart';

import 'package:size_config/size_config.dart';
import '../../../core/widgets/auth_stepper.dart';
import '../../../core/widgets/general_option_card.dart';

int selectedTypeIndex = 0 ;

class ConsultationTypeScreen extends StatefulWidget {
  const ConsultationTypeScreen({super.key});

  @override
  State<ConsultationTypeScreen> createState() => _ConsultationTypeScreenState();
}

class _ConsultationTypeScreenState extends State<ConsultationTypeScreen> {
  String selectedType = 'instant'; // default selection

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: GeneralAppBar(title: "إختر نوع الإستشارة"),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal:  16.w),
          child: Column(
            children: [

              Padding(
                padding:  EdgeInsets.symmetric(vertical: 24.h ),
                child: AuthStepperWidget( activeStep: 2, totalSteps: 5,),
              )   ,

              Expanded(
                child: ListView(
                  children: [
                    OptionCard(
                      value: 'instant',
                      icon: Picture(getAssetIcon("Immediately.svg") , width: 20.h,height: 20.h, color: selectedType == 'instant'? colorScheme.primary : theme.dividerColor),
                      title: 'استشارات فورية',
                      subtitle:
                      'ادفع الآن وسيتم توصيلك بأقرب محامٍ متاح في تخصصك.',
                      isSelected: selectedType == 'instant',
                      onTap: () {
                        setState(() => selectedType = 'instant');
                        selectedTypeIndex = 0 ;
                      },
                    ),
                    OptionCard(
                      value: 'written',
                      icon: Picture(getAssetIcon("chat.svg") , width: 20.h,height: 20.h, color: selectedType == 'written'? colorScheme.primary : theme.dividerColor),
                      title: 'استشارات كتابية',
                      subtitle:
                      'اكتب تفاصيلك وأرفق مستنداتك، ويتواصل معك المحامي في المحادثة.',
                      isSelected: selectedType == 'written',
                      onTap: () {
                        setState(() => selectedType = 'written');
                        selectedTypeIndex = 1 ;
                      },
                    ),
                    OptionCard(
                      value: 'scheduled',
                      icon: Picture(getAssetIcon("Calendar.svg") , width:20.h,height: 20.h, color: selectedType == 'scheduled'? colorScheme.primary : theme.dividerColor),
                      title: 'استشارات مجدولة',
                      subtitle:
                      'اختر موعدًا محددًا للتواصل صوتيًا أو بالفيديو.',
                      isSelected: selectedType == 'scheduled',
                      onTap: () {
                        setState(() => selectedType = 'scheduled');
                        selectedTypeIndex = 2 ;
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding:  EdgeInsets.symmetric(vertical:  16.0.w),
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
                      Nav.consultationDetailsScreen(context) ;
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
      ),
    );
  }
}
