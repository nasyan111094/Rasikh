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
import 'package:rasikh/features/Lawyer/consultation/widgets/consultation_shimmer.dart';
import 'package:size_config/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/general_divider.dart';
import '../../../../core/widgets/gradiant_button.dart';

import 'Bloc/consultation_details_cubit.dart';
import 'Bloc/consultations_states.dart';
import 'models/consultation_model.dart';

const String _kBaseUrl = 'http://89.117.60.202:3050';

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

                if (state is ConsultationDetailsLoaded) ...[
                  if (state.consultation.status == ConsultationStatus.active)
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                      child: SizedBox(
                        width: double.infinity,
                        child: GradiantButton(
                          text: "أدخل الجلسه",
                          onTap: () {},
                        ),
                      ),
                    )
                  else if (state.consultation.status ==
                      ConsultationStatus.upcoming)
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                      child: _DetailsUpcomingButton(
                        consultation: state.consultation,
                        onEnter: () {},
                      ),
                    ),
                ],
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

  String _typeLabel(String type) {
    switch (type) {
      case 'instant':
        return 'إستشارة فورية';
      case 'scheduled':
        return 'إستشارة مجدولة';
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

    final priceLabel = consultation.priceInSar != null
        ? '${consultation.priceInSar!.toStringAsFixed(0)} ${consultation.currency ?? 'SAR'}'
        : '—';

    final startLabel = _formatDateTime(consultation.effectiveStartDateTime);

    final parts = startLabel.trim().split(RegExp(r'\s+'));
    final datePart = parts.isNotEmpty ? parts.first : '—';
    final timePart = parts.length > 1 ? parts.last : '—';
    final hourValue =
    timePart == '—' ? null : int.tryParse(timePart.split(':').first);
    final amPm =
    hourValue == null ? '' : (hourValue >= 12 ? ' مساء' : ' صباحا');
    final timeDisplay = timePart == '—' ? '—' : '$timePart$amPm';

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Client ───────────────────────────────────────────────────────
          if (consultation.client != null &&
              !consultation.hideClientFromLawyer) ...[
            _ClientCard(client: consultation.client!),
            SizedBox(height: 16.h),
          ],

          // ── Type + number ────────────────────────────────────────────────
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
          color: primary,
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
  final ConsultationClient client;
  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasCity =
        client.city != null && client.city!.trim().isNotEmpty;

    final initials = client.fullName.trim().isNotEmpty
        ? client.fullName.trim()[0].toUpperCase()
        : '?';

    return Row(
      children: [
        Hero(
          tag: 'client_${client.id}',
          child: Container(
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
          ),
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
          Icon(icon, size: 14.sp, color: primary),
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

  const _DetailsUpcomingButton({
    required this.consultation,
    required this.onEnter,
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
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateRemaining();
    });
  }

  void _updateRemaining() {
    final dt = widget.consultation.effectiveStartDateTime;
    if (dt == null) {
      setState(() => _remaining = null);
      return;
    }
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final startMs = dt.millisecondsSinceEpoch;
    final diffMs = startMs - nowMs;
    setState(() =>
    _remaining = diffMs <= 0 ? Duration.zero : Duration(milliseconds: diffMs));
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
          child: GradiantButton(text: "أدخل الجلسه", onTap: () {}),
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
      ],
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