import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/navigation/nav.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';
import '../../../core/widgets/auth_stepper.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  int selectedDayIndex = 3; // default selected (Saturday 22)
  int selectedTimeIndex = 1; // default selected (03:30 PM)

  final List<String> times = [
    // Morning slots
    "09:00 صباحا",
    "09:30 صباحا",
    "10:00 صباحا",
    "10:30 صباحا",
    "11:00 صباحا",
    "11:30 صباحا",
    "12:00 مساءً",
    // Afternoon & evening slots
    "01:00 مساء",
    "01:30 مساء",
    "02:00 مساء",
    "02:30 مساء",
    "03:00 مساء",
    "03:30 مساء",
    "04:00 مساء",
    "04:30 مساء",
    "05:00 مساء",
    "05:30 مساء",
    "06:00 مساء",
    "06:30 مساء",
    "07:00 مساء",
    "07:30 مساء",
    "08:00 مساء",
    "08:30 مساء",
    "09:00 مساء",
  ];

  List<DateTime> upcomingDays =
      List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: GeneralAppBar(title: "حجز موعد"),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(24.h),
              // Stepper
              AuthStepperWidget(activeStep: 5, totalSteps: 6),
              Gap(24.h),

              // Label: اختر تاريخ الجلسة
              Text(
                "إختر تاريخ الجلسة *",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap(12.h),

              // Days Scroll
              // Generate next 7 days from today dynamically

              SizedBox(
                height: 130.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: upcomingDays.length,
                  separatorBuilder: (_, __) => Gap(8.w),
                  itemBuilder: (context, index) {
                    final isSelected = selectedDayIndex == index;
                    final day = upcomingDays[index];

                    // Arabic weekday names
                    final arabicDays = [
                      'الاثنين',
                      'الثلاثاء',
                      'الأربعاء',
                      'الخميس',
                      'الجمعة',
                      'السبت',
                      'الأحد',
                    ];

                    // Get weekday in Arabic
                    final dayName =
                        arabicDays[day.weekday == 7 ? 6 : day.weekday - 1];

                    // Format date: e.g. "22 سبتمبر"
                    final arabicMonths = [
                      'يناير',
                      'فبراير',
                      'مارس',
                      'أبريل',
                      'مايو',
                      'يونيو',
                      'يوليو',
                      'أغسطس',
                      'سبتمبر',
                      'أكتوبر',
                      'نوفمبر',
                      'ديسمبر',
                    ];
                    final formattedDate =
                        "${day.day} ${arabicMonths[day.month - 1]}";

                    return GestureDetector(
                      onTap: () => setState(() => selectedDayIndex = index),
                      child: Container(
                        width: 100.w,
                        height: 140.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.h),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : theme.dividerColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Picture(
                                getAssetIcon("Calendar.svg"),
                                width: 24.h,
                                height: 24.h,
                                color: isSelected
                                    ? colorScheme.primary
                                    : theme.hintColor,
                              ),
                              padding: EdgeInsets.all(12.h),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.dividerColor.withOpacity(.4),
                              ),
                            ),
                            Gap(6.h),
                            Text(
                              dayName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? colorScheme.primary
                                    : theme.hintColor,
                              ),
                            ),
                            Gap(2.h),
                            Text(
                              formattedDate,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isSelected
                                    ? colorScheme.primary
                                    : theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Gap(50.h),

              // Label: وقت الإستشارة
              Text(
                "وقت الإستشارة *",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap(8.h),

              // Time options grid
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: times.length,
                  padding: EdgeInsets.only(top: 8.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: 3.5,
                  ),
                  itemBuilder: (context, index) {
                    final isSelected = selectedTimeIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedTimeIndex = index),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.h),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : theme.dividerColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          times[index],
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: isSelected
                                ? colorScheme.primary
                                : theme.hintColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Gap(16.h),

              // Next button
              SizedBox(
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
                    Nav.paymentScreen(context);
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
              Gap(16.h),
            ],
          ),
        ),
      ),
    );
  }
}
