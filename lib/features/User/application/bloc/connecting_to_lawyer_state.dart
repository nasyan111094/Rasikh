// ─────────────────────────────────────────────────────────────────────────────
// connecting_to_lawyer_state.dart
//
// Phase lifecycle:
//   waiting   → polling instant/written session every 3 s for lawyer to join
//   joined    → lawyerJoined == true, screen is about to navigate away
//   timedOut  → exceeded the max wait window with no lawyer join
//   ended     → consultation was cancelled/expired while waiting
//   error     → polling failed (network / server error)
// ─────────────────────────────────────────────────────────────────────────────

enum ConnectingPhase {
  waiting,
  joined,
  timedOut,
  ended,
  error,
}

class ConnectingToLawyerState {
  final ConnectingPhase phase;
  final String? errorMessage;

  /// How many polling attempts have been made so far (used to drive the
  /// timeout and, optionally, a "still searching..." message after a while).
  final int attempts;

  const ConnectingToLawyerState({
    this.phase = ConnectingPhase.waiting,
    this.errorMessage,
    this.attempts = 0,
  });

  ConnectingToLawyerState copyWith({
    ConnectingPhase? phase,
    String? errorMessage,
    bool clearError = false,
    int? attempts,
  }) {
    return ConnectingToLawyerState(
      phase: phase ?? this.phase,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      attempts: attempts ?? this.attempts,
    );
  }
}
