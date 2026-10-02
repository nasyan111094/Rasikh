import 'package:rasikh/config/localization/loc_keys.dart';


import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:gap/gap.dart';
import 'package:logger/logger.dart';
import 'package:rasikh/config/app_config.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/services/app_logger.dart';
import 'package:rasikh/features/Lawyer/consultation/widgets/consultation_shimmer.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';
import 'package:size_config/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/general_divider.dart';
import '../../../../core/widgets/gradiant_button.dart';
import '../../../config/navigation/nav.dart';

import '../../User/application/bloc/consulation_application_cubit.dart';
import '../../User/application/models/consultation_model.dart' as app_models;
import 'Bloc/consultation_details_cubit.dart';
import 'Bloc/consultations_cubit.dart';
import 'Bloc/consultations_states.dart';
import 'models/consultation_model.dart';

import '../../User/application/appointment_booking_screen(3.3).dart';
import 'consultations_screen.dart';

const String _kBaseUrl = 'http://89.117.60.202:3050';

DateTime? _correctServerTime(DateTime? dt) {
  if (dt == null) return null;
  return dt.toLocal().add(const Duration(hours: 0));
}


class _UI {
  static const radiusLg = 20.0;
  static const radiusMd = 16.0;
  static const radiusSm = 12.0;

  static BoxShadow softShadow(Color tint) => BoxShadow(
    color: tint.withOpacity(0.08),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );
}


class LawyerConsultationDetailsScreen extends StatefulWidget {
  final String consultationId;

  const LawyerConsultationDetailsScreen({
    super.key,
    required this.consultationId,
  });

  @override
  State<LawyerConsultationDetailsScreen> createState() =>
      _LawyerConsultationDetailsScreenState();
}

class _LawyerConsultationDetailsScreenState
    extends State<LawyerConsultationDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<ConsultationDetailsCubit>()
        .fetchDetails(id: widget.consultationId);
  }

  bool _canEnterSession(ConsultationModel item) {
    if (item.status == ConsultationStatus.active) return true;
    if (item.status == ConsultationStatus.upcoming) {
      final start = _correctServerTime(item.effectiveStartDateTime);
      if (start == null) return true;
      return !DateTime.now().isBefore(start.toLocal());
    }
    if (item.isPaymentPaid && item.status == ConsultationStatus.none) return true;
    return false;
  }

  void _enterSession(BuildContext context, ConsultationModel item) {
    if (!_canEnterSession(item)) return;

    if (item.type == "written") {
      Nav.chat(
        context,
        consultationId: item.id,
        clientId: item.client?.id,
        lawyerId: item.lawyer?.id,
        lawyerName: item.lawyer?.fullName,
        lawyerPhotoUrl: getIt<CacheHelper>().currentUser?.avatar,
      );
    } else {
      Nav.videoCallScreen(
        context,
        consultationId: item.id,
        clientId: item.client?.id,
        lawyerId: item.lawyer?.id,
        lawyerName: item.lawyer?.fullName,
        consultationType: item.type,
        lawyerPhotoUrl: getIt<CacheHelper>().currentUser?.avatar,
      );
    }
  }

  List<Widget> _buildStatusAction(
      BuildContext context, ConsultationModel consultation) {
    Logger().d("llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll" );
    Logger().d(consultation.isPaymentPending && consultation.isConsultationPending );
    Logger().d("llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll" );

    if (consultation.isPaymentPending && consultation.isConsultationPending ) {
      return [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
          child: SizedBox(
            width: double.infinity,
            child: GradiantButton(
              text: Loc.completePayment(),
              onTap: () async {
                final createdConsultation = app_models.CreatedConsultationModel(
                  id: consultation.id,
                  consultationNumber: consultation.consultationNumber,
                  title: consultation.title,
                  details: consultation.details ?? '',
                  voiceNoteUrl: consultation.voiceNoteUrl,
                  voiceNoteDurationSeconds: consultation.voiceNoteDurationSeconds,
                  attachments: consultation.attachments.map((a) => a.url).toList(),
                  type: consultation.type,
                  startTime: consultation.startTime,
                  endTime: consultation.endTime,
                  status: consultation.status.apiValue,
                  durationMin: consultation.durationMin,
                  priceAmountHalala: consultation.priceAmountHalala,
                  currency: consultation.currency ?? 'SAR',
                  hideClientFromLawyer: consultation.hideClientFromLawyer,
                  createdAt: consultation.createdAt ?? '',
                );

                await context.read<ConsultationApplicationCubit>()
                    .loadExistingConsultationForPayment(createdConsultation);

                if (context.mounted) {
                  Nav.paymentScreen(context);
                }
              },
            ),
          ),
        ),
      ];
    }



    switch (consultation.status) {
      case ConsultationStatus.active:
        return [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: SizedBox(
              width: double.infinity,
              height: 54.h,
              child: GradiantButton(
                text: Loc.enterSession(),
                onTap: () => _enterSession(context, consultation),
              ),
            ),
          ),
        ];

      case ConsultationStatus.upcoming:
        return [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: _DetailsUpcomingButton(
              consultation: consultation,
              onEnter: () => _enterSession(context, consultation),
              onReschedule: consultation.lawyer == null
                  ? null
                  : () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AppointmentBookingScreen(
                    lawyerId: consultation.lawyer!.id,
                    consultationId: consultation.id,
                    isRescheduleMode: true,
                    onRescheduleConfirmed: (d) {
                      context
                          .read<ConsultationsCubit>()
                          .rescheduleConsultation(
                        consultationId: consultation.id,
                        newStartTime: d,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ];

      case ConsultationStatus.cancelled:
        return [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: const _DetailsCancelledNotice(),
          ),
        ];

      case ConsultationStatus.disputes:
        return [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: _DetailsDisputeNotice(consultation: consultation),
          ),
        ];

      case ConsultationStatus.completed:
        if (getIt<CacheHelper>().cachedVendorType == VendorType.lawyer) {
          return const [];
        }
        return [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: SizedBox(
              width: double.infinity,

              child: GradiantButton(
                text: Loc.addRating(),
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => BlocProvider.value(
                    value: context.read<ConsultationsCubit>(),
                    child:
                    _DetailsRatingBottomSheet(consultation: consultation),
                  ),
                ),
              ),
            ),
          ),
        ];

      case ConsultationStatus.none:
        return const [];
      case ConsultationStatus.pending:
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(

      body: Directionality(
        textDirection: Directionality.of(context),
        child: BlocBuilder<ConsultationDetailsCubit, ConsultationDetailsState>(
          builder: (context, state) {
            final consultation =
            state is ConsultationDetailsLoaded ? state.consultation : null;

            return Column(
              children: [
                _DetailsAppBar(
                  onBack: () => Navigator.pop(context),
                  status: consultation?.status,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _buildBody(context, state, theme),
                  ),
                ),

                if (consultation != null)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildStatusAction(context, consultation),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      ConsultationDetailsState state,
      ThemeData theme,
      ) {
    if (state is ConsultationDetailsLoading) {
      return const SingleChildScrollView(
        key: ValueKey('loading'),
        child: ConsultationDetailsShimmer(),
      );
    }

    if (state is ConsultationDetailsError) {
      return Center(
        key: const ValueKey('error'),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84.w,
                height: 84.w,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline_rounded,
                    size: 40.w, color: Colors.red.shade300),
              ),
              SizedBox(height: 16.h),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey.shade600, fontSize: 13.sp),
              ),
              SizedBox(height: 18.h),
              SizedBox(
                width: 180.w,
                height: 48.h,
                child: GradiantButton(
                  text: Loc.retryAgain(),
                  onTap: () => context
                      .read<ConsultationDetailsCubit>()
                      .fetchDetails(id: widget.consultationId),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is ConsultationDetailsLoaded) {
      return _DetailsContent(
        key: const ValueKey('loaded'),
        consultation: state.consultation,
      );
    }

    return const SizedBox.shrink();
  }
}


class _DetailsAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final ConsultationStatus? status;
  const _DetailsAppBar({required this.onBack, this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.only(
            top: topPadding + 10.h,
            bottom: 16.h,
            left: 16.w,
            right: 16.w,
          ),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withOpacity(0.85),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _CircleIconButton(
                icon: Icons.arrow_back_outlined,
                onTap: onBack,
              ),
              Gap(12.w),
              Expanded(
                child: Text(
                  Loc.consultationDetailsAlt(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18.sp,
                  ),
                ),
              ),
              if (status != null) _DetailsStatusBadge(status: status!),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(color: Colors.grey.withOpacity(0.12)),
          ),
          child: Icon(icon, size: 18.sp),
        ),
      ),
    );
  }
}


class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _SectionCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181B21) : Colors.white,
        borderRadius: BorderRadius.circular(_UI.radiusMd),
        boxShadow: [_UI.softShadow(isDark ? Colors.black : Colors.grey)],
      ),
      child: child,
    );
  }
}


class _DetailsContent extends StatelessWidget {
  final ConsultationModel consultation;
  const _DetailsContent({super.key, required this.consultation});

  String _typeLabel(String type) {
    switch (type) {
      case 'instant':
        return Loc.instantConsultation();
      case 'scheduled':
        return Loc.scheduledConsultation();
      case 'written':
        return Loc.writtenConsultation();
      default:
        return type;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'instant':
        return Icons.flash_on_rounded;
      case 'scheduled':
        return Icons.event_available_rounded;
      case 'written':
        return Icons.edit_note_rounded;
      default:
        return Icons.gavel_rounded;
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year}  $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    AppLogger.info(
        _formatDateTime(_correctServerTime(consultation.effectiveStartDateTime)));

    final priceLabel = consultation.priceInSar != null
        ? '${consultation.priceInSar!.toStringAsFixed(0)} ${Loc.currencySAR()}'
        : '—';

    final startLabel = _formatDateTime(
      _correctServerTime(consultation.effectiveStartDateTime),
    );

    final parts = startLabel.trim().split(RegExp(r'\s+'));
    final datePart = parts.isNotEmpty ? parts.first : '—';
    final timePart = parts.length > 1 ? parts.last : '—';

    String timeDisplay = '—';
    if (timePart != '—') {
      final timeParts = timePart.split(':');
      final hour24 = int.tryParse(timeParts[0]);
      final minute = timeParts.length > 1 ? timeParts[1] : '00';

      if (hour24 != null) {
        final period = hour24 >= 12 ? Loc.pmLongLeading() : Loc.amLongLeading();
        final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
        timeDisplay = '${hour12.toString().padLeft(2, '0')}:$minute$period';
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cs.primary, cs.primary.withOpacity(0.75)],
              ),
              borderRadius: BorderRadius.circular(_UI.radiusLg),
              boxShadow: [_UI.softShadow(cs.primary)],
            ),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14.w),
                  ),
                  child: Icon(_typeIcon(consultation.type),
                      color: Colors.white, size: 24.sp),
                ),
                Gap(14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _typeLabel(consultation.type),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        consultation.consultationNumber,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                _DetailsStatusBadge(status: consultation.status, onDark: true),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          if (consultation.client != null &&
              !consultation.hideClientFromLawyer) ...[
            _SectionCard(
              child: _ClientCard(
                client: getIt<CacheHelper>().cachedVendorType ==
                    VendorType.user
                    ? consultation.lawyer
                    : consultation.client!,
              ),
            ),
            SizedBox(height: 14.h),
          ],

          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: Loc.specialization(), icon: Icons.workspace_premium_rounded),
                SizedBox(height: 8.h),
                Text(
                  consultation.specialization?.name ?? '—',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                ),
                if (consultation.subSpecializations.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    alignment: WrapAlignment.start,
                    children: consultation.subSpecializations.map((s) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(50.w),
                          border: Border.all(color: cs.primary.withOpacity(0.18)),
                        ),
                        child: Text(
                          s.name,
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 14.h),

          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: Loc.consultationTitle(), icon: Icons.title_rounded),
                SizedBox(height: 8.h),
                Text(
                  consultation.title,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (consultation.details != null) ...[
                  SizedBox(height: 14.h),
                  GeneralDivider(height: 0),
                  SizedBox(height: 14.h),
                  _SectionLabel(label: Loc.consultationDescription(), icon: Icons.notes_rounded),
                  SizedBox(height: 8.h),
                  Text(
                    consultation.details!,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 13.sp,
                      height: 1.7,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 14.h),

          if (consultation.summary != null) ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(
                      label: Loc.sessionSummary(), icon: Icons.summarize_rounded),
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(_UI.radiusSm),
                      border: Border.all(color: cs.primary.withOpacity(0.12)),
                    ),
                    child: Text(
                      consultation.summary!,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                        fontSize: 13.sp,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
          ],

          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(
                    label: Loc.timeAndPrice(), icon: Icons.schedule_rounded),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: Icons.event_rounded,
                        label: Loc.startDateLabel(),
                        value: datePart,
                        color: Colors.indigo,
                      ),
                    ),
                    Gap(10.w),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.access_time_filled_rounded,
                        label: Loc.startTime(),
                        value: timeDisplay,
                        color: Colors.teal,
                      ),
                    ),
                    if (consultation.durationMin != null) ...[
                      Gap(10.w),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.timer_rounded,
                          label: Loc.duration(),
                          value: Loc.durationMinutesAbbr(consultation.durationMin),
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ],
                ),
                if (consultation.priceInSar != null) ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(

                      borderRadius: BorderRadius.circular(_UI.radiusMd),
                      border: Border.all(
                        color: primary.withOpacity(.1),
                        width: 1,
                      ),

                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary,
                          ),
                          child: Icon(
                            Icons.payments_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),

                        Gap(12.w),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Loc.totalPrice(),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),



                            ],
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(

                            borderRadius: BorderRadius.circular(10),
                          ),
                          child:         Text(
                            priceLabel,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: primary,
                              letterSpacing: .2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ) ,
                ],
              ],
            ),
          ),
          SizedBox(height: 14.h),

          if (consultation.voiceNoteUrl != null) ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(label: Loc.voiceNote(), icon: Icons.mic_rounded),
                  SizedBox(height: 12.h),
                  _VoiceNotePlayer(
                    url: consultation.voiceNoteUrl!,
                    fallbackDurationSeconds:
                    consultation.voiceNoteDurationSeconds ?? 0,
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
          ],

          if (consultation.attachments.isNotEmpty) ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _SectionLabel(
                            label: Loc.attachments(), icon: Icons.attach_file_rounded),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.h),
                        ),
                        child: Text(
                          '${consultation.attachments.length}/5',
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  _AttachmentsGrid(attachments: consultation.attachments),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ],
      ),
    );
  }
}


class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(_UI.radiusSm),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [   Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 10.5.sp),
        ),SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: color,
              fontSize: 13.sp,
            ),
          ),


        ],
      ),
    );
  }
}


class _DetailsStatusBadge extends StatelessWidget {
  final ConsultationStatus status;
  final bool onDark;

  const _DetailsStatusBadge({required this.status, this.onDark = false});

  Color get _bgColor {
    if (onDark) return Colors.white.withOpacity(0.22);
    switch (status) {
      case ConsultationStatus.active:
        return Colors.green.withOpacity(0.1);
      case ConsultationStatus.upcoming:
        return Colors.blue.withOpacity(0.1);
      case ConsultationStatus.completed:
        return Colors.grey.withOpacity(0.1);
      case ConsultationStatus.cancelled:
        return Colors.red.withOpacity(0.1);
      case ConsultationStatus.disputes:
        return Colors.orange.withOpacity(0.1);
      case ConsultationStatus.none:
        return Colors.black.withOpacity(0.1);
      case ConsultationStatus.pending:
        return Colors.orange.withOpacity(.1);
    }
  }

  Color get _textColor {
    if (onDark) return Colors.white;
    switch (status) {
      case ConsultationStatus.active:
        return Colors.green.shade700;
      case ConsultationStatus.upcoming:
        return Colors.blue.shade700;
      case ConsultationStatus.completed:
        return Colors.grey.shade700;
      case ConsultationStatus.cancelled:
        return Colors.red.shade700;
      case ConsultationStatus.disputes:
        return Colors.orange.shade700;
      case ConsultationStatus.none:
        return Colors.black;
      case ConsultationStatus.pending:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(50.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: _textColor,
              shape: BoxShape.circle,
            ),
          ),
          Gap(6.w),
          Text(
            status.label,
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.bold,
              fontSize: 11.5.sp,
            ),
          ),
        ],
      ),
    );
  }
}


class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _SectionLabel({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9.w),
          ),
          child: Icon(
            icon ?? Icons.label_rounded,
            color: cs.primary,
            size: 15.sp,
          ),
        ),
        Gap(10.w),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.5.sp,
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}


class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.grey, fontSize: 12.sp)),
        SizedBox(height: 10.h),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? theme.textTheme.bodyMedium?.color,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }
}


class _ClientCard extends StatelessWidget {
  final client;
  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final hasCity = client.city != null && client.city!.trim().isNotEmpty;

    final initials = client.fullName.trim().isNotEmpty
        ? client.fullName.trim()[0].toUpperCase()
        : '?';

    final userType = getIt<CacheHelper>().cachedVendorType;

    final hasPhoto = userType == VendorType.lawyer
        ? client.avatar?.isNotEmpty
        : client.photoUrl?.isNotEmpty;
    final photoUrl = hasPhoto
        ? '${AppConfig.baseImgUrl}${userType == VendorType.lawyer ? client.avatar : client.photoUrl}'
        : null;

    final initialsAvatar = Container(
      width: 54.w,
      height: 54.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [primary, primary.withValues(alpha: .7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: .25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontFamily: "cairo",
            fontSize: 22.sp,
          ),
        ),
      ),
    );

    final avatar = photoUrl == null
        ? initialsAvatar
        : Container(
      width: 54.w,
      height: 54.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primary.withOpacity(0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ClipOval(
          child: Image.network(
            photoUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => initialsAvatar,
          ),
        ),
      ),
    );

    return Row(
      children: [
        Hero(
          tag: 'client_${client.id}',
          child: avatar,
        ),
        Gap(14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.sp,
                  letterSpacing: .2,
                ),
              ),
              Gap(6.h),
              Wrap(
                runSpacing: 8.h,
                spacing: 8.w,
                children: [
                  if (hasCity)
                    _InfoChip(
                      icon: Icons.location_on_rounded,
                      text: client.city!,
                    ),
                ],
              ),
            ],
          ),
        ),
        Gap(10.w),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(100.h),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: cs.primary),
          Gap(6.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 120.w),
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _VoiceNotePlayer extends StatefulWidget {
  final String url;
  final int fallbackDurationSeconds;

  const _VoiceNotePlayer({
    required this.url,
    required this.fallbackDurationSeconds,
  });

  @override
  State<_VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<_VoiceNotePlayer> {
  final AudioPlayer _player = AudioPlayer();

  bool _isLoading = true;
  bool _hasError = false;
  bool _isPlaying = false;
  bool _isCompleted = false;
  Duration _total = Duration.zero;
  Duration _position = Duration.zero;

  String get _resolvedUrl {
    final u = widget.url;
    return u.startsWith(AppConfig.baseImgUrl) ? u : '$_kBaseUrl$u';
  }

  @override
  void initState() {
    super.initState();
    _total = Duration(seconds: widget.fallbackDurationSeconds);
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _player.setSourceUrl(_resolvedUrl).timeout(
        const Duration(seconds: 60),
        onTimeout: () => Future.error('Source URL loading timeout'),
      );

      final duration = await _player.getDuration();
      if (duration != null && duration > Duration.zero) {
        if (mounted) setState(() => _total = duration);
      }

      _player.onPositionChanged.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });

      _player.onDurationChanged.listen((d) {
        if (mounted && d > Duration.zero) setState(() => _total = d);
      });

      _player.onPlayerStateChanged.listen((state) {
        if (!mounted) return;
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (state == PlayerState.completed) {
            _isPlaying = false;
            _isCompleted = true;
          }
        });
      });

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      print('Audio init error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_hasError || _isLoading) return;

    if (_isPlaying) {
      await _player.pause();
      if (_isCompleted) setState(() => _isCompleted = false);
    } else {
      if (_isCompleted) {
        try {
          await _player.stop();
          await _player.setSourceUrl(_resolvedUrl);
          setState(() {
            _position = Duration.zero;
            _isCompleted = false;
          });
        } catch (_) {
          setState(() => _isCompleted = false);
        }
      }
      try {
        await _player.resume();
      } catch (_) {
        if (mounted) setState(() => _hasError = true);
      }
    }
  }

  Future<void> _onSeek(double ms) async {
    try {
      await _player.seek(Duration(milliseconds: ms.toInt())).timeout(
        const Duration(seconds: 60),
        onTimeout: () => Future.error('Seek timeout'),
      );
      if (_isCompleted) setState(() => _isCompleted = false);
    } catch (e) {
      print('Seek error: $e');
      if (mounted) {
        if (e.toString().contains('404') || e.toString().contains('no such')) {
          setState(() => _hasError = true);
        }
      }
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final totalMs = _total.inMilliseconds.toDouble();
    final posMs = _position.inMilliseconds
        .toDouble()
        .clamp(0.0, totalMs > 0 ? totalMs : 1.0);

    if (_hasError) {
      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(14.w),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 22.w),
            SizedBox(width: 8.w),
            Text(
              Loc.unableToPlayAudio(),
              style: TextStyle(color: Colors.red.shade500, fontSize: 13.sp),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.08),
            primaryColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: primaryColor.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isLoading
                      ? [Colors.grey.shade300, Colors.grey.shade300]
                      : [primaryColor, primaryColor.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: _isLoading
                    ? []
                    : [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isLoading
                  ? Padding(
                padding: EdgeInsets.all(14.w),
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
                  : Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 26.w,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4.h,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.w),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 14.w),
                    activeTrackColor: primaryColor,
                    inactiveTrackColor: primaryColor.withOpacity(0.15),
                    thumbColor: primaryColor,
                    overlayColor: primaryColor.withOpacity(0.15),
                  ),
                  child: Slider(
                    value: posMs,
                    min: 0,
                    max: totalMs > 0 ? totalMs : 1.0,
                    onChanged: _isLoading ? null : _onSeek,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(_position),
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600)),
                      Text(_fmt(_total),
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _AttachmentsGrid extends StatelessWidget {
  final List<ConsultationAttachment> attachments;
  const _AttachmentsGrid({required this.attachments});

  String _resolveUrl(String url) =>
      url.startsWith('http') ? url : '$_kBaseUrl$url';

  String _extension(String url) {
    final clean = url.split('?').first;
    final name = clean.split('/').last;
    return name.contains('.') ? name.split('.').last.toLowerCase() : '';
  }

  bool _isImage(String ext) =>
      ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);

  IconData _iconForExt(String ext) {
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.videocam_rounded;
      case 'mp3':
      case 'm4a':
      case 'wav':
        return Icons.audiotrack_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _colorForExt(String ext, ColorScheme cs) {
    switch (ext) {
      case 'pdf':
        return Colors.redAccent;
      case 'doc':
      case 'docx':
        return Colors.blueAccent;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Colors.purple;
      case 'mp3':
      case 'm4a':
      case 'wav':
        return Colors.orange;
      default:
        return cs.primary;
    }
  }

  String _labelForExt(String ext) {
    switch (ext) {
      case 'pdf':
        return 'PDF';
      case 'doc':
      case 'docx':
        return 'Word';
      case 'xls':
      case 'xlsx':
        return 'Excel';
      case 'mp4':
      case 'mov':
      case 'avi':
        return Loc.videoLabel();
      case 'mp3':
      case 'm4a':
      case 'wav':
        return Loc.audioLabel();
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Loc.imageLabel();
      default:
        return ext.isEmpty ? Loc.fileLabel() : ext.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: attachments.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 2.3,
      ),
      itemBuilder: (context, index) {
        final attachment = attachments[index];
        final url = _resolveUrl(attachment.url);
        final ext = _extension(attachment.url);
        final isImg = _isImage(ext);
        final icon = _iconForExt(ext);
        final color = _colorForExt(ext, cs);
        final label = _labelForExt(ext);

        final rawName = attachment.url.split('?').first.split('/').last;
        final displayName = rawName.isNotEmpty ? rawName : Loc.attachmentNumber(index + 1);

        return GestureDetector(
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              border: Border.all(color: color.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(14.h),
            ),
            child: Row(
              children: [
                Container(
                  width: 42.h,
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10.h),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: isImg
                      ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      icon,
                      color: color,
                      size: 22.h,
                    ),
                  )
                      : Icon(icon, color: color, size: 22.h),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                          fontSize: 11.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6.h),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: color,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class _DetailsUpcomingButton extends StatefulWidget {
  final ConsultationModel consultation;
  final VoidCallback onEnter;
  final VoidCallback? onReschedule;

  const _DetailsUpcomingButton({
    required this.consultation,
    required this.onEnter,
    this.onReschedule,
  });

  @override
  State<_DetailsUpcomingButton> createState() => _DetailsUpcomingButtonState();
}

class _DetailsUpcomingButtonState extends State<_DetailsUpcomingButton> {
  Timer? _timer;
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    if (widget.consultation.status != ConsultationStatus.upcoming) {
      _remaining = Duration.zero;
      return;
    }
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateRemaining();
    });
  }

  void _updateRemaining() {
    if (widget.consultation.status != ConsultationStatus.upcoming) {
      _timer?.cancel();
      return;
    }
    final dt = _correctServerTime(widget.consultation.effectiveStartDateTime);
    if (dt == null) {
      setState(() => _remaining = null);
      return;
    }
    final nowMs = DateTime.now().toLocal().millisecondsSinceEpoch;
    final startMs = dt.toLocal().millisecondsSinceEpoch;
    final diffMs = startMs - nowMs;
    if (diffMs <= 0) {
      setState(() => _remaining = Duration.zero);
      _timer?.cancel();
    } else {
      setState(() => _remaining = Duration(milliseconds: diffMs));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _canEnter => _remaining == null || _remaining! == Duration.zero;

  String _fmtCountdown(Duration d) {
    final h = d.inHours;
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    if (h > 0) return '${h.toString().padLeft(2, '0')}:$m:$s';
    return '$m:$s';
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CustomConfirmationDialog(
        title: Loc.confirmCancellation(),
        description: Loc.cancelAppointmentConfirmation(),
        icon: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE53935),
              width: 2.5,
            ),
          ),
          child: const Icon(
            Icons.close_rounded,
            color: Color(0xFFE53935),
            size: 34,
          ),
        ),
        confirmText: Loc.yes(),
        cancelText: Loc.no(),
        onConfirm: () {
          context.read<ConsultationsCubit>().cancelConsultation(
            consultationId: widget.consultation.id,
          );
        },
        onCancel: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    if (_canEnter) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
        child: SizedBox(
          width: double.infinity,
          height: 54.h,
          child: GradiantButton(text: Loc.join(), onTap: widget.onEnter),
        ),
      );
    }

    final remaining = _remaining!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 18.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.1),
                  primaryColor.withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(_UI.radiusMd),
              border: Border.all(color: primaryColor.withOpacity(0.18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46.w,
                  height: 46.h,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child:
                  Icon(Icons.timer_outlined, color: primaryColor, size: 22.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Loc.nextSessionAppointment(),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        Loc.sessionStartsIn(),
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _fmtCountdown(remaining),
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(

            child: Opacity(
              opacity: 0.4,
              child: GradiantButton(text: Loc.enterSession(), onTap: null),
            ),
          ),
          SizedBox(height: 6.h),
          Center(
            child: Text(
              Loc.buttonEnabledWhenSessionStarts(),
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 11.sp,
              ),
            ),
          ),
          if (widget.onReschedule != null &&
              getIt<CacheHelper>().cachedVendorType == VendorType.user) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46.h,
                    child: Material(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12.h),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.h),
                        onTap: widget.onReschedule,
                        child: Center(
                          child: Text(
                            Loc.reschedule(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Gap(10.w),
                Expanded(
                  child: SizedBox(
                    height: 46.h,
                    child: Material(
                      color: primaryColor.withOpacity(.1),
                      borderRadius: BorderRadius.circular(12.h),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.h),
                        onTap: () => _confirmCancel(context),
                        child: Center(
                          child: Text(
                            Loc.cancel(),
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}


class _DetailsCancelledNotice extends StatelessWidget {
  const _DetailsCancelledNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(_UI.radiusMd),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: Icon(Icons.error_outline, size: 18.sp, color: Colors.red.shade400),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Text(
                Loc.paymentDeadlineExpired(),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _DetailsDisputeNotice extends StatelessWidget {
  final ConsultationModel consultation;

  const _DetailsDisputeNotice({required this.consultation});

  @override
  Widget build(BuildContext context) {
    final dispute = consultation.dispute;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.06),
            borderRadius: BorderRadius.circular(_UI.radiusMd),
            border: Border.all(color: Colors.orange.withOpacity(0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Icon(Icons.gavel_outlined,
                    size: 18.sp, color: Colors.orange.shade700),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Text(
                    dispute?.reason ?? Loc.disputeOpenedOnConsultation(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          child: GradiantButton(
            text: Loc.viewDisputeDetails(),
            onTap: () => showDialog<void>(
              context: context,
              builder: (_) => _DisputeDetailsPopup(consultation: consultation),
            ),
          ),
        ),
      ],
    );
  }
}


class _DisputeDetailsPopup extends StatelessWidget {
  final ConsultationModel consultation;

  const _DisputeDetailsPopup({required this.consultation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dispute = consultation.dispute;

    return Dialog(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.w),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16),
                    ),
                  ),
                  Gap(16.w),
                  Text(
                    consultation.type == "instant"
                        ? Loc.instantConsultationAlt()
                        : consultation.type == "written"
                        ? Loc.writtenConsultationAlt()
                        : consultation.type == "scheduled"
                        ? Loc.scheduledConsultationAlt()
                        : Loc.unknown(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              GeneralDivider(),
              SizedBox(height: 10.h),

              if (dispute?.disputeNumber != null &&
                  dispute!.disputeNumber!.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    Loc.disputeNumberLabel(dispute.disputeNumber),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  Loc.disputeReason(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  dispute?.reason ?? '—',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14.sp,
                  ),
                ),
              ),

              if (dispute?.description != null) ...[
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    Loc.disputeDetails(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    dispute!.description!,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],

              if (dispute?.status != null) ...[
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    Loc.disputeStatus(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _translateDisputeStatus(dispute!.status!),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],

              if (dispute?.status != null &&
                  dispute!.status!.toLowerCase() == 'closed' &&
                  dispute.decision != null &&
                  dispute.decision!.toLowerCase() != 'none') ...[
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    Loc.decisionTaken(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _translateDisputeDecision(dispute.decision!),
                    style: TextStyle(
                      color: dispute.decision!.toLowerCase() == 'lawyer'
                          ? Colors.blue.shade700
                          : Colors.green.shade700,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              SizedBox(height: 10.h),
              GeneralDivider(),
              SizedBox(height: 10.h),

              GradiantButton(
                text: Loc.done(),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _translateDisputeStatus(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Loc.statusOpen();
      case 'under review':
        return Loc.underReview();
      case 'closed':
        return Loc.statusClosed();
      default:
        return status;
    }
  }

  String _translateDisputeDecision(String decision) {
    switch (decision.toLowerCase()) {
      case 'lawyer':
        return Loc.disputeResolvedForLawyer();
      case 'client':
        return Loc.disputeResolvedForClient();
      default:
        return decision;
    }
  }
}




class _DetailsRatingBottomSheet extends StatefulWidget {
  final ConsultationModel consultation;

  const _DetailsRatingBottomSheet({required this.consultation});

  @override
  State<_DetailsRatingBottomSheet> createState() =>
      _DetailsRatingBottomSheetState();
}

class _DetailsRatingBottomSheetState extends State<_DetailsRatingBottomSheet> {
  int _stars = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    context.read<ConsultationsCubit>().rateConsultation(
      consultation: widget.consultation,
      stars: _stars,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<ConsultationsCubit, ConsultationsState>(
      listenWhen: (_, curr) =>
      (curr is ConsultationRatingSubmitted &&
          curr.consultationId == widget.consultation.id) ||
          (curr is ConsultationRatingError &&
              curr.consultationId == widget.consultation.id),
      listener: (context, state) {
        if (state is ConsultationRatingSubmitted ||
            state is ConsultationRatingError) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isSubmitting = state is ConsultationRatingSubmitting &&
            state.consultationId == widget.consultation.id;

        return Padding(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.w)),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: isSubmitting ? null : () => Navigator.pop(context),
                    child: Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(Icons.person, size: 36.sp, color: Colors.white),
                ),
                SizedBox(height: 14.h),
                Text(
                  Loc.rateYourExperience(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  Loc.ratingReflectsSatisfaction(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
                ),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final starIndex = i + 1;
                    final filled = starIndex <= _stars;
                    return GestureDetector(
                      onTap: isSubmitting
                          ? null
                          : () => setState(() => _stars = starIndex),
                      child: AnimatedScale(
                        scale: filled ? 1.0 : 0.9,
                        duration: const Duration(milliseconds: 150),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            filled ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 34.sp,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 18.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    Loc.howWasYourExperienceTellUs(),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_UI.radiusSm),
                    color: isDark
                        ? Colors.white.withOpacity(0.03)
                        : Colors.grey.shade50,
                  ),
                  child: TextField(
                    controller: _commentController,
                    enabled: !isSubmitting,
                    maxLines: 4,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: Loc.writeHereAlt(),
                      hintTextDirection: TextDirection.rtl,
                      contentPadding: EdgeInsets.all(12.w),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(_UI.radiusSm),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(_UI.radiusSm),
                        borderSide:
                        BorderSide(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: isSubmitting
                      ? Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(50.w),
                    ),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 22.w,
                      height: 40.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                      : GradiantButton(
                    text: Loc.sendNow(),
                    onTap: () => _submit(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class _FileIcon extends StatelessWidget {
  const _FileIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.insert_drive_file_outlined,
        color: Colors.grey.shade400,
        size: 30,
      ),
    );
  }
}