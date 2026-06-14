// features/Lawyer/lawyer-appointments/presentation/screens/lawyer_appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/features/Lawyer/lawyer-appointments/repo/lawyer_appointments_repo.dart';
import 'package:rasikh/features/Lawyer/lawyer-appointments/widgets/appointments_list_widget.dart';
import 'package:rasikh/features/Lawyer/lawyer-appointments/widgets/appointments_screen_title.dart';
import 'package:size_config/size_config.dart';

import '../../../../../config/navigation/nav.dart';
import '../../../../../core/get_it_service/get_it_service.dart';
import '../../../../../core/widgets/app_bar_without_icon_button.dart';
import '../../../../../core/widgets/general_divider.dart';
import '../../../../../core/widgets/gradiant_button.dart';

import 'bloc/lawyer_appointments_cubit.dart';
import 'bloc/lawyer_appointments_state.dart';

class LawyerAppointmentsScreen extends StatelessWidget {
  const LawyerAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LawyerAppointmentsCubit(getIt<LawyerAppointmentsRepo>())
        ..fetchWeeklyAvailability(),
      child: const _LawyerAppointmentsView(),
    );
  }
}

// ── Inner view ────────────────────────────────────────────────────────────────

class _LawyerAppointmentsView extends StatelessWidget {
  const _LawyerAppointmentsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<LawyerAppointmentsCubit, LawyerAppointmentsState>(
      // ── Side-effects (snackbars) ─────────────────────────────────────────
      listenWhen: (_, current) =>
      current is SlotCreatedSuccess ||
          current is SlotUpdatedSuccess ||
          current is SlotDeletedSuccess ||
          current is SlotMutationError ||
          current is LawyerAppointmentsError,
      listener: (context, state) {
        if (state is SlotCreatedSuccess) {
          _showSnack(context, state.message, isError: false);
        } else if (state is SlotUpdatedSuccess) {
          _showSnack(context, state.message, isError: false);
        } else if (state is SlotDeletedSuccess) {
          _showSnack(context, 'تم حذف الموعد بنجاح', isError: false);
        } else if (state is SlotMutationError) {
          _showSnack(context, state.message, isError: true);
        } else if (state is LawyerAppointmentsError) {
          // Only show snackbar for errors when we already have cached data
          // (i.e. a pull-to-refresh failure). First-load errors are shown inline.
          final hasCached =
              context.read<LawyerAppointmentsCubit>().cachedWeeklyData != null;
          if (hasCached) {
            _showSnack(context, state.message, isError: true);
          }
        }
      },
      // ── UI ───────────────────────────────────────────────────────────────
      builder: (context, state) {
        return Scaffold(
          body: Directionality(
            textDirection: Directionality.of(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBarWithoutBackIconButton(theme: theme, title: 'مواعيدي'),
                AppointmentsScreenTitle(theme: theme),
                GeneralDivider(height: 25.h),

                // ── Content area ────────────────────────────────────────
                _buildBody(context, state, theme),

                // ── Add button (always visible) ─────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: GradiantButton(
                    text: 'إضافة موعد عمل',
                    onTap: () => Nav.addWorkAppointment(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Body builder ──────────────────────────────────────────────────────────

  Widget _buildBody(
      BuildContext context,
      LawyerAppointmentsState state,
      ThemeData theme,
      ) {
    // 1. Hard loading — very first fetch, nothing cached yet → shimmer
    if (state is LawyerAppointmentsInitial || state is LawyerAppointmentsLoading) {
      final hasCached =
          context.read<LawyerAppointmentsCubit>().cachedWeeklyData != null;
      if (!hasCached) {
        return const AppointmentsListShimmer();
      }
      // Already have cached data (e.g. pull-to-refresh triggered a new
      // LawyerAppointmentsLoading) — keep showing the list so the
      // RefreshIndicator spinner is the only visual feedback.
      return AppointmentsList(
        days: context
            .read<LawyerAppointmentsCubit>()
            .cachedWeeklyData!
            .days,
        theme: theme,
      );
    }

    // 2. Loaded — happy path
    if (state is LawyerAppointmentsLoaded) {
      return AppointmentsList(
        days: state.weeklyData.days,
        theme: theme,
      );
    }

    // 3. Mutation in flight or just completed → show cached list optimistically
    if (state is SlotMutationLoading ||
        state is SlotCreatedSuccess ||
        state is SlotUpdatedSuccess ||
        state is SlotDeletedSuccess) {
      final cached =
          context.read<LawyerAppointmentsCubit>().cachedWeeklyData;
      if (cached != null) {
        return AppointmentsList(days: cached.days, theme: theme);
      }
      // Edge-case: mutation fired before any list was ever loaded (shouldn't
      // normally happen, but handle it gracefully with shimmer).
      return const AppointmentsListShimmer();
    }

    // 4. Mutation error — the listener shows a snackbar; keep the cached list
    if (state is SlotMutationError) {
      final cached =
          context.read<LawyerAppointmentsCubit>().cachedWeeklyData;
      if (cached != null) {
        return AppointmentsList(days: cached.days, theme: theme);
      }
    }

    // 5. Fetch error — only show error page on the very first load failure
    if (state is LawyerAppointmentsError) {
      final cached =
          context.read<LawyerAppointmentsCubit>().cachedWeeklyData;

      // If we have cached data (failed pull-to-refresh) keep showing the list;
      // the snackbar in the listener already informed the user.
      if (cached != null) {
        return AppointmentsList(days: cached.days, theme: theme);
      }

      // First-load failure → inline error with retry
      return Expanded(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 56.w,
                  color: theme.colorScheme.error.withOpacity(0.6),
                ),
                Gap(16.h),
                Text(
                  state.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap(16.h),
                TextButton.icon(
                  onPressed: () => context
                      .read<LawyerAppointmentsCubit>()
                      .fetchWeeklyAvailability(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Expanded(child: SizedBox());
  }

  // ── Snackbar helper ───────────────────────────────────────────────────────

  void _showSnack(BuildContext context, String message,
      {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: isError ? 4 : 2),
        ),
      );
  }
}