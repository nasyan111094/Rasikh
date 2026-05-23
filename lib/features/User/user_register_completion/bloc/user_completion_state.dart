// ─────────────────────────────────────────────────────────────────────────────
// user_completion/bloc/user_completion_state.dart
//
// Design notes
// ────────────
// • City states are kept separate from profile-submission states so that the
//   dropdown can always rebuild independently.
// • A single `UserCompletionError` covers both city errors and submission
//   errors — the listener in the page decides how to surface each one.
// • LawyerCityLoaded carries the loaded list so BlocBuilder never loses
//   the cities while a submission is in flight (see cubit for how this works).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

import '../../../../Shared/models/city_model.dart';
import '../../../../core/models/user_model.dart';
import '../model/user_completion_model.dart';

abstract class UserCompletionState extends Equatable {
  const UserCompletionState();

  @override
  List<Object?> get props => [];
}

// ── Initial ───────────────────────────────────────────────────────────────────

class UserCompletionInitial extends UserCompletionState {
  const UserCompletionInitial();
}

// ── City loading ──────────────────────────────────────────────────────────────

class CityLoading extends UserCompletionState {
  const CityLoading();
}

class CityLoaded extends UserCompletionState {
  final List<CityEnumModel> cities;
  const CityLoaded(this.cities);

  @override
  List<Object?> get props => [cities];
}

class CityError extends UserCompletionState {
  final String message;
  const CityError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Profile submission ────────────────────────────────────────────────────────

/// Emitted while the PUT request is in flight.
/// The cubit retains the loaded cities alongside this state so the dropdown
/// never disappears during submission.
class ProfileSubmitting extends UserCompletionState {
  /// Cities are kept here so the dropdown can still render while the
  /// submission request is in flight.
  final List<CityEnumModel> cities;
  const ProfileSubmitting({required this.cities});

  @override
  List<Object?> get props => [cities];
}

class ProfileCompleted extends UserCompletionState {
  final UserProfileModel profile;
  const ProfileCompleted(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends UserCompletionState {
  final String message;
  /// Cities are kept so the UI stays intact after a failed submission.
  final List<CityEnumModel> cities;
  const ProfileError({required this.message, required this.cities});

  @override
  List<Object?> get props => [message, cities];
}