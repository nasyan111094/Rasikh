/*
// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/consultation/consultation_details_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:gap/gap.dart';
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

import 'Bloc/consultation_details_cubit.dart';
import 'Bloc/consultations_cubit.dart';
import 'Bloc/consultations_states.dart';
import 'models/consultation_model.dart';

// NOTE: these two imports are reused verbatim from consultations_screen.dart,
// which lives alongside this file. `CustomConfirmationDialog` is a public
// class defined there (used for the cancel-confirmation dialog below), and
// AppointmentBookingScreen is the same reschedule flow the card uses.
// Double check these paths resolve correctly for your actual folder layout.
import '../../User/application/appointment_booking_screen(3.3).dart';
import 'consultations_screen.dart';

const String _kBaseUrl = 'http://89.117.60.202:3050';

/// The backend stores Riyadh local time (UTC+3) but tags it with a trailing
/// `Z`, mislabeling it as UTC. Every timestamp coming from the API is
/// therefore 3 hours ahead of the real intended moment. This helper corrects
/// that before the value is used for display or countdown math anywhere in
/// this screen. Mirrors the same fix applied in consultations_screen.dart.
DateTime? _correctServerTime(DateTime? dt) {
  if (dt == null) return null;
  return dt.toLocal().add(const Duration(hours: 0));
}

// ── Screen ────────────────────────────────────────────────────────────────────

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

  /// True once a session can actually be entered: either it's already
  /// [active], or it's [upcoming] AND its corrected start time has been
  /// reached. Mirrors `_canEnterSession` in consultations_screen.dart so the
  /// behaviour stays consistent between the list and the details screen.
  bool _canEnterSession(ConsultationModel item) {
    if (item.status == ConsultationStatus.active) return true;
    if (item.status == ConsultationStatus.upcoming) {
      final start = _correctServerTime(item.effectiveStartDateTime);
      if (start == null) return true;
      return !DateTime.now().isBefore(start .toLocal  ());
    }
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

  /// Mirrors `_buildBottomAction` in consultations_screen.dart: an
  /// exhaustive, status-driven switch so every status the card already
  /// knows how to render also gets a matching (visually consistent)
  /// treatment here, instead of silently rendering nothing.
  List<Widget> _buildStatusAction(
      BuildContext context, ConsultationModel consultation) {
    switch (consultation.status) {
      case ConsultationStatus.active:
        return [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: SizedBox(
              width: double.infinity,
              child: GradiantButton(
                text: "أدخل الجلسه",
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
              // Same reschedule flow the card opens from
              // `_UpcomingSessionButton`. Only buildable when we know which
              // lawyer the consultation belongs to.
              onReschedule: consultation.lawyer == null
                  ? null
                  : () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AppointmentBookingScreen(
                    lawyerId: consultation.lawyer!.id,
                    consultationId: consultation.id,
                    isRescheduleMode: true,
                    onRescheduleConfirmed: (d) {
                      context.read<ConsultationsCubit>().rescheduleConsultation(
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
      // The card shows two buttons here ("عرض الملخص" + "إضافة تقييم"),
      // but "عرض الملخص" just opens this very details screen — which is
      // redundant since the summary is already shown inline in the body
      // above. So only the rating action carries over here.
        return [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: SizedBox(
              width: double.infinity,
              child: GradiantButton(
                text: 'إضافة تقييم',
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => BlocProvider.value(
                    value: context.read<ConsultationsCubit>(),
                    child: _DetailsRatingBottomSheet(consultation: consultation),
                  ),
                ),
              ),
            ),
          ),
        ];

    // "none" is not a real status that comes back from the backend (it's
    // the local "no filter" sentinel), so nothing renders for it, same as
    // before.
      case ConsultationStatus.none:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Directionality(
        textDirection: Directionality.of(context),
        child: BlocBuilder<ConsultationDetailsCubit, ConsultationDetailsState>(
          builder: (context, state) {
            return Column(
              children: [
                _DetailsAppBar(onBack: () => Navigator.pop(context)),
                Expanded(child: _buildBody(context, state, theme)),

                if (state is ConsultationDetailsLoaded)
                  ..._buildStatusAction(context, state.consultation),
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
      return const SingleChildScrollView(child: ConsultationDetailsShimmer());
    }

    if (state is ConsultationDetailsError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 56.w, color: Colors.grey.shade400),
              SizedBox(height: 12.h),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey.shade600),
              ),
              SizedBox(height: 16.h),
              GradiantButton(
                text: "إعادة المحاولة",
                onTap: () => context
                    .read<ConsultationDetailsCubit>()
                    .fetchDetails(id: widget.consultationId),
              ),
            ],
          ),
        ),
      );
    }

    if (state is ConsultationDetailsLoaded) {
      return _DetailsContent(consultation: state.consultation);
    }

    return const SizedBox.shrink();
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _DetailsAppBar extends StatelessWidget {
  final VoidCallback onBack;
  const _DetailsAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 8.h,
        bottom: 12.h,
        left: 16.w,
        right: 16.w,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10.w),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.arrow_back_outlined, size: 18),
            ),
          ),
          Gap(10.w),
          Text(
            "تفاصيل الإستشارة",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 17.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Details Content ───────────────────────────────────────────────────────────

class _DetailsContent extends StatelessWidget {
  final ConsultationModel consultation;
  const _DetailsContent({required this.consultation});

  // ✅ Now matches `_typeLabel` in consultations_screen.dart exactly,
  // including the previously-missing "written" case (was falling through
  // to the raw "written" string instead of the Arabic label).
  String _typeLabel(String type) {
    switch (type) {
      case 'instant':
        return 'إستشارة فورية';
      case 'scheduled':
        return 'إستشارة مجدولة';
      case 'written':
        return 'إستشارة كتابيه';
      default:
        return type;
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
    AppLogger.info(_formatDateTime(_correctServerTime(consultation.effectiveStartDateTime)) );
    final priceLabel = consultation.priceInSar != null
        ? '${consultation.priceInSar!.toStringAsFixed(0)} ${consultation.currency ?? 'SAR'}'
        : '—';

    // ✅ Correct the mislabeled server timestamp before formatting/display.
    final startLabel = _formatDateTime(_correctServerTime(consultation.effectiveStartDateTime),



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
        final period = hour24 >= 12 ? ' مساءً' : ' صباحًا';

        final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

        timeDisplay =
        '${hour12.toString().padLeft(2, '0')}:$minute$period';
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Client ───────────────────────────────────────────────────────
          if (consultation.client != null &&
              !consultation.hideClientFromLawyer) ...[
            _ClientCard(client: getIt<CacheHelper>().cachedVendorType == VendorType.user ? consultation.lawyer  : consultation.client!),
            SizedBox(height: 16.h),
          ],

          // ── Type + number + status badge ────────────────────────────────
          // Mirrors the card header in consultations_screen.dart: type/number
          // on one side, the same colour-coded status badge on the other, so
          // the lawyer can tell a consultation's status at a glance here too.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _typeLabel(consultation.type),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      consultation.consultationNumber,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(8.w),
              _DetailsStatusBadge(status: consultation.status),
            ],
          ),
          SizedBox(height: 16.h),

          // ── Specialization ───────────────────────────────────────────────
          _SectionLabel(label: "التخصص"),
          SizedBox(height: 4.h),
          Text(
            consultation.specialization?.name ?? '—',
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
          ),
          if (consultation.subSpecializations.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 4.h,
              alignment: WrapAlignment.start,
              children: consultation.subSpecializations.map((s) {
                return Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(50.w),
                  ),
                  child: Text(
                    s.name,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          SizedBox(height: 16.h),

          // ── Title ────────────────────────────────────────────────────────
          _SectionLabel(label: "عنوان الاستشارة"),
          SizedBox(height: 4.h),
          Text(
            consultation.title,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),

          // ── Details ──────────────────────────────────────────────────────
          if (consultation.details != null) ...[
            SizedBox(height: 12.h),
            _SectionLabel(label: "وصف الاستشارة"),
            SizedBox(height: 4.h),
            Text(
              consultation.details!,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontSize: 13.sp,
                height: 1.6,
              ),
            ),
          ],
          SizedBox(height: 16.h),
          GeneralDivider(height: 0),
          SizedBox(height: 16.h),

          // ── Summary ──────────────────────────────────────────────────────
          if (consultation.summary != null) ...[
            _SectionLabel(label: "ملخص الجلسة"),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10.w),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                consultation.summary!,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                  fontSize: 13.sp,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            GeneralDivider(height: 0),
            SizedBox(height: 16.h),
          ],

          // ── Time, Price & Duration ───────────────────────────────────────
          _SectionLabel(label: "الوقت والسعر"),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoColumn(label: "تاريخ البدء", value: datePart),
              _VerticalDivider(),
              _InfoColumn(label: "وقت البدء", value: timeDisplay),
              if (consultation.durationMin != null) ...[
                _VerticalDivider(),
                _InfoColumn(
                  label: "المدة",
                  value: "${consultation.durationMin} دقيقة",
                  valueColor: theme.colorScheme.primary,
                ),
              ],
            ],
          ),
          SizedBox(height: 16.h),
          GeneralDivider(height: 0),
          SizedBox(height: 16.h),

          // ── Voice Note ───────────────────────────────────────────────────
          if (consultation.voiceNoteUrl != null) ...[
            _SectionLabel(label: "مذكرة صوتية"),
            SizedBox(height: 12.h),
            _VoiceNotePlayer(
              url: consultation.voiceNoteUrl!,
              fallbackDurationSeconds:
              consultation.voiceNoteDurationSeconds ?? 0,
            ),
            SizedBox(height: 16.h),
          ],

          // ── Attachments ──────────────────────────────────────────────────
          if (consultation.attachments.isNotEmpty) ...[
            _SectionLabel(label: "المرفقات"),
            SizedBox(height: 4.h),
            // Counter badge
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.h),
                ),
                child: Text(
                  '${consultation.attachments.length}/5',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            _AttachmentsGrid(attachments: consultation.attachments),
            SizedBox(height: 24.h),
          ],
        ],
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────
//
// Visual twin of `_StatusBadge` in consultations_screen.dart. Kept as a
// separate, file-local copy here because that widget is private to its own
// file — but the styling and labels are intentionally identical so a
// consultation's status badge looks the same whether the lawyer is viewing
// it from the list or from this details screen.

class _DetailsStatusBadge extends StatelessWidget {
  final ConsultationStatus status;

  const _DetailsStatusBadge({required this.status});

  Color get _bgColor {
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
    }
  }

  Color get _textColor {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(50.w),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _SectionLabel({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon ?? Icons.label_rounded,
          color: cs.primary,
          size: 18.sp,
        ),
        Gap(12.w),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Info Column ───────────────────────────────────────────────────────────────

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

// ── Vertical Divider ──────────────────────────────────────────────────────────

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.h,
      width: 2.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50.w),
      ),
    );
  }
}

// ── Client Card ───────────────────────────────────────────────────────────────

class _ClientCard extends StatelessWidget {
  final  client;
  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final hasCity =
        client.city != null && client.city!.trim().isNotEmpty;

    final initials = client.fullName.trim().isNotEmpty
        ? client.fullName.trim()[0].toUpperCase()
        : '?';

    // ✅ Same photo source the card uses for a lawyer viewing a client
    // (`_ClientInfoRow` -> AppConfig.baseImgUrl + client.avatar). Falls
    // back to the gradient-initials avatar — unchanged from before — if
    // there's no photo, or if loading it fails.

    final userType = getIt<CacheHelper>().cachedVendorType ;

    final hasPhoto = userType == VendorType.lawyer ? client.avatar?.isNotEmpty :   client.photoUrl?.isNotEmpty  ;
    final photoUrl = hasPhoto ? '${AppConfig.baseImgUrl}${userType == VendorType.lawyer ? client.avatar :   client.photoUrl}' : null;

    final initialsAvatar = Container(
      width: 50.w,
      height: 50.w,
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
      width: 50.w,
      height: 50.w,
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
                  fontSize: 13.sp,
                  letterSpacing: .2,
                ),
              ),
              Gap(5.h),
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

// ── Voice Note Player ─────────────────────────────────────────────────────────

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
      // Set source with timeout (60 seconds for network audio)
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
      if (mounted) setState(() { _isLoading = false; _hasError = true; });
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
          setState(() { _position = Duration.zero; _isCompleted = false; });
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
      // Increase timeout to 60 seconds for network audio operations
      await _player.seek(Duration(milliseconds: ms.toInt())).timeout(
        const Duration(seconds: 60),
        onTimeout: () => Future.error('Seek timeout'),
      );
      if (_isCompleted) setState(() => _isCompleted = false);
    } catch (e) {
      // Log the error but don't fail - audio playback can continue from current position
      print('Seek error: $e');
      if (mounted) {
        // Only show error on critical failures, not on seek timeouts
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
    final posMs =
    _position.inMilliseconds.toDouble().clamp(0.0, totalMs > 0 ? totalMs : 1.0);

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
              "تعذّر تشغيل المقطع الصوتي",
              style: TextStyle(color: Colors.red.shade500, fontSize: 13.sp),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14.w),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 46.w,
              height: 46.h,
              decoration: BoxDecoration(
                color: _isLoading ? Colors.grey.shade300 : primaryColor,
                shape: BoxShape.circle,
              ),
              child: _isLoading
                  ? Padding(
                padding: EdgeInsets.all(13.w),
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
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3.5.h,
                    thumbShape:
                    RoundSliderThumbShape(enabledThumbRadius: 6.w),
                    overlayShape:
                    RoundSliderOverlayShape(overlayRadius: 14.w),
                    activeTrackColor: primaryColor,
                    inactiveTrackColor: Colors.grey.shade300,
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
                              fontWeight: FontWeight.w500)),
                      Text(_fmt(_total),
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500)),
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

// ── Attachments Grid ──────────────────────────────────────────────────────────

class _AttachmentsGrid extends StatelessWidget {
  final List<ConsultationAttachment> attachments;
  const _AttachmentsGrid({required this.attachments});

  String _resolveUrl(String url) =>
      url.startsWith('http') ? url : '$_kBaseUrl$url';

  String _extension(String url) {
    final clean = url.split('?').first;
    final name = clean.split('/').last;
    return name.contains('.')
        ? name.split('.').last.toLowerCase()
        : '';
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
        return 'فيديو';
      case 'mp3':
      case 'm4a':
      case 'wav':
        return 'صوت';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'صورة';
      default:
        return ext.isEmpty ? 'ملف' : ext.toUpperCase();
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

        // Extract file name from URL
        final rawName = attachment.url.split('?').first.split('/').last;
        final displayName = rawName.isNotEmpty ? rawName : 'مرفق ${index + 1}';

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
              borderRadius: BorderRadius.circular(12.h),
            ),
            child: Row(
              children: [
                // ── Thumbnail or icon ──────────────────────────────────
                Container(
                  width: 40.h,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8.h),
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

                // ── Name + type badge ──────────────────────────────────
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

// ── Upcoming Session Button ───────────────────────────────────────────────────

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
    // Defensive guard: this widget is only ever switched-in by
    // _LawyerConsultationDetailsScreenState's status switch for
    // ConsultationStatus.upcoming, but the check is kept here too so the
    // countdown can never start (or keep running) for any other status.
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
    // ✅ Correct the mislabeled server timestamp, and compare in UTC on both
    // sides — same fix as _UpcomingSessionButtonState in
    // consultations_screen.dart, so the two screens always agree.
    final dt = _correctServerTime(widget.consultation.effectiveStartDateTime);
    if (dt == null) {
      setState(() => _remaining = null);
      return;
    }
    final nowMs = DateTime.now() .toLocal  ().millisecondsSinceEpoch;
    final startMs = dt .toLocal  ().millisecondsSinceEpoch;
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
        title: 'تأكيد الإلغاء',
        description: 'هل أنت متأكد من رغبتك في إلغاء الموعد ؟',
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
        confirmText: 'نعم',
        cancelText: 'لا',
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
      return SizedBox(
        width: double.infinity,
        child: GradiantButton(text: "إنضمام", onTap: widget.onEnter),
      );
    }

    final remaining = _remaining!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14.w),
            border: Border.all(color: primaryColor.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.timer_outlined,
                    color: primaryColor, size: 22.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "موعد الجلسة القادمة",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      "تبدأ الجلسة خلال",
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
        Opacity(
          opacity: 0.4,
          child: GradiantButton(text: "أدخل الجلسه", onTap: null),
        ),
        SizedBox(height: 4.h),
        Center(
          child: Text(
            "سيتم تفعيل الزر عند بدء الجلسة",
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 11.sp,
            ),
          ),
        ),
        // ✅ Same reschedule + cancel pair the card shows under the
        // countdown in `_UpcomingSessionButton`, gated by the same
        // vendor-type condition.
        if (widget.onReschedule != null &&
            getIt<CacheHelper>().cachedVendorType == VendorType.user) ...[
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.h),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.h),
                      onTap: widget.onReschedule,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Center(
                          child: Text(
                            'إعادة الجدولة',
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
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: primaryColor.withOpacity(.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.h),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.h),
                      onTap: () => _confirmCancel(context),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Center(
                          child: Text(
                            'إلغاء',
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
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Cancelled Notice ──────────────────────────────────────────────────────────
//
// Visual twin of `_CancelledWarningBanner` in consultations_screen.dart.
// Kept as a separate, file-local copy because that widget is private to its
// own file — but the styling/wording is intentionally identical so a
// cancelled consultation looks the same whether the lawyer is viewing it
// from the list or from this details screen.

class _DetailsCancelledNotice extends StatelessWidget {
  const _DetailsCancelledNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10.w),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18.sp, color: Colors.red.shade400),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'انتهت مهلة الدفع. يرجى إعادة الحجز بدلاً من الدفع.',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dispute Notice ────────────────────────────────────────────────────────────
//
// Until now, a "disputes" consultation rendered nothing at all on this
// screen even though `consultation.dispute` already carries the reason,
// description, status, decision and amount from the backend. This shows a
// compact summary inline (same colour language as the card's dispute
// button) and opens a full popup — styled like `_DisputeDetailsPopup` in
// consultations_screen.dart — for the rest of the details.

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
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10.w),
            border: Border.all(color: Colors.orange.withOpacity(0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.gavel_outlined,
                  size: 18.sp, color: Colors.orange.shade700),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  dispute?.reason ?? 'تم فتح نزاع على هذه الاستشارة',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        GradiantButton(
          text: 'عرض تفاصيل النزاع',
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) => _DetailsDisputePopup(consultation: consultation),
          ),
        ),
      ],
    );
  }
}

class _DetailsDisputePopup extends StatelessWidget {
  final ConsultationModel consultation;

  const _DetailsDisputePopup({required this.consultation});

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
                  'تفاصيل النزاع',
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

            if (dispute?.disputeNumber != null) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'رقم النزاع: ${dispute!.disputeNumber}',
                  style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
                ),
              ),
              SizedBox(height: 12.h),
            ],

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'سبب النزاع',
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
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
              ),
            ),

            if (dispute?.description != null) ...[
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'تفاصيل النزاع',
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
                  style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
                ),
              ),
            ],

            if (dispute?.status != null || dispute?.decision != null) ...[
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (dispute?.status != null)
                    _InfoColumn(label: 'حالة النزاع', value: dispute!.status!),
                  if (dispute?.decision != null)
                    _InfoColumn(label: 'القرار', value: dispute!.decision!),
                ],
              ),
            ],

            SizedBox(height: 10.h),
            GeneralDivider(),
            SizedBox(height: 10.h),
            GradiantButton(text: 'تم', onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

// ── Rating Bottom Sheet ────────────────────────────────────────────────────────
//
// Visual + behavioral twin of `_RatingBottomSheet` in consultations_screen.dart.
// Kept as a separate, file-local copy because that widget is private to its
// own file — but the styling, copy, and BLoC wiring (ConsultationsCubit) are
// intentionally identical so completing a rating looks and works the same
// whether started from the list or from this details screen.

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
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                CircleAvatar(
                  radius: 36.w,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(Icons.person,
                      size: 36.sp, color: theme.colorScheme.primary),
                ),
                SizedBox(height: 14.h),
                Text(
                  'قيّم تجربتك معنا',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'تقييمك يعكس مدى رضاك ويساعدنا على التحسين.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final starIndex = i + 1;
                    final filled = starIndex <= _stars;
                    return GestureDetector(
                      onTap: isSubmitting
                          ? null
                          : () => setState(() => _stars = starIndex),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Icon(
                          filled ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32.sp,
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'كيف كانت تجربتك؟ احكي لنا',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _commentController,
                  enabled: !isSubmitting,
                  maxLines: 4,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'أكتب هنا ...',
                    hintTextDirection: TextDirection.rtl,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.w),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
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
                    text: 'إرسال الآن',
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

// ── File Icon Fallback ────────────────────────────────────────────────────────

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
}*/

// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/consultation/consultation_details_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:gap/gap.dart';
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

import 'Bloc/consultation_details_cubit.dart';
import 'Bloc/consultations_cubit.dart';
import 'Bloc/consultations_states.dart';
import 'models/consultation_model.dart';

// NOTE: these two imports are reused verbatim from consultations_screen.dart,
// which lives alongside this file. `CustomConfirmationDialog` is a public
// class defined there (used for the cancel-confirmation dialog below), and
// AppointmentBookingScreen is the same reschedule flow the card uses.
import '../../User/application/appointment_booking_screen(3.3).dart';
import 'consultations_screen.dart';

const String _kBaseUrl = 'http://89.117.60.202:3050';

/// The backend stores Riyadh local time (UTC+3) but tags it with a trailing
/// `Z`, mislabeling it as UTC. Every timestamp coming from the API is
/// therefore 3 hours ahead of the real intended moment. This helper corrects
/// that before the value is used for display or countdown math anywhere in
/// this screen. Mirrors the same fix applied in consultations_screen.dart.
DateTime? _correctServerTime(DateTime? dt) {
  if (dt == null) return null;
  return dt.toLocal().add(const Duration(hours: 0));
}

// ── Design tokens (local to this screen) ───────────────────────────────────

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

// ── Screen ────────────────────────────────────────────────────────────────────

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

  /// True once a session can actually be entered: either it's already
  /// [active], or it's [upcoming] AND its corrected start time has been
  /// reached. Mirrors `_canEnterSession` in consultations_screen.dart so the
  /// behaviour stays consistent between the list and the details screen.
  bool _canEnterSession(ConsultationModel item) {
    if (item.status == ConsultationStatus.active) return true;
    if (item.status == ConsultationStatus.upcoming) {
      final start = _correctServerTime(item.effectiveStartDateTime);
      if (start == null) return true;
      return !DateTime.now().isBefore(start.toLocal());
    }
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

  /// Mirrors `_buildBottomAction` in consultations_screen.dart: an
  /// exhaustive, status-driven switch so every status the card already
  /// knows how to render also gets a matching (visually consistent)
  /// treatment here, instead of silently rendering nothing.
  List<Widget> _buildStatusAction(
      BuildContext context, ConsultationModel consultation) {
    switch (consultation.status) {
      case ConsultationStatus.active:
        return [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: SizedBox(
              width: double.infinity,
              height: 54.h,
              child: GradiantButton(
                text: "أدخل الجلسه",
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
              // Same reschedule flow the card opens from
              // `_UpcomingSessionButton`. Only buildable when we know which
              // lawyer the consultation belongs to.
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
      // The card shows two buttons here ("عرض الملخص" + "إضافة تقييم"),
      // but "عرض الملخص" just opens this very details screen — which is
      // redundant since the summary is already shown inline in the body
      // above. So only the rating action carries over here.
        return [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: SizedBox(
              width: double.infinity,

              child: GradiantButton(
                text: 'إضافة تقييم',
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

    // "none" is not a real status that comes back from the backend (it's
    // the local "no filter" sentinel), so nothing renders for it, same as
    // before.
      case ConsultationStatus.none:
        return const [];
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
                  text: "إعادة المحاولة",
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

// ── App Bar ───────────────────────────────────────────────────────────────────

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
                  "تفاصيل الإستشارة",
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

// ── Section Card wrapper ──────────────────────────────────────────────────────
//
// Gives every block on this screen a consistent elevated-card treatment
// (white surface, soft shadow, rounded corners) instead of everything
// floating flush against the scaffold background.

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

// ── Details Content ───────────────────────────────────────────────────────────

class _DetailsContent extends StatelessWidget {
  final ConsultationModel consultation;
  const _DetailsContent({super.key, required this.consultation});

  // ✅ Matches `_typeLabel` in consultations_screen.dart exactly, including
  // the "written" case.
  String _typeLabel(String type) {
    switch (type) {
      case 'instant':
        return 'إستشارة فورية';
      case 'scheduled':
        return 'إستشارة مجدولة';
      case 'written':
        return 'إستشارة كتابيه';
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
        ? '${consultation.priceInSar!.toStringAsFixed(0)} ${'ريال'}'
        : '—';

    // ✅ Correct the mislabeled server timestamp before formatting/display.
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
        final period = hour24 >= 12 ? ' مساءً' : ' صباحًا';
        final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
        timeDisplay = '${hour12.toString().padLeft(2, '0')}:$minute$period';
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero: type + number + status ────────────────────────────────
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

          // ── Client ───────────────────────────────────────────────────────
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

          // ── Specialization ───────────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: "التخصص", icon: Icons.workspace_premium_rounded),
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

          // ── Title + Details ──────────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: "عنوان الاستشارة", icon: Icons.title_rounded),
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
                  _SectionLabel(label: "وصف الاستشارة", icon: Icons.notes_rounded),
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

          // ── Summary ──────────────────────────────────────────────────────
          if (consultation.summary != null) ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(
                      label: "ملخص الجلسة", icon: Icons.summarize_rounded),
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

          // ── Time, Price & Duration ───────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(
                    label: "الوقت والسعر", icon: Icons.schedule_rounded),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: Icons.event_rounded,
                        label: "تاريخ البدء",
                        value: datePart,
                        color: Colors.indigo,
                      ),
                    ),
                    Gap(10.w),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.access_time_filled_rounded,
                        label: "وقت البدء",
                        value: timeDisplay,
                        color: Colors.teal,
                      ),
                    ),
                    if (consultation.durationMin != null) ...[
                      Gap(10.w),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.timer_rounded,
                          label: "المدة",
                          value: "${consultation.durationMin} د",
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
                                "السعر الإجمالي",
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

          // ── Voice Note ───────────────────────────────────────────────────
          if (consultation.voiceNoteUrl != null) ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(label: "مذكرة صوتية", icon: Icons.mic_rounded),
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

          // ── Attachments ──────────────────────────────────────────────────
          if (consultation.attachments.isNotEmpty) ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _SectionLabel(
                            label: "المرفقات", icon: Icons.attach_file_rounded),
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

// ── Stat Tile (time/price/duration) ───────────────────────────────────────────

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

// ── Status Badge ──────────────────────────────────────────────────────────────

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

// ── Section Label ─────────────────────────────────────────────────────────────

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

// ── Info Column (kept for the dispute popup) ──────────────────────────────────

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

// ── Client Card ───────────────────────────────────────────────────────────────

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

    // ✅ Same photo source the card uses for a lawyer viewing a client
    // (`_ClientInfoRow` -> AppConfig.baseImgUrl + client.avatar). Falls
    // back to the gradient-initials avatar if there's no photo, or if
    // loading it fails.
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

// ── Voice Note Player ─────────────────────────────────────────────────────────

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
      // Set source with timeout (60 seconds for network audio)
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
      // Increase timeout to 60 seconds for network audio operations
      await _player.seek(Duration(milliseconds: ms.toInt())).timeout(
        const Duration(seconds: 60),
        onTimeout: () => Future.error('Seek timeout'),
      );
      if (_isCompleted) setState(() => _isCompleted = false);
    } catch (e) {
      // Log the error but don't fail - audio playback can continue from current position
      print('Seek error: $e');
      if (mounted) {
        // Only show error on critical failures, not on seek timeouts
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
              "تعذّر تشغيل المقطع الصوتي",
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

// ── Attachments Grid ──────────────────────────────────────────────────────────

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
        return 'فيديو';
      case 'mp3':
      case 'm4a':
      case 'wav':
        return 'صوت';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'صورة';
      default:
        return ext.isEmpty ? 'ملف' : ext.toUpperCase();
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
        final displayName = rawName.isNotEmpty ? rawName : 'مرفق ${index + 1}';

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

// ── Upcoming Session Button ───────────────────────────────────────────────────

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
    // Defensive guard: this widget is only ever switched-in by
    // _LawyerConsultationDetailsScreenState's status switch for
    // ConsultationStatus.upcoming, but the check is kept here too so the
    // countdown can never start (or keep running) for any other status.
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
    // ✅ Correct the mislabeled server timestamp, and compare in local time
    // on both sides — same fix as _UpcomingSessionButtonState in
    // consultations_screen.dart, so the two screens always agree.
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
        title: 'تأكيد الإلغاء',
        description: 'هل أنت متأكد من رغبتك في إلغاء الموعد ؟',
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
        confirmText: 'نعم',
        cancelText: 'لا',
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
          child: GradiantButton(text: "إنضمام", onTap: widget.onEnter),
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
                        "موعد الجلسة القادمة",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        "تبدأ الجلسة خلال",
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
              child: GradiantButton(text: "أدخل الجلسه", onTap: null),
            ),
          ),
          SizedBox(height: 6.h),
          Center(
            child: Text(
              "سيتم تفعيل الزر عند بدء الجلسة",
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 11.sp,
              ),
            ),
          ),
          // ✅ Same reschedule + cancel pair the card shows under the
          // countdown in `_UpcomingSessionButton`, gated by the same
          // vendor-type condition.
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
                            'إعادة الجدولة',
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
                            'إلغاء',
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

// ── Cancelled Notice ──────────────────────────────────────────────────────────

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
                'انتهت مهلة الدفع. يرجى إعادة الحجز بدلاً من الدفع.',
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

// ── Dispute Notice ────────────────────────────────────────────────────────────

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
                    dispute?.reason ?? 'تم فتح نزاع على هذه الاستشارة',
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
            text: 'عرض تفاصيل النزاع',
            onTap: () => showDialog<void>(
              context: context,
              builder: (_) => _DetailsDisputePopup(consultation: consultation),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailsDisputePopup extends StatelessWidget {
  final ConsultationModel consultation;

  const _DetailsDisputePopup({required this.consultation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dispute = consultation.dispute;

    return Dialog(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_UI.radiusLg),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
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
                  'تفاصيل النزاع',
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

            if (dispute?.disputeNumber != null) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'رقم النزاع: ${dispute!.disputeNumber}',
                  style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
                ),
              ),
              SizedBox(height: 12.h),
            ],

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'سبب النزاع',
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
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
              ),
            ),

            if (dispute?.description != null) ...[
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'تفاصيل النزاع',
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
                  style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
                ),
              ),
            ],

            if (dispute?.status != null || dispute?.decision != null) ...[
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (dispute?.status != null)
                    _InfoColumn(label: 'حالة النزاع', value: dispute!.status!),
                  if (dispute?.decision != null)
                    _InfoColumn(label: 'القرار', value: dispute!.decision!),
                ],
              ),
            ],

            SizedBox(height: 10.h),
            GeneralDivider(),
            SizedBox(height: 10.h),
            SizedBox(
              height: 50.h,
              child: GradiantButton(text: 'تم', onTap: () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rating Bottom Sheet ────────────────────────────────────────────────────────

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
                // Drag handle
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
                  'قيّم تجربتك معنا',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'تقييمك يعكس مدى رضاك ويساعدنا على التحسين.',
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
                    'كيف كانت تجربتك؟ احكي لنا',
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
                      hintText: 'أكتب هنا ...',
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
                    text: 'إرسال الآن',
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

// ── File Icon Fallback ────────────────────────────────────────────────────────

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
