// ─────────────────────────────────────────────────────────────────────────────
// consulation_application_cubit.dart
//
// Flow summary:
//  • instant / written  → createConsultation() called from ChooseLawyerScreen
//                         after selectLawyer(). Payment screen navigated to on
//                         success via BlocListener in ChooseLawyerScreen.
//  • scheduled          → selectLawyer() only from ChooseLawyerScreen.
//                         AppointmentBookingScreen lets user pick time.
//                         createConsultation() called from AppointmentBookingScreen
//                         after confirming. Payment screen navigated to on
//                         success via BlocListener in AppointmentBookingScreen.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/get_it_service/get_it_service.dart';
import '../models/consultation_model.dart';
import '../repo/consulation_application_repo.dart';
import 'consulation_application_state.dart';
import '../models/bookable_slot_model.dart';

class ConsultationApplicationCubit extends Cubit<ConsultationState> {
  ConsultationApplicationCubit() : super(const ConsultationState());

  final ConsultationRepo _repo = getIt.get<ConsultationRepo>();

  // ── Step-1: Specializations ───────────────────────────────────────────────

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

  // ── Enums ─────────────────────────────────────────────────────────────────

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

  Future<void> loadCities() async {
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

  // Also stored outside state so ConnectingToLawyerScreen can read it
  // synchronously without needing a BlocBuilder.
  ConsultationType? selectedConsultationType = ConsultationType.instant;

  void selectConsultationType(ConsultationType type) {
    selectedConsultationType = type;
    emit(state.copyWith(selectedConsultationType: type));
  }

  // ── Step-3: Pricing + Details ─────────────────────────────────────────────

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
        selectedPricing:
        state.selectedPricing ?? (data.isNotEmpty ? data.first : null),
      )),
    );
  }

  void selectPricing(PricingModel pricing) =>
      emit(state.copyWith(selectedPricing: pricing));

  void updateTitle(String value) =>
      emit(state.copyWith(consultationTitle: value));

  void updateDetails(String value) =>
      emit(state.copyWith(consultationDetails: value));

  void setHideClientFromLawyer(bool value) =>
      emit(state.copyWith(hideClientFromLawyer: value));

  void setVoiceNote(File file, int durationSeconds) => emit(state.copyWith(
    voiceNote: file,
    voiceNoteDurationSeconds: durationSeconds,
  ));

  void clearVoiceNote() => emit(_stateWithNullVoiceNote(state));

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
      voiceNote: null,
      voiceNoteDurationSeconds: null,
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

  void selectLawyer(LawyerModel lawyer) =>
      emit(state.copyWith(selectedLawyer: lawyer));

  Future<void> selectLawyerAndLoadDetail(LawyerModel lawyer) async {
    emit(state.copyWith(selectedLawyer: lawyer));
    if (state.selectedLawyerDetail?.id != lawyer.id) {
      await loadLawyerDetail(lawyer.id);
    }
  }

  // ── Step-5: Appointment scheduling (scheduled only) ───────────────────────

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

  // ── Bookable slots fetching ───────────────────────────────────────────────
  // Fetch available slots for a lawyer within a date range
  // typically from today to today+7 days

  Future<void> fetchBookableSlots({
    required String lawyerId,
    DateTime? from,
    DateTime? to,
    int? durationMinutes,
  }) async {
    emit(state.copyWith(
      bookableSlotsStatus: ConsultationStatus.loading,
      bookableSlotsError: null,
    ));

    final fromDate = from ?? DateTime.now();
    final toDate = to ?? DateTime.now().add(const Duration(days: 7));

    // Round to start of day (use logical time, not UTC)
    final fromRounded = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final toRounded = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);

    final duration = durationMinutes ?? (state.selectedPricing?.duration ?? 30);

    final result = await _repo.fetchBookableSlots(
      lawyerId: lawyerId,
      from: fromRounded,
      to: toRounded,
      durationMinutes: duration,
    );

    result.fold(
          (error) => emit(state.copyWith(
        bookableSlotsStatus: ConsultationStatus.failure,
        bookableSlotsError: error,
      )),
          (slots) => emit(state.copyWith(
        bookableSlotsStatus: ConsultationStatus.success,
        bookableSlots: slots,
      )),
    );
  }

  // Select a bookable slot and derive startTime/endTime
  void selectBookableSlot(BookableSlotModel slot) {
    emit(state.copyWith(
      selectedBookableSlot: slot,
      startTime: slot.startTime,
      endTime: slot.endTime,
    ));
  }

  // ── Step-6: Create consultation ───────────────────────────────────────────
  //
  // Called from:
  //  • ChooseLawyerScreen (_onConsult) for instant / written
  //  • AppointmentBookingScreen (Next button) for scheduled
  //
  // On success the calling screen's BlocListener handles navigation:
  //  • instant / written  → paymentScreen
  //  • scheduled          → paymentScreen (same listener pattern)

  Future<void> createConsultation() async {
    final lawyer =
        state.selectedLawyer ?? _lawyerFromRecommended(state.recommendedLawyer);

    if (lawyer == null ||
        state.selectedSpecialization == null ||
        state.selectedPricing == null) return;

    // Reset previous result so listeners fire even on retry
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

  void resetFlow() {
    selectedConsultationType = null;
    emit(const ConsultationState());
  }
}