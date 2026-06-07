import 'package:permission_handler/permission_handler.dart';

import '../repo/video_call_repo.dart';

enum VideoCallPhase {
  /// Permissions not yet granted (first-time denial)
  permissionDenied,

  /// Permissions permanently denied ("Don't ask again")
  permissionPermanentlyDenied,

  /// Step 1–3: accept-instant → instant-session → rtc-token
  initializing,

  /// Step 4: Agora.initialize() completed, about to join channel
  agoraReady,

  /// Step 5: join-call POST sent to server
  joiningCall,

  /// Step 6: Agora.joinChannel() in flight / waiting for lawyer to appear
  waitingForLawyer,

  /// Step 7: in_progress from polling + remote user joined Agora
  inProgress,

  /// Server sent 2-minute warning
  twoMinuteWarning,

  /// Local network drop – attempting to rejoin
  reconnecting,

  /// Local countdown hit 00:00 — show summary dialog before fully ending
  timerExpired,

  /// Session over (navigate away)
  ended,

  /// Unrecoverable error
  error,
}

class VideoCallState {
  // ── Agora credentials ──────────────────────────────────────────────────────
  final RtcTokenModel? rtcToken;

  // ── Phase & timing ─────────────────────────────────────────────────────────
  final VideoCallPhase phase;
  final int? remainingSeconds;
  final bool twoMinuteWarningActive;

  // ── Remote peer ────────────────────────────────────────────────────────────
  final int? remoteUid;
  final bool isRemoteVideoMuted;
  final bool isRemoteAudioMuted;

  // ── Lawyer info (display) ──────────────────────────────────────────────────
  final String? lawyerName;
  final String? lawyerPhotoUrl;
  final String? lawyerId;
  final String? clientId;

  // ── Local media ────────────────────────────────────────────────────────────
  final bool isMuted;
  final bool isCameraOff;
  final bool isSpeakerOn;
  final bool isFrontCamera;

  // ── Network quality (Agora: 0 = unknown, 1 = excellent … 6 = down) ─────────
  final int localNetworkQuality;
  final int remoteNetworkQuality;

  // ── Error / reconnection ───────────────────────────────────────────────────
  final String? errorMessage;
  final int reconnectAttempts;

  // ── Permissions ────────────────────────────────────────────────────────────
  final List<Permission> missingPermissions;

  const VideoCallState({
    this.rtcToken,
    this.phase = VideoCallPhase.initializing,
    this.remainingSeconds,
    this.twoMinuteWarningActive = false,
    this.remoteUid,
    this.isRemoteVideoMuted = false,
    this.isRemoteAudioMuted = false,
    this.lawyerName,
    this.lawyerPhotoUrl,
    this.lawyerId,
    this.clientId,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isSpeakerOn = true,
    this.isFrontCamera = true,
    this.localNetworkQuality = 0,
    this.remoteNetworkQuality = 0,
    this.errorMessage,
    this.reconnectAttempts = 0,
    this.missingPermissions = const [],
  });

  VideoCallState copyWith({
    RtcTokenModel? rtcToken,
    VideoCallPhase? phase,
    int? remainingSeconds,
    bool? twoMinuteWarningActive,
    int? remoteUid,
    bool clearRemoteUid = false,
    bool? isRemoteVideoMuted,
    bool? isRemoteAudioMuted,
    String? lawyerName,
    String? lawyerPhotoUrl,
    String? lawyerId,
    String? clientId,
    bool? isMuted,
    bool? isCameraOff,
    bool? isSpeakerOn,
    bool? isFrontCamera,
    int? localNetworkQuality,
    int? remoteNetworkQuality,
    String? errorMessage,
    bool clearError = false,
    int? reconnectAttempts,
    List<Permission>? missingPermissions,
  }) {
    return VideoCallState(
      rtcToken: rtcToken ?? this.rtcToken,
      phase: phase ?? this.phase,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      twoMinuteWarningActive:
      twoMinuteWarningActive ?? this.twoMinuteWarningActive,
      remoteUid: clearRemoteUid ? null : (remoteUid ?? this.remoteUid),
      isRemoteVideoMuted: isRemoteVideoMuted ?? this.isRemoteVideoMuted,
      isRemoteAudioMuted: isRemoteAudioMuted ?? this.isRemoteAudioMuted,
      lawyerName: lawyerName ?? this.lawyerName,
      lawyerPhotoUrl: lawyerPhotoUrl ?? this.lawyerPhotoUrl,
      lawyerId: lawyerId ?? this.lawyerId,
      clientId: clientId ?? this.clientId,
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      localNetworkQuality: localNetworkQuality ?? this.localNetworkQuality,
      remoteNetworkQuality: remoteNetworkQuality ?? this.remoteNetworkQuality,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      reconnectAttempts: reconnectAttempts ?? this.reconnectAttempts,
      missingPermissions: missingPermissions ?? this.missingPermissions,
    );
  }

  // ── Convenience getters ────────────────────────────────────────────────────

  bool get isSessionActive =>
      phase == VideoCallPhase.inProgress ||
          phase == VideoCallPhase.twoMinuteWarning;

  bool get isPeerConnected => remoteUid != null;

  String get formattedRemaining {
    final secs = remainingSeconds;
    if (secs == null || secs <= 0) return '00:00';
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Friendly quality label for UI display
  String networkQualityLabel(int quality) {
    switch (quality) {
      case 1:
      case 2:
        return 'ممتاز';
      case 3:
        return 'جيد';
      case 4:
        return 'ضعيف';
      case 5:
      case 6:
        return 'سيء';
      default:
        return '';
    }
  }
}