import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/gradiant_button.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';
import '../../../core/widgets/auth_stepper.dart';
import 'widgets/day_selection_section.dart';
import 'widgets/session_settings_widget.dart';

class AddingWorkAppointmentScreen extends StatelessWidget {
  const AddingWorkAppointmentScreen({super.key});

  Future<void> showSaveAppointmentDialog(BuildContext context) async {
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(dialogContext);
          Navigator.pop(context);
        });

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
                  "تم حفظ الموعد بنجاح",
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
                  "يمكنك مراجعة تفاصيل الموعد في أي وقت من صفحة المواعيد.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),


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

    return Scaffold(
      appBar: const GeneralAppBar(title: "إضافة موعد عمل"),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(24.h),
              Text(
                "إختر اليوم أو الأيام *",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap(12.h),
              const DaySelectionSection(),
              Gap(40.h),
              const Expanded(child: SessionSettingsWidget()),
              Gap(20.h),
              GradiantButton(text: "حفظ الموعد", onTap: () {showSaveAppointmentDialog(context);}),
              Gap(16.h),
            ],
          ),
        ),
      ),
    );
  }
}
