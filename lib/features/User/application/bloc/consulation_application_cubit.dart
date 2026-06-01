// ─────────────────────────────────────────────────────────────────────────────
// consulation_application_cubit.dart
// Single cubit driving the entire Create-Consultation flow (steps 1–6).
//
// Changes from original:
//  • fetchSpecializations now calls /specializations/active
//  • Added loadConsultationTypes() → GET /enums/consultation-types
//  • Added loadCities()             → GET /enums/cities
//  • clearVoiceNote uses Object sentinel to properly null voiceNote in copyWith
//  • "استشر الآن" from LawyerCard/LawyerDetailsScreen: selectLawyer then
//    navigate appropriately (see selectLawyerAndProceed)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/get_it_service/get_it_service.dart';
import '../models/consultation_model.dart';
import '../repo/consulation_application_repo.dart';
import 'consulation_application_state.dart';

// Sentinel object used to explicitly null-out nullable fields in copyWith.
final _$null = Object();

class ConsultationCubit extends Cubit<ConsultationState> {
  ConsultationCubit() : super(const ConsultationState());

  final ConsultationRepo _repo = getIt.get<ConsultationRepo>();

  // ── Step-1: Specializations ───────────────────────────────────────────────
  // Calls GET /api/v1/specializations/active

  Future<void> loadSpecializations({String? search}) async {
    emit(state.copyWith(
      specializationsStatus: ConsultationStatus.loading,
      specializationsError: null,
    ));

    final result = await _repo.fetchSpecializations(search: search);

    result.fold(
          (error) => emit(state.copyWith(
        specializationsStatus: ConsultationStatus.failure,
        specializationsError: error,
      )),
          (data) => emit(state.copyWith(
        specializationsStatus: ConsultationStatus.success,
        specializations: data,
      )),
    );
  }

  void selectSpecialization(SpecializationModel specialization) {
    emit(state.copyWith(
      selectedSpecialization: specialization,
      selectedSubSpecializations: [],
    ));
  }

  void toggleSubSpecialization(SubSpecializationModel sub) {
    final current =
    List<SubSpecializationModel>.from(state.selectedSubSpecializations);
    if (current.any((s) => s.id == sub.id)) {
      current.removeWhere((s) => s.id == sub.id);
    } else {
      current.add(sub);
    }
    emit(state.copyWith(selectedSubSpecializations: current));
  }

  // ── Enums: Consultation types ────────────────────────────────────────────
  // Calls GET /api/v1/enums/consultation-types

  Future<void> loadConsultationTypes() async {
    emit(state.copyWith(
      consultationTypesStatus: ConsultationStatus.loading,
      consultationTypesError: null,
    ));

    final result = await _repo.fetchEnum('consultation-types');

    result.fold(
          (error) => emit(state.copyWith(
        consultationTypesStatus: ConsultationStatus.failure,
        consultationTypesError: error,
      )),
          (data) => emit(state.copyWith(
        consultationTypesStatus: ConsultationStatus.success,
        consultationTypes: data,
      )),
    );
  }

  // ── Enums: Cities ────────────────────────────────────────────────────────
  // Calls GET /api/v1/enums/cities

  Future<void> loadCities() async {
    // Skip if already loaded successfully
    if (state.citiesStatus == ConsultationStatus.success &&
        state.cities.isNotEmpty) return;

    emit(state.copyWith(
      citiesStatus: ConsultationStatus.loading,
      citiesError: null,
    ));

    final result = await _repo.fetchEnum('cities');

    result.fold(
          (error) => emit(state.copyWith(
        citiesStatus: ConsultationStatus.failure,
        citiesError: error,
      )),
          (data) => emit(state.copyWith(
        citiesStatus: ConsultationStatus.success,
        cities: data,
      )),
    );
  }

  // ── Step-2: Consultation type ─────────────────────────────────────────────
  ConsultationType ? selectedConsultationType  ;
  void selectConsultationType(ConsultationType type) {
    selectedConsultationType = type ;
    emit(state.copyWith(selectedConsultationType: type));
  }

  // ── Step-3: Pricing + Details ─────────────────────────────────────────────
  // Calls GET /api/v1/client/pricing filtered by the selected consultation type

  Future<void> loadPricingPlans() async {
    emit(state.copyWith(
      pricingStatus: ConsultationStatus.loading,
      pricingError: null,
    ));

    final result = await _repo.fetchPricing(
      consultationType: state.selectedConsultationType.value,
    );

    result.fold(
          (error) => emit(state.copyWith(
        pricingStatus: ConsultationStatus.failure,
        pricingError: error,
      )),
          (data) => emit(state.copyWith(
        pricingStatus: ConsultationStatus.success,
        pricingPlans: data,
        // Auto-select first plan when none is selected
        selectedPricing:
        state.selectedPricing ?? (data.isNotEmpty ? data.first : null),
      )),
    );
  }

  void selectPricing(PricingModel pricing) {
    emit(state.copyWith(selectedPricing: pricing));
  }

  void updateTitle(String value) {
    emit(state.copyWith(consultationTitle: value));
  }

  void updateDetails(String value) {
    emit(state.copyWith(consultationDetails: value));
  }

  void setHideClientFromLawyer(bool value) {
    emit(state.copyWith(hideClientFromLawyer: value));
  }

  // ── Voice note ────────────────────────────────────────────────────────────

  void setVoiceNote(File file, int durationSeconds) {
    emit(state.copyWith(
      voiceNote: file,
      voiceNoteDurationSeconds: durationSeconds,
    ));
  }

  /// Clears the voice note.
  /// Uses a special copyWith overload to set voiceNote = null correctly.
  void clearVoiceNote() {
    emit(_stateWithNullVoiceNote(state));
  }

  /// Returns a new state with voiceNote and voiceNoteDurationSeconds nulled out.
  ConsultationState _stateWithNullVoiceNote(ConsultationState s) {
    return ConsultationState(
      specializationsStatus: s.specializationsStatus,
      specializations: s.specializations,
      specializationsError: s.specializationsError,
      selectedSpecialization: s.selectedSpecialization,
      selectedSubSpecializations: s.selectedSubSpecializations,
      consultationTypesStatus: s.consultationTypesStatus,
      consultationTypes: s.consultationTypes,
      consultationTypesError: s.consultationTypesError,
      citiesStatus: s.citiesStatus,
      cities: s.cities,
      citiesError: s.citiesError,
      selectedConsultationType: s.selectedConsultationType,
      pricingStatus: s.pricingStatus,
      pricingPlans: s.pricingPlans,
      selectedPricing: s.selectedPricing,
      pricingError: s.pricingError,
      consultationTitle: s.consultationTitle,
      consultationDetails: s.consultationDetails,
      hideClientFromLawyer: s.hideClientFromLawyer,
      voiceNote: null, // explicitly null
      voiceNoteDurationSeconds: null, // explicitly null
      attachments: s.attachments,
      lawyersStatus: s.lawyersStatus,
      lawyers: s.lawyers,
      lawyersError: s.lawyersError,
      recommendedLawyerStatus: s.recommendedLawyerStatus,
      recommendedLawyer: s.recommendedLawyer,
      recommendedLawyerError: s.recommendedLawyerError,
      lawyerDetailStatus: s.lawyerDetailStatus,
      selectedLawyerDetail: s.selectedLawyerDetail,
      lawyerDetailError: s.lawyerDetailError,
      selectedLawyer: s.selectedLawyer,
      selectedDayIndex: s.selectedDayIndex,
      selectedTimeIndex: s.selectedTimeIndex,
      startTime: s.startTime,
      endTime: s.endTime,
      createStatus: s.createStatus,
      createdConsultation: s.createdConsultation,
      createError: s.createError,
    );
  }

  // ── Attachments ───────────────────────────────────────────────────────────

  void addAttachment(File file) {
    if (state.attachments.length >= 5) return;
    final updated = List<File>.from(state.attachments)..add(file);
    emit(state.copyWith(attachments: updated));
  }

  void removeAttachment(int index) {
    final updated = List<File>.from(state.attachments)..removeAt(index);
    emit(state.copyWith(attachments: updated));
  }

  // ── Step-4: Lawyer selection ──────────────────────────────────────────────

  Future<void> loadLawyers({
    String? search,
    String? city,
    String? sortBy,
    String? sortOrder,
  }) async {
    emit(state.copyWith(
      lawyersStatus: ConsultationStatus.loading,
      lawyersError: null,
    ));

    final result = await _repo.fetchLawyers(
      specializationId: state.selectedSpecialization?.id,
      subSpecializationIds: state.selectedSubSpecializations.isNotEmpty
          ? state.selectedSubSpecializations.map((s) => s.id).join(',')
          : null,
      search: search,
      city: city,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    result.fold(
          (error) => emit(state.copyWith(
        lawyersStatus: ConsultationStatus.failure,
        lawyersError: error,
      )),
          (data) => emit(state.copyWith(
        lawyersStatus: ConsultationStatus.success,
        lawyers: data,
      )),
    );
  }

  Future<void> loadRecommendedLawyer() async {
    final specId = state.selectedSpecialization?.id;
    if (specId == null) return;

    emit(state.copyWith(
      recommendedLawyerStatus: ConsultationStatus.loading,
      recommendedLawyerError: null,
    ));

    final result = await _repo.fetchRecommendedLawyer(
      specializationId: specId,
      subSpecializationIds:
      state.selectedSubSpecializations.map((s) => s.id).toList(),
    );

    result.fold(
          (error) => emit(state.copyWith(
        recommendedLawyerStatus: ConsultationStatus.failure,
        recommendedLawyerError: error,
      )),
          (data) => emit(state.copyWith(
        recommendedLawyerStatus: ConsultationStatus.success,
        recommendedLawyer: data,
      )),
    );
  }

  Future<void> loadLawyerDetail(String lawyerId) async {
    emit(state.copyWith(
      lawyerDetailStatus: ConsultationStatus.loading,
      lawyerDetailError: null,
    ));

    final result = await _repo.fetchLawyerDetails(lawyerId);

    result.fold(
          (error) => emit(state.copyWith(
        lawyerDetailStatus: ConsultationStatus.failure,
        lawyerDetailError: error,
      )),
          (data) => emit(state.copyWith(
        lawyerDetailStatus: ConsultationStatus.success,
        selectedLawyerDetail: data,
      )),
    );
  }

  void selectLawyer(LawyerModel lawyer) {
    emit(state.copyWith(selectedLawyer: lawyer));
  }

  /// Called when "استشر الآن" is pressed from LawyerCard OR LawyerDetailsScreen.
  /// Selects the lawyer and also loads their full detail if not yet loaded.
  Future<void> selectLawyerAndLoadDetail(LawyerModel lawyer) async {
    emit(state.copyWith(selectedLawyer: lawyer));
    // Only re-fetch if the detail is for a different lawyer or not yet loaded.
    if (state.selectedLawyerDetail?.id != lawyer.id) {
      await loadLawyerDetail(lawyer.id);
    }
  }

  // ── Step-5: Appointment scheduling ───────────────────────────────────────

  void selectDay(int index) {
    emit(state.copyWith(selectedDayIndex: index));
    _resolveScheduledTimes();
  }

  void selectTime(int index) {
    emit(state.copyWith(selectedTimeIndex: index));
    _resolveScheduledTimes();
  }

  void _resolveScheduledTimes() {
    final selectedDay =
    DateTime.now().add(Duration(days: state.selectedDayIndex));
    final startHour = 9 + (state.selectedTimeIndex ~/ 2);
    final startMinute = (state.selectedTimeIndex % 2) * 30;

    final start = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      startHour,
      startMinute,
    );

    final durationMin = state.selectedPricing?.duration ?? 60;
    final end = start.add(Duration(minutes: durationMin));

    emit(state.copyWith(startTime: start, endTime: end));
  }

  // ── Step-6: Create consultation ───────────────────────────────────────────

  Future<void> createConsultation() async {
    // Use selectedLawyer; fall back to recommendedLawyer if user chose
    // "recommend me the best" path.
    final lawyer =
        state.selectedLawyer ?? _lawyerFromRecommended(state.recommendedLawyer);

    if (lawyer == null ||
        state.selectedSpecialization == null ||
        state.selectedPricing == null) return;

    emit(state.copyWith(
      createStatus: ConsultationStatus.loading,
      createError: null,
    ));

    final params = CreateConsultationParams(
      pricingId: state.selectedPricing!.id,
      lawyerId: lawyer.id,
      specializationId: state.selectedSpecialization!.id,
      subSpecializationIds:
      state.selectedSubSpecializations.map((s) => s.id).toList(),
      title: state.consultationTitle.trim(),
      details: state.consultationDetails.trim(),
      type: state.selectedConsultationType,
      hideClientFromLawyer: state.hideClientFromLawyer,
      startTime: state.isScheduled ? state.startTime : null,
      endTime: state.isScheduled ? state.endTime : null,
      attachments: state.attachments,
      voiceNote: state.voiceNote,
      voiceNoteDurationSeconds: state.voiceNoteDurationSeconds,
    );

    final result = await _repo.createConsultation(params);

    result.fold(
          (error) => emit(state.copyWith(
        createStatus: ConsultationStatus.failure,
        createError: error,
      )),
          (data) => emit(state.copyWith(
        createStatus: ConsultationStatus.success,
        createdConsultation: data,
      )),
    );
  }

  /// Converts a LawyerDetailModel to a lightweight LawyerModel for the create call.
  LawyerModel? _lawyerFromRecommended(LawyerDetailModel? detail) {
    if (detail == null) return null;
    return LawyerModel(
      id: detail.id,
      fullName: detail.fullName,
      photoUrl: detail.photoUrl,
      city: detail.city,
      experienceYears: detail.experienceYears,
      rating: detail.rating,
      mainSpecializations: detail.mainSpecializations,
      consultationFee: detail.consultationFee,
      isCompany: detail.isCompany,
      bio: detail.bio,
    );
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void resetFlow() => emit(const ConsultationState());
}