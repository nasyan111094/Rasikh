import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:logger/logger.dart';
import 'package:rasikh/features/User/profile/cubit/profile_cubit.dart';
import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';
import '../../../core/get_it_service/get_it_service.dart';
import 'bloc/consulation_application_cubit.dart';
import 'bloc/connecting_to_lawyer_cubit.dart';
import 'bloc/connecting_to_lawyer_state.dart';
import 'models/consultation_model.dart';

class ConnectingToLawyerScreen extends StatelessWidget {
  const ConnectingToLawyerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appCubit = getIt<ConsultationApplicationCubit>();
    final created = appCubit.state.createdConsultation;
    final type = appCubit.selectedConsultationType ??
        appCubit.state.selectedConsultationType;

    // Null-safety: previous version force-unwrapped (!) and crashed
    // when the screen was opened without a created consultation.
    if (created == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(Loc.unexpectedError()),
                  Gap(16.h),
                  ElevatedButton(
                    onPressed: () => Nav.layout(context),
                    child: Text(Loc.backToHomeAlt()),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => ConnectingToLawyerCubit(
        consultationId: created.id,
        consultationType: type,
      )..start(),
      child: _ConnectingBody(
        consultationId: created.id,
        consultationType: type,
      ),
    );
  }
}

class _ConnectingBody extends StatefulWidget {
  final String consultationId;
  final ConsultationType consultationType;

  const _ConnectingBody({
    required this.consultationId,
    required this.consultationType,
  });

  @override
  State<_ConnectingBody> createState() => _ConnectingBodyState();
}

class _ConnectingBodyState extends State<_ConnectingBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
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

  void _navigateToSession() {
    ConsultationApplicationCubit cubit;
    try {
      cubit = context.read<ConsultationApplicationCubit>();
    } catch (_) {
      cubit = getIt<ConsultationApplicationCubit>();
    }
    ProfileCubit profileCubit;
    try {
      profileCubit = context.read<ProfileCubit>();
    } catch (_) {
      profileCubit = getIt<ProfileCubit>();
    }
    final profile = profileCubit.profile;

    if (profile == null) {
      Logger().e('Profile is null , cannot navigate to session');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Loc.unexpectedError())),
      );
      return;
    }

    if (widget.consultationType == ConsultationType.instant ||
        widget.consultationType == ConsultationType.scheduled) {
      Nav.videoCallScreen(
        context,
        consultationId: widget.consultationId,
        lawyerName: cubit.state.selectedLawyer?.fullName,
        lawyerPhotoUrl: cubit.state.selectedLawyer?.photoUrl,
        lawyerId: cubit.state.selectedLawyer?.id,
        clientId: profile.id,
        consultationType: widget.consultationType.value,
      );
    } else {
      Nav.chat(
        context,
        consultationId: widget.consultationId,
        lawyerId: cubit.state.selectedLawyer?.id,
        clientId: profile.id,
        lawyerName: cubit.state.selectedLawyer?.fullName,
        lawyerPhotoUrl: cubit.state.selectedLawyer?.photoUrl,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ConnectingToLawyerCubit, ConnectingToLawyerState>(
          listener: (context, state) {
            if (state.phase == ConnectingPhase.joined) {
              _navigateToSession();
            }
          },
          builder: (context, state) {
            switch (state.phase) {
              case ConnectingPhase.joined:
              case ConnectingPhase.waiting:
                return _buildWaiting(theme);
              case ConnectingPhase.timedOut:
                return _buildTerminal(
                  theme,
                  title: Loc.noAvailableAppointments(),
                  message: Loc.pleaseWaitWhileConnecting(),
                  primaryLabel: Loc.retryAgain(),
                  onPrimary: () =>
                      context.read<ConnectingToLawyerCubit>().retry(),
                  secondaryLabel: Loc.backToHomeAlt(),
                  onSecondary: () => Nav.layout(context),
                );
              case ConnectingPhase.ended:
                return _buildTerminal(
                  theme,
                  title: Loc.consultationTimeEnded(),
                  message: Loc.pleaseWaitWhileConnecting(),
                  primaryLabel: Loc.backToHomeAlt(),
                  onPrimary: () => Nav.layout(context),
                );
              case ConnectingPhase.error:
                return _buildTerminal(
                  theme,
                  title: Loc.unableToConnectToServer(),
                  message: state.errorMessage,
                  primaryLabel: Loc.retryAgain(),
                  onPrimary: () =>
                      context.read<ConnectingToLawyerCubit>().retry(),
                  secondaryLabel: Loc.backToHomeAlt(),
                  onSecondary: () => Nav.layout(context),
                );
            }
          },
        ),
      ),
    );
  }

  Widget _buildWaiting(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            Text(
              Loc.connectingYouToLawyer(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(10.h),
            Text(
              Loc.pleaseWaitWhileConnecting(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(24.h),
            BlocBuilder<ConnectingToLawyerCubit, ConnectingToLawyerState>(
              builder: (context, state) {
                if (state.attempts < 10) return const SizedBox.shrink();
                return TextButton(
                  onPressed: () => Nav.layout(context),
                  child: Text(Loc.backToHomeAlt()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminal(
    ThemeData theme, {
    required String title,
    String? message,
    required String primaryLabel,
    required VoidCallback onPrimary,
    String? secondaryLabel,
    VoidCallback? onSecondary,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline,
                size: 48.w, color: theme.colorScheme.primary),
            Gap(16.h),
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            if (message != null) ...[
              Gap(8.h),
              Text(message,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center),
            ],
            Gap(24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPrimary,
                child: Text(primaryLabel),
              ),
            ),
            if (secondaryLabel != null && onSecondary != null) ...[
              Gap(8.h),
              TextButton(
                onPressed: onSecondary,
                child: Text(secondaryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
