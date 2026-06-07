// ─────────────────────────────────────────────────────────────────────────────
// video_call_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rasikh/features/User/application/end_session_screen.dart';
import 'package:rasikh/features/common/layout/layout_screen.dart';
import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';
import 'bloc/video_call_cubit.dart';
import 'bloc/video_call_state.dart';
import 'dialogs/call_summary_dialog.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({
    Key? key,
    required this.consultationId,
    required this.lawyerId,
    required this.clientId,
    this.lawyerName,
    this.lawyerPhotoUrl,
  }) : super(key: key);

  final String consultationId;

  /// The IDs of the lawyer and client for this consultation.
  /// Must be passed from the caller (consultation list / detail screen)
  /// because the instant-session endpoint does not return them.
  final String lawyerId;
  final String clientId;

  final String? lawyerName;
  final String? lawyerPhotoUrl;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoCallCubit(
        consultationId: consultationId,
        lawyerName: lawyerName,
        lawyerPhotoUrl: lawyerPhotoUrl,
        lawyerId: lawyerId,
        clientId: clientId,
      )..initialize(),
      child: _VideoCallView(
        consultationId: consultationId,
        lawyerId: lawyerId,
        clientId: clientId,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal view — consumes VideoCallCubit
// ─────────────────────────────────────────────────────────────────────────────

class _VideoCallView extends StatefulWidget {
  const _VideoCallView({
    required this.consultationId,
    required this.lawyerId,
    required this.clientId,
  });

  final String consultationId;
  final String lawyerId;
  final String clientId;

  @override
  State<_VideoCallView> createState() => _VideoCallViewState();
}

class _VideoCallViewState extends State<_VideoCallView> {
  /// Guard: prevents the timer-expiry dialog from being shown more than once.
  bool _timerExpiredDialogShown = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<VideoCallCubit, VideoCallState>(
      listener: (context, state) async {
        // ── Timer expired: show summary (lawyer) or navigate to end (client)
        if (state.phase == VideoCallPhase.timerExpired &&
            !_timerExpiredDialogShown) {
          _timerExpiredDialogShown = true;
          await _handleTimerExpired(context);
          return;
        }

        // ── Server confirmed session ended ────────────────────────────────
        if (state.phase == VideoCallPhase.ended) {
          final cubit = context.read<VideoCallCubit>();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => cubit.isLawyer ? LayoutPage() : EndSessionScreen(
                consultationId: widget.consultationId,
                // Use widget fields — guaranteed non-empty from the caller
                lawyerId: widget.lawyerId,
                clientId: widget.clientId,
              ),
            ),
                (route) => false,
          );
        }
      },
      builder: (context, state) {
        // ── Permission gate ───────────────────────────────────────────────
        if (state.phase == VideoCallPhase.permissionDenied ||
            state.phase == VideoCallPhase.permissionPermanentlyDenied) {
          return _PermissionDeniedOverlay(
            permanentlyDenied:
            state.phase == VideoCallPhase.permissionPermanentlyDenied,
            missingPermissions: state.missingPermissions,
          );
        }

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: colorScheme.background,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // ── Remote video (full-screen background) ─────────────────
                _RemoteVideoView(state: state),

                // ── Top gradient ──────────────────────────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 160,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Top bar ───────────────────────────────────────────────
                Positioned(
                  top: 10.h,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        children: [
                          SizedBox(width: 12.w),
                          Text(
                            'استشارة فورية',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Two-minute warning banner ─────────────────────────────
                if (state.twoMinuteWarningActive)
                  Positioned(
                    top: 70,
                    left: 20,
                    right: 20,
                    child: _TwoMinuteWarningBanner(colorScheme: colorScheme),
                  ),

                // ── Local preview (floating) ──────────────────────────────
                Positioned(
                  top: 100,
                  right: 16,
                  child: _LocalPreviewView(state: state),
                ),

                // ── Waiting overlay ───────────────────────────────────────
                if (state.phase == VideoCallPhase.waitingForLawyer ||
                    state.phase == VideoCallPhase.initializing ||
                    state.phase == VideoCallPhase.agoraReady ||
                    state.phase == VideoCallPhase.joiningCall)
                  _WaitingOverlay(state: state),

                // ── Reconnecting overlay ──────────────────────────────────
                if (state.phase == VideoCallPhase.reconnecting)
                  _ReconnectingOverlay(
                      attempts: state.reconnectAttempts, max: 3),

                // ── Error overlay ─────────────────────────────────────────
                if (state.phase == VideoCallPhase.error)
                  _ErrorOverlay(message: state.errorMessage),

                // ── Bottom controls ───────────────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _BottomControls(
                    state: state,
                    consultationId: widget.consultationId,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Handles timer reaching 00:00 ─────────────────────────────────────────
  Future<void> _handleTimerExpired(BuildContext context) async {
    final cubit = context.read<VideoCallCubit>();

    if (cubit.isLawyer) {
      await showCallSummaryDialog(
        context,
        onSubmit: (summary) async {
          await cubit.submitCallSummary(summary);
          await cubit.endSession();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LayoutPage()),
                  (route) => false,
            );
          }
        },
        onSkip: () async {
          await cubit.endSession();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LayoutPage()),
                  (route) => false,
            );
          }
        },
      );
    } else {
      final csState = cubit.state;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => cubit.isLawyer ? LayoutPage(): EndSessionScreen(
            consultationId: widget.consultationId,
            lawyerId: csState.lawyerId ?? '',
            clientId: csState.clientId ?? '',
          ),
        ),
            (route) => false,
      );
      await cubit.endSession();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Permission Denied Overlay
// ─────────────────────────────────────────────────────────────────────────────

class _PermissionDeniedOverlay extends StatelessWidget {
  const _PermissionDeniedOverlay({
    required this.permanentlyDenied,
    required this.missingPermissions,
  });

  final bool permanentlyDenied;
  final List<Permission> missingPermissions;

  String get _permissionNames {
    return missingPermissions.map((p) {
      switch (p) {
        case Permission.camera:
          return 'الكاميرا';
        case Permission.microphone:
          return 'الميكروفون';
        default:
          return p.toString();
      }
    }).join(' و ');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  permanentlyDenied
                      ? Icons.settings_suggest_outlined
                      : Icons.mic_off_outlined,
                  size: 72,
                  color: colorScheme.error.withOpacity(0.8),
                ),
                const SizedBox(height: 24),
                Text(
                  permanentlyDenied
                      ? 'الإذن مطلوب'
                      : 'يحتاج التطبيق إلى صلاحيات',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  permanentlyDenied
                      ? 'تم رفض الإذن بشكل دائم. يجب تمكين $_permissionNames من إعدادات التطبيق لبدء المكالمة.'
                      : 'لإجراء مكالمة الفيديو، يجب السماح بالوصول إلى $_permissionNames.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (permanentlyDenied)
                  ElevatedButton.icon(
                    onPressed: () => openAppSettings(),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('فتح الإعدادات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => context
                        .read<VideoCallCubit>()
                        .requestPermissionsAndInitialize(),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('السماح بالصلاحيات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'إلغاء',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// End-session confirmation dialog
// ─────────────────────────────────────────────────────────────────────────────

class _EndSessionDialog {
  static Future<bool?> show(
      BuildContext context, {
        required String consultationId,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Future<void> _handleEndingSession(BuildContext context) async {
      final cubit = context.read<VideoCallCubit>();

      if (cubit.isLawyer) {
        await showCallSummaryDialog(
          context,
          onSubmit: (summary) async {
            await cubit.submitCallSummary(summary);
            await cubit.endSession();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LayoutPage()),
                    (route) => false,
              );
            }
          },
          onSkip: () async {
            await cubit.endSession();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LayoutPage()),
                    (route) => false,
              );
            }
          },
        );
      } else {
        // Always read IDs from cubit state — they come from the server
        final cubit=context.read<VideoCallCubit>() ;
        final vsState = cubit.state;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) =>cubit.isLawyer ? LayoutPage() : EndSessionScreen(
              consultationId: consultationId,
              lawyerId: vsState.lawyerId ?? '',
              clientId: vsState.clientId ?? '',
            ),
          ),
              (route) => false,
        );
        await cubit.endSession();
      }
    }

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'تأكيد إنهاء',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'هل تريد إنهاء الجلسة الآن؟',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorScheme.outline),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding:
                            const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'لا',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleEndingSession(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding:
                            const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'نعم',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onError,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -28,
              child: CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.surface,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.info_outline,
                    color: colorScheme.primary,
                    size: 28,
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

// ─────────────────────────────────────────────────────────────────────────────
// Remote video
// ─────────────────────────────────────────────────────────────────────────────

class _RemoteVideoView extends StatelessWidget {
  const _RemoteVideoView({required this.state});
  final VideoCallState state;

  @override
  Widget build(BuildContext context) {
    final engine = context.read<VideoCallCubit>().engine;

    final showLiveVideo = engine != null &&
        state.remoteUid != null &&
        state.remoteUid != 0 &&
        (state.phase == VideoCallPhase.inProgress ||
            state.phase == VideoCallPhase.twoMinuteWarning ||
            state.phase == VideoCallPhase.timerExpired);

    if (showLiveVideo) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: state.remoteUid),
          connection: RtcConnection(
            channelId: state.rtcToken?.channelName ?? '',
          ),
        ),
      );
    }

    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundImage: state.lawyerPhotoUrl != null
                  ? NetworkImage(state.lawyerPhotoUrl!)
                  : null,
              child: state.lawyerPhotoUrl == null
                  ? const Icon(Icons.person, size: 56, color: Colors.white54)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              state.lawyerName ?? 'المحامي',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Local camera preview
// ─────────────────────────────────────────────────────────────────────────────

class _LocalPreviewView extends StatelessWidget {
  const _LocalPreviewView({required this.state});
  final VideoCallState state;

  @override
  Widget build(BuildContext context) {
    final engine = context.read<VideoCallCubit>().engine;
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 110,
        height: 130,
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.onSurface.withOpacity(0.4)),
        ),
        child: state.isCameraOff || engine == null
            ? Center(
          child: Icon(Icons.videocam_off,
              color: Colors.white54, size: 32),
        )
            : AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: engine,
            canvas: const VideoCanvas(uid: 0),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Waiting / initialising overlay
// ─────────────────────────────────────────────────────────────────────────────

class _WaitingOverlay extends StatelessWidget {
  const _WaitingOverlay({required this.state});
  final VideoCallState state;

  String get _message {
    switch (state.phase) {
      case VideoCallPhase.initializing:
      case VideoCallPhase.agoraReady:
      case VideoCallPhase.joiningCall:
        return 'جاري الاتصال…';
      case VideoCallPhase.waitingForLawyer:
        return 'في انتظار انضمام المحامي…';
      default:
        return 'جاري التحميل…';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.55),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(
              _message,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reconnecting overlay
// ─────────────────────────────────────────────────────────────────────────────

class _ReconnectingOverlay extends StatelessWidget {
  const _ReconnectingOverlay({required this.attempts, required this.max});
  final int attempts;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.65),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              'إعادة الاتصال… ($attempts/$max)',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error overlay
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: colorScheme.error, size: 56),
              const SizedBox(height: 16),
              Text(
                message ?? 'حدث خطأ في الاتصال',
                style: const TextStyle(color: Colors.white, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('العودة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Two-minute warning banner
// ─────────────────────────────────────────────────────────────────────────────

class _TwoMinuteWarningBanner extends StatelessWidget {
  const _TwoMinuteWarningBanner({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.error.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: colorScheme.onError, size: 20),
          const SizedBox(width: 8),
          Text(
            'تبقّت دقيقتان على انتهاء الجلسة',
            style: TextStyle(
                color: colorScheme.onError, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom control strip
// ─────────────────────────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.state,
    required this.consultationId,
  });
  final VideoCallState state;
  final String consultationId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cubit = context.read<VideoCallCubit>();

    // Timer turns red when ≤ 2 minutes remain
    final timerCritical = state.twoMinuteWarningActive ||
        (state.remainingSeconds != null && state.remainingSeconds! <= 120);

    return Container(
      padding: const EdgeInsets.only(bottom: 40, top: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            colorScheme.background.withOpacity(0.9),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lawyer name
          Text(
            state.lawyerName ?? 'المحامي',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onBackground,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Timer chip
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: timerCritical
                  ? colorScheme.error.withOpacity(0.15)
                  : colorScheme.surface.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: timerCritical
                    ? colorScheme.error.withOpacity(0.6)
                    : colorScheme.onSurface.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: timerCritical
                      ? colorScheme.error
                      : colorScheme.onBackground.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  state.formattedRemaining,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: timerCritical
                        ? colorScheme.error
                        : colorScheme.onBackground,
                    fontSize: 14,
                    fontWeight: timerCritical
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: state.isSessionActive
                        ? colorScheme.error
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 45),

          // Control buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: colorScheme.onSurface.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ControlButton(
                    onTap: () => _handleEndCall(context, cubit),
                    icon: Icons.call_end,
                    color: colorScheme.error,
                    iconColor: colorScheme.onError,
                    size: 58,
                  ),
                  const SizedBox(width: 18),
                  _ControlButton(
                    onTap: cubit.flipCamera,
                    icon: Icons.flip_camera_ios,
                    color: colorScheme.surface,
                    iconColor: colorScheme.onSurface,
                    size: 48,
                  ),
                  const SizedBox(width: 18),
                  _ControlButton(
                    onTap: cubit.toggleCamera,
                    icon: state.isCameraOff
                        ? Icons.videocam_off
                        : Icons.camera_alt,
                    color: colorScheme.surface,
                    iconColor: state.isCameraOff
                        ? colorScheme.error
                        : colorScheme.onSurface,
                    size: 48,
                  ),
                  const SizedBox(width: 18),
                  _ControlButton(
                    onTap: cubit.toggleSpeaker,
                    icon: state.isSpeakerOn
                        ? Icons.volume_up
                        : Icons.volume_off,
                    color: colorScheme.surface,
                    iconColor: colorScheme.onSurface,
                    size: 48,
                  ),
                  const SizedBox(width: 18),
                  _ControlButton(
                    onTap: cubit.toggleMute,
                    icon: state.isMuted ? Icons.mic_off : Icons.mic,
                    color: colorScheme.surface,
                    iconColor: state.isMuted
                        ? colorScheme.error
                        : colorScheme.onSurface,
                    size: 48,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEndCall(
      BuildContext context, VideoCallCubit cubit) async {
    final confirmed = await _EndSessionDialog.show(
      context,
      consultationId: consultationId,
    );
    if (confirmed != true) return;

    if (cubit.isLawyer) {
      await showCallSummaryDialog(
        context,
        onSubmit: (summary) async {
          await cubit.submitCallSummary(summary);
          await cubit.endSession();
        },
        onSkip: () async {
          await cubit.endSession();
        },
      );
    } else {
      await cubit.endSession();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable circular control button
// ─────────────────────────────────────────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.85),
          shape: BoxShape.circle,
          border: Border.all(
            color: iconColor.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.45,
        ),
      ),
    );
  }
}