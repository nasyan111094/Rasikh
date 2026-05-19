import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/widgets/custom_divider.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';


class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Directionality(
        textDirection: Directionality.of(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(40.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "مواعيدي",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.textTheme.titleSmall?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Gap(12.h),
            Divider(
              height: 1,
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
            const Gap(12),
            const AppointmentTabs(),
            const Gap(16),
            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: const [
                    AppointmentCard(
                      date: "16 / 08 / 2025",
                      startTime: "10:30 صباحا",
                      duration: "30 دقيقة",
                      lawyerName: "عبدالله بن فهد الشمري",
                      specialization: "بيع وشراء",
                      imageUrl:
                      "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                      primaryButtonText: "إنضمام",
                      secondaryButtonText: "إلغاء",
                    ),
                    SizedBox(height: 12),
                    AppointmentCard(
                      date: "16 / 08 / 2025",
                      startTime: "10:30 صباحا",
                      duration: "30 دقيقة",
                      lawyerName: "عبدالله بن فهد الشمري",
                      specialization: "بيع وشراء",
                      imageUrl:
                      "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                      primaryButtonText: "إعادة الجدولة",
                      secondaryButtonText: "إلغاء",
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

//==============================//
//         Tabs Section         //
//==============================//

class AppointmentTabs extends StatelessWidget {
  const AppointmentTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5 , horizontal: 12),
        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding:
                const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: tabColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Center(
                  child: Text(
                    "قادمة",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  "مكتملة",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color
                        ?.withOpacity(0.6),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  "ملغاة",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color
                        ?.withOpacity(0.6),
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

//==============================//
//       Appointment Card       //
//==============================//

class AppointmentCard extends StatelessWidget {
  final String date;
  final String startTime;
  final String duration;
  final String lawyerName;
  final String specialization;
  final String imageUrl;
  final String primaryButtonText;
  final String secondaryButtonText;

  const AppointmentCard({
    super.key,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.lawyerName,
    required this.specialization,
    required this.imageUrl,
    required this.primaryButtonText,
    required this.secondaryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: ()
      {
       Nav.appointmentDetailsScreen(context) ;
      },
      child: Container(
        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.2),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "إستشارة مجدولة",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
             color: Colors.green.withOpacity(.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "قادمة",
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            GeneralDivider(height: 20.h,) ,

            // Lawyer Info
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(imageUrl),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lawyerName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "التخصص: $specialization",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            GeneralDivider(height: 20.h,) ,


            // Details Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoColumn(context, "تاريخ الجلسة", date),
                _divider(theme),
                _infoColumn(context, "وقت البدء", startTime),
                _divider(theme),
                _infoColumn(context, "مدة الجلسة", duration),
              ],
            ),

            GeneralDivider(height: 20.h,) ,


            // Buttons Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      primaryButtonText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.textTheme.bodyLarge?.color,
                      backgroundColor:
                      theme.colorScheme.surface.withOpacity(0.4),
                      side: BorderSide(
                        color: theme.dividerColor.withOpacity(0.2),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      secondaryButtonText,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(BuildContext context, String title, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _divider(ThemeData theme) => Container(
    height: 24,
    width: 1.5,
    color: theme.colorScheme.primary.withOpacity(0.1),
  );
}
