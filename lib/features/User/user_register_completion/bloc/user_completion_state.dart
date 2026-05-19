// ─────────────────────────────────────────────────────────────────────────────
// user_completion/bloc/user_completion_state.dart
//
// States for the user (non-lawyer) profile-completion flow.
// Add your user-specific states here as the product grows.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

abstract class UserCompletionState extends Equatable {
  const UserCompletionState();

  @override
  List<Object?> get props => [];
}

class UserCompletionInitial extends UserCompletionState {
  const UserCompletionInitial();
}

class UserProfileSubmitting extends UserCompletionState {
  const UserProfileSubmitting();
}

class UserProfileCompleted extends UserCompletionState {
  const UserProfileCompleted();
}

class UserCompletionError extends UserCompletionState {
  final String message;
  const UserCompletionError(this.message);

  @override
  List<Object?> get props => [message];
}