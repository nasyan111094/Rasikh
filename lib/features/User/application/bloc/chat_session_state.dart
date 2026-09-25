// ─────────────────────────────────────────────────────────────────────────────
// chat_session_state.dart
//
// Mirrors VideoCallState / VideoCallPhase exactly for written (text) chat.
//
// Phase lifecycle:
//   initializing     → fetchSession + fetchToken + fetchConversation + joinChat
//   waitingForClient → poll confirms both parties joined (isInProgress)
//   inProgress       ↔ twoMinuteWarning  (server flag)
//   timerExpired     → summary dialog (lawyer) / EndSessionScreen (client)
//   ended            → navigate away
//   error            → error overlay
// ─────────────────────────────────────────────────────────────────────────────

enum ChatSessionPhase {
  /// Steps 1-4: fetchSession → fetchToken → fetchConversation → joinChat
  initializing,

  /// POST join-chat done; waiting for the other party to also join
  waitingForClient,

  /// Both parties have joined; chat is live and timer is running
  inProgress,

  /// Server sent 2-minute warning
  twoMinuteWarning,

  /// Local countdown hit 00:00 — show summary dialog before fully ending
  timerExpired,

  /// Session over (navigate away)
  ended,

  /// Unrecoverable error
  error,
}

/// Credentials returned by the two Agora-chat endpoints.
/// Passed to the Agora Chat SDK by the UI layer.
class AgoraChatCredentials {
  /// Short-lived Agora Chat user token.
  final String token;

  /// My own Agora Chat user ID (used for login).
  final String myUserId;

  /// The peer's Agora Chat user ID (to open a 1-to-1 conversation).
  final String peerUserId;

  /// Stable conversation key used by the SDK.
  final String conversationKey;

  const AgoraChatCredentials({
    required this.token,
    required this.myUserId,
    required this.peerUserId,
    required this.conversationKey,
  });
}

class ChatSessionState {
  // ── Agora Chat credentials ─────────────────────────────────────────────────
  final AgoraChatCredentials? credentials;

  // ── Phase & timing ─────────────────────────────────────────────────────────
  final ChatSessionPhase phase;
  final int? remainingSeconds;
  final bool twoMinuteWarningActive;

  // ── Peer info (display only) ───────────────────────────────────────────────
  final String? peerName;
  final String? peerPhotoUrl;

  // ── IDs (server-authoritative) ─────────────────────────────────────────────
  final String? lawyerId;
  final String? clientId;

  // ── Error ──────────────────────────────────────────────────────────────────
  final String? errorMessage;

  const ChatSessionState({
    this.credentials,
    this.phase = ChatSessionPhase.initializing,
    this.remainingSeconds,
    this.twoMinuteWarningActive = false,
    this.peerName,
    this.peerPhotoUrl,
    this.lawyerId,
    this.clientId,
    this.errorMessage,
  });

  ChatSessionState copyWith({
    AgoraChatCredentials? credentials,
    ChatSessionPhase? phase,
    int? remainingSeconds,
    bool? twoMinuteWarningActive,
    String? peerName,
    String? peerPhotoUrl,
    String? lawyerId,
    String? clientId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatSessionState(
      credentials: credentials ?? this.credentials,
      phase: phase ?? this.phase,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      twoMinuteWarningActive:
      twoMinuteWarningActive ?? this.twoMinuteWarningActive,
      peerName: peerName ?? this.peerName,
      peerPhotoUrl: peerPhotoUrl ?? this.peerPhotoUrl,
      lawyerId: lawyerId ?? this.lawyerId,
      clientId: clientId ?? this.clientId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  // ── Convenience getters ────────────────────────────────────────────────────

  bool get isSessionActive =>
      phase == ChatSessionPhase.inProgress ||
          phase == ChatSessionPhase.twoMinuteWarning;

  String get formattedRemaining {
    final secs = remainingSeconds;
    if (secs == null || secs <= 0) return '00:00';
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}