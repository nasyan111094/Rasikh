import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/widgets/gradiant_button.dart';
import 'package:size_config/size_config.dart';
import '../../../core/widgets/app_bar_without_icon_button.dart';
import '../../../core/widgets/general_divider.dart';



class InstantConsultationScreen extends StatefulWidget {
  const InstantConsultationScreen({super.key});

  @override
  State<InstantConsultationScreen> createState() => _InstantConsultationScreenState();
}

class _InstantConsultationScreenState extends State<InstantConsultationScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);



    return Scaffold(
      body: Directionality(
        textDirection: Directionality.of(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBarWithoutBackIconButton(theme: theme, title: Loc.myConsultations()),
            const FilterHeader(),
            GeneralDivider(height: 10.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                child: Column(
                  children: [
                    LawyerConsultationCard(
                      active: true,
                      lawyerName: Loc.sampleLawyerName(),
                      specialization: Loc.sampleSpecialization(),
                      startTime: Loc.sampleStartTimeAlt(),
                      price: Loc.samplePrice(),
                      imageUrl:
                      "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                      showWaitingMessage: false,
                    ),
                    SizedBox(height: 12.h),
                    UserConsultationCard(
                      active: true,
                      lawyerName: null,
                      specialization: null,
                      startTime: Loc.sampleStartTimeAlt(),
                      price: Loc.samplePrice(),
                      imageUrl: null,
                      showWaitingMessage: true,
                    ),
                    UserConsultationCard(
                      active: false  ,
                      lawyerName: null,
                      specialization: null,
                      startTime: Loc.sampleStartTimeAlt(),
                      price: Loc.samplePrice(),
                      imageUrl: null,
                      showWaitingMessage: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterHeader extends StatelessWidget {
  const FilterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final highlightColor = theme.colorScheme.secondary;
    final cardColor = theme.cardColor.withOpacity(isDark ? 0.15 : 1);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
              children: [
                TextSpan(text: Loc.filterByWithColon()),
                TextSpan(
                  text: Loc.statusActive(),
                  style: TextStyle(
                    color: highlightColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Container(
            width: 38.w,
            height: 38.h,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10.w),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/filter.svg',
                width: 20.w,
                height: 20.h,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserConsultationCard extends StatelessWidget {
  final bool active;
  final String? lawyerName;
  final String? specialization;
  final String startTime;
  final String price;
  final String? imageUrl;
  final bool showWaitingMessage;

  const UserConsultationCard({
    super.key,
    required this.active,
    required this.lawyerName,
    required this.specialization,
    required this.startTime,
    required this.price,
    this.imageUrl,
    this.showWaitingMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.w),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Loc.instantConsultation(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(.1),
                        borderRadius: BorderRadius.circular(50.w),
                      ),
                      child: Center(
                        child: Text(
                          Loc.statusActive(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                GeneralDivider(height: 20.h),

                if (!showWaitingMessage && lawyerName != null)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22.w,
                        backgroundImage: NetworkImage(imageUrl!),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lawyerName!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            Loc.specializationWithValue(specialization),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.grey,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8.w),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange, size: 18.w),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            Loc.suitableLawyerWillBeRecommended(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                GeneralDivider(height: 20.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          Loc.startTime(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          startTime,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 30.h,
                      width: 2.w,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(.1),
                        borderRadius: BorderRadius.circular(50.w),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          Loc.paidPrice(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          price,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
               SizedBox(height: 10.h,) ,
               GeneralDivider(height: 0,) ,
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: GradiantButton(text: Loc.join(), onTap: (){}),
          ),
        ],
      ),
    );
  }
}
class LawyerConsultationCard extends StatelessWidget {
  final bool active;
  final String? lawyerName;
  final String? specialization;
  final String startTime;
  final String price;
  final String? imageUrl;
  final bool showWaitingMessage;

  const LawyerConsultationCard({
    super.key,
    required this.active,
    required this.lawyerName,
    required this.specialization,
    required this.startTime,
    required this.price,
    this.imageUrl,
    this.showWaitingMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.w),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          Loc.instantConsultation(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        Gap(10.h) ,
                        Text(
                          Loc.specializationWithValue(specialization),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.grey,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(.1),
                        borderRadius: BorderRadius.circular(50.w),
                      ),
                      child: Center(
                        child: Text(
                          Loc.statusActive(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                GeneralDivider(height: 20.h),


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          Loc.startTime(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          startTime,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 30.h,
                      width: 2.w,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(.1),
                        borderRadius: BorderRadius.circular(50.w),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          Loc.paidPrice(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          price,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10.h,) ,
                GeneralDivider(height: 0),


              ],
            ),
          ),
          SizedBox(
            width: double.infinity,

            child: GradiantButton(text: Loc.join(), onTap: (){}),
          ),
        ],
      ),
    );
  }
}
