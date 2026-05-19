// ─────────────────────────────────────────────────────────────────────────────
// lawyer_completion/bloc/lawyer_completion_cubit.dart
//
// Singleton cubit that:
//  • Holds all TextEditingControllers for the multi-step completion flow
//  • Accumulates form data in LawyerRegistrationFormData
//  • Fetches cities and specializations
//  • Submits the final profile via LawyerCompletionRepo
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Repo/lawyer_register_complation_repo.dart';
import '../models/lawyer_registeration_complation_model.dart';
import 'lawyer_registeration_complation_state.dart';

class LawyerCompletionCubit extends Cubit<LawyerCompletionState> {
  final LawyerCompletionRepo _repo;

  LawyerCompletionCubit(this._repo) : super(const LawyerCompletionInitial());

  // ── Controllers shared across all completion screens ─────────────────────
  final TextEditingController fullNameController        = TextEditingController();
  final TextEditingController emailController           = TextEditingController();
  final TextEditingController nationalIdController      = TextEditingController();
  final TextEditingController licenseController         = TextEditingController();
  final TextEditingController commercialRegController   = TextEditingController();
  final TextEditingController qualificationsController  = TextEditingController();
  final TextEditingController experienceYearsController = TextEditingController();

  // ── Accumulated form data ─────────────────────────────────────────────────
  LawyerRegistrationFormData formData = LawyerRegistrationFormData();

  // ── In-memory specialization list for filtering ───────────────────────────
  List<SpecializationModel> _allSpecializations = [];

  // ══════════════════════════════════════════════════════════════════════════
  // Cities
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> fetchCities() async {
    emit(const LawyerCityLoading());
    final result = await _repo.getCities();
    result.fold(
          (err)    => emit(LawyerCityError(err)),
          (cities) => emit(LawyerCityLoaded(cities)),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Specializations
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> fetchSpecializations() async {
    emit(const LawyerSpecializationLoading());
    final result = await _repo.getSpecializations();
    result.fold(
          (err)  => emit(LawyerSpecializationError(err)),
          (list) {
        _allSpecializations = list;
        emit(LawyerSpecializationLoaded(
          specializations:     list,
          selectedSubIdsByMain: const {},
        ));
      },
    );
  }

  void searchSpecializations(String query) {
    final current = state;
    if (current is! LawyerSpecializationLoaded) return;

    final filtered = query.trim().isEmpty
        ? _allSpecializations
        : _allSpecializations.where((spec) {
      final matchesMain = spec.name.contains(query);
      final matchesSub  = spec.subSpecializations
          .any((s) => s.name.contains(query));
      return matchesMain || matchesSub;
    }).toList();

    emit(current.copyWith(specializations: filtered));
  }

  /// Tap on a main-specialization card header:
  ///  - If already expanded → collapse (close) it.
  ///  - If not expanded → expand it so the user can choose subs.
  ///  - Expanding does NOT auto-select the main; it only becomes "selected"
  ///    once the user picks at least one sub from inside it.
  void toggleExpanded(String mainId) {
    final current = state;
    if (current is! LawyerSpecializationLoaded) return;

    final isSame = current.expandedMainId == mainId;
    emit(current.copyWith(
      expandedMainId: isSame ? null : mainId,
      clearExpanded:  isSame,
    ));
  }

  /// Toggle a sub-specialization chip under [mainId].
  ///  - Adds/removes the sub from the map.
  ///  - If the last sub under a main is deselected, removes that main's entry
  ///    from the map entirely (so it is no longer considered selected).
  void toggleSub(String mainId, String subId) {
    final current = state;
    if (current is! LawyerSpecializationLoaded) return;

    // Deep-copy the map so we don't mutate state directly.
    final updated = Map<String, Set<String>>.fromEntries(
      current.selectedSubIdsByMain.entries
          .map((e) => MapEntry(e.key, Set<String>.from(e.value))),
    );

    final subs = updated.putIfAbsent(mainId, () => <String>{});
    if (subs.contains(subId)) {
      subs.remove(subId);
      if (subs.isEmpty) updated.remove(mainId);
    } else {
      subs.add(subId);
    }

    emit(current.copyWith(selectedSubIdsByMain: updated));
  }

  // ── Convenience getters used by the submit button / saveSpecializations ──

  List<String> get selectedMainIds {
    final current = state;
    if (current is LawyerSpecializationLoaded) {
      return current.selectedMainIds;
    }
    return [];
  }

  List<String> get selectedSubIds {
    final current = state;
    if (current is LawyerSpecializationLoaded) {
      return current.allSelectedSubIds;
    }
    return [];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Step savers (called from each page before navigating forward)
  // ══════════════════════════════════════════════════════════════════════════

  void savePersonalInfo({required String cityKey}) {
    formData = formData.copyWith(
      fullName: fullNameController.text.trim(),
      email:    emailController.text.trim(),
      cityKey:  cityKey,
    );
  }

  void saveLicenseInfo({
    File? licenseImage,
    File? nationalIdDocument,
    File? commercialRegistrationDocument,
    required bool isCompany,
  }) {
    formData = formData.copyWith(
      nationalId:                     nationalIdController.text.trim(),
      licenseNumber:                  licenseController.text.trim(),
      commercialRegistrationNumber:   commercialRegController.text.trim(),
      isCompany:                      isCompany,
      licenseImage:                   licenseImage,
      nationalIdDocument:             nationalIdDocument,
      commercialRegistrationDocument: commercialRegistrationDocument,
      acceptedTerms:                  true,
    );
  }

  void saveQualifications() {
    final years =
        int.tryParse(experienceYearsController.text.trim()) ?? 0;
    formData = formData.copyWith(
      qualifications:  qualificationsController.text.trim(),
      experienceYears: years,
    );
  }

  void saveSpecializations({
    required List<String> mainIds,
    required List<String> subIds,
  }) {
    formData = formData.copyWith(
      mainSpecializationIds: mainIds,
      subSpecializationIds:  subIds,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Final submission
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> completeProfile() async {
    emit(const LawyerProfileSubmitting());
    final result = await _repo.completeProfile(formData: formData);
    result.fold(
          (err)   => emit(LawyerCompletionError(err)),
          (model) => emit(LawyerProfileCompleted(model)),
    );
  }

  @override
  Future<void> close() {
    // ⚠️  Singleton – DO NOT dispose controllers here.
    return super.close();
  }
}