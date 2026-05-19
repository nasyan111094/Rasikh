// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/specializations/logic/states/specializations_state.dart
// ─────────────────────────────────────────────────────────────────────────────


import '../../models/specialization_catalog_model.dart';

sealed class SpecializationsState {}

// ── Initial ───────────────────────────────────────────────────────────────────

final class SpecializationsInitial extends SpecializationsState {}

// ── Fetch catalog ─────────────────────────────────────────────────────────────

final class SpecializationsLoading extends SpecializationsState {}

final class SpecializationsLoaded extends SpecializationsState {
  final List<SpecializationCatalogModel> specializations;
  SpecializationsLoaded(this.specializations);
}

final class SpecializationsError extends SpecializationsState {
  final String message;
  SpecializationsError(this.message);
}

// ── Save specializations (update profile) ────────────────────────────────────

final class SaveSpecializationsLoading extends SpecializationsState {}

final class SaveSpecializationsSuccess extends SpecializationsState {}

final class SaveSpecializationsError extends SpecializationsState {
  final String message;
  SaveSpecializationsError(this.message);
}