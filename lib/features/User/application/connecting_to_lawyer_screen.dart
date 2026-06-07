import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:logger/logger.dart';
import 'package:rasikh/features/User/application/models/consultation_model.dart';
import 'package:rasikh/features/User/profile/cubit/profile_cubit.dart';

import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';
import '../../../core/get_it_service/get_it_service.dart';
import 'bloc/consulation_application_cubit.dart';
import 'consultation_type_screen(2).dart';

class ConnectingToLawyerScreen extends StatefulWidget {
  const ConnectingToLawyerScreen({super.key});

  @override
  State<ConnectingToLawyerScreen> createState() =>
      _ConnectingToLawyerScreenState();
}

class _ConnectingToLawyerScreenState extends State<ConnectingToLawyerScreen>
    with SingleTickerProviderStateMixin {

    late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      final cubit = getIt<ConsultationApplicationCubit>();

      if (cubit.selectedConsultationType == ConsultationType.instant) {
        Nav.videoCallScreen(
          context,
          consultationId: cubit.state.createdConsultation!.id,
          lawyerName: cubit.state.selectedLawyer?.fullName,
          lawyerPhotoUrl: cubit.state.selectedLawyer?.photoUrl,
          lawyerId: cubit.state.selectedLawyer?.id,
          clientId: getIt<ProfileCubit>().profile!.id,

        );
      } else {
        Nav.chat(
          context,
          consultationId: '${cubit.state.createdConsultation!.id}',
          lawyerId: cubit.state.selectedLawyer?.id,
          clientId: getIt<ProfileCubit>().profile!.id,
          lawyerName: cubit.state.selectedLawyer?.fullName,
          lawyerPhotoUrl: cubit.state.selectedLawyer?.photoUrl,
        );
      }
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Dots Indicator
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final progress = (_controller.value * 3).floor() % 3;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isActive = index == progress;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 6.w),
                          width: isActive ? 10.w : 8.w,
                          height: isActive ? 10.w : 8.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary.withOpacity(0.3),
                          ),
                        );
                      }),
                    );
                  },
                ),

                Gap(30.h),

                // Title
                Text(
                  "جاري ربطك بالمحامي",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                Gap(10.h),

                // Subtitle
                Text(
                  "يرجى الانتظار لحظات حتى نكمل عملية الربط مع المحامي المناسب.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
