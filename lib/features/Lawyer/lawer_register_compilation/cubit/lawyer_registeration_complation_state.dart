// ─────────────────────────────────────────────────────────────────────────────
// lawyer_completion/bloc/lawyer_completion_state.dart
//
// States emitted by LawyerCompletionCubit (profile-completion flow only).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

import '../models/lawyer_registeration_complation_model.dart';

abstract class LawyerCompletionState extends Equatable {
  const LawyerCompletionState();

  @override
  List<Object?> get props => [];
}

// ── Idle ──────────────────────────────────────────────────────────────────────
class LawyerCompletionInitial extends LawyerCompletionState {
  const LawyerCompletionInitial();
}

// ── City loading ──────────────────────────────────────────────────────────────
class LawyerCityLoading extends LawyerCompletionState {
  const LawyerCityLoading();
}

class LawyerCityLoaded extends LawyerCompletionState {
  final List<CityEnumModel> cities;
  const LawyerCityLoaded(this.cities);

  @override
  List<Object?> get props => [cities];
}

class LawyerCityError extends LawyerCompletionState {
  final String message;
  const LawyerCityError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Specialization loading ────────────────────────────────────────────────────
class LawyerSpecializationLoading extends LawyerCompletionState {
  const LawyerSpecializationLoading();
}

/// [selectedSubIdsByMain] maps each main-specialization id → set of selected
/// sub-specialization ids.  A main is considered "selected" (confirmed) only
/// when it has at least one sub selected.  The card for a main is "expanded"
/// (showing sub-chips) when [expandedMainId] equals that main's id.
class LawyerSpecializationLoaded extends LawyerCompletionState {
  final List<SpecializationModel>    specializations;

  /// The card currently expanded to show its sub-specializations.
  /// null means no card is open.
  final String?                      expandedMainId;

  /// mainId → Set of chosen sub-ids for that main.
  /// A main only appears in this map once the user selects ≥1 sub from it.
  final Map<String, Set<String>>     selectedSubIdsByMain;

  const LawyerSpecializationLoaded({
    required this.specializations,
    this.expandedMainId,
    required this.selectedSubIdsByMain,
  });

  // ── Derived helpers ──────────────────────────────────────────────────────

  /// Is this main card confirmed (has ≥1 sub selected)?
  bool isMainSelected(String mainId) =>
      (selectedSubIdsByMain[mainId]?.isNotEmpty) ?? false;

  /// Is a particular sub selected under its main?
  bool isSubSelected(String mainId, String subId) =>
      selectedSubIdsByMain[mainId]?.contains(subId) ?? false;

  /// All confirmed main ids (those with ≥1 sub).
  List<String> get selectedMainIds => selectedSubIdsByMain.entries
      .where((e) => e.value.isNotEmpty)
      .map((e) => e.key)
      .toList();

  /// All selected sub ids across every main (flat list for the API).
  List<String> get allSelectedSubIds => selectedSubIdsByMain.values
      .expand((s) => s)
      .toList();

  /// The form can be submitted when at least one main has ≥1 sub.
  bool get canProceed => selectedMainIds.isNotEmpty;

  // ── copyWith ─────────────────────────────────────────────────────────────
  LawyerSpecializationLoaded copyWith({
    List<SpecializationModel>?  specializations,
    String?                     expandedMainId,
    bool                        clearExpanded = false,
    Map<String, Set<String>>?   selectedSubIdsByMain,
  }) {
    return LawyerSpecializationLoaded(
      specializations:     specializations     ?? this.specializations,
      expandedMainId:      clearExpanded ? null : (expandedMainId ?? this.expandedMainId),
      selectedSubIdsByMain: selectedSubIdsByMain ?? this.selectedSubIdsByMain,
    );
  }

  @override
  List<Object?> get props =>
      [specializations, expandedMainId, selectedSubIdsByMain];
}

class LawyerSpecializationError extends LawyerCompletionState {
  final String message;
  const LawyerSpecializationError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Profile submission ────────────────────────────────────────────────────────
class LawyerProfileSubmitting extends LawyerCompletionState {
  const LawyerProfileSubmitting();
}

class LawyerProfileCompleted extends LawyerCompletionState {
  final LawyerProfileCompletionModel model;
  const LawyerProfileCompleted(this.model);

  @override
  List<Object?> get props => [model];
}

// ── Generic error ─────────────────────────────────────────────────────────────
class LawyerCompletionError extends LawyerCompletionState {
  final String message;
  const LawyerCompletionError(this.message);

  @override
  List<Object?> get props => [message];
}