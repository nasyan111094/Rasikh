
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/get_it_service/get_it_service.dart';
import '../models/consultation_model.dart';
import '../repo/consulation_application_repo.dart';
import 'consulation_application_state.dart';
import '../models/bookable_slot_model.dart';

class ConsultationApplicationCubit extends Cubit<ConsultationState> {
  ConsultationApplicationCubit() : super(const ConsultationState());

  final ConsultationRepo _repo = getIt.get<ConsultationRepo>();

  /// Stable idempotency key for the in-flight create request.
  /// Generated once per attempt so a retry reuses it.
  String? _createIdempotencyKey;


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
        specializations: data.specializations,
        lawsuitTypesBySubSpecialization: data.lawsuitTypes,
      )),
    );
  }

  void selectSpecialization(SpecializationModel specialization) {
    emit(state.copyWith(
      selectedSpecialization: specialization,
      selectedSubSpecializations: [],
      clearSelectedLawsuitType: true,
    ));
  }

  void selectSubSpecialization(SubSpecializationModel sub) {
    emit(state.copyWith(
      selectedSubSpecializations: [sub],
      clearSelectedLawsuitType: true,
    ));
  }

  void selectLawsuitType(SubSpecializationModel lawsuitType) {
    emit(state.copyWith(selectedLawsuitType: lawsuitType));
  }

  /// Sub-specialization is optional → allow clearing it (also clears lawsuit).
  void clearSubSpecialization() {
    emit(state.copyWith(
      selectedSubSpecializations: const [],
      clearSelectedLawsuitType: true,
    ));
  }

  /// Lawsuit type is optional → allow clearing it.
  void clearLawsuitType() {
    emit(state.copyWith(clearSelectedLawsuitType: true));
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


  void selectConsultationType(ConsultationType type) {
    emit(state.copyWith(selectedConsultationType: type));
  }

  /// Backwards-compatible read-only alias for the in-state selection.
  /// The old mutable out-of-state field was removed (singleton leak fix);
  /// all writes must go through [selectConsultationType].
  ConsultationType get selectedConsultationType => state.selectedConsultationType;


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
          (data) {
            if (data.isEmpty) {
              emit(state.copyWith(
                pricingStatus: ConsultationStatus.failure,
                pricingError: 'لا توجد باقات سعر متاحة',
              ));
              return;
            }
            // Keep the user's previous pricing selection when it is still
            // present in the refreshed list (e.g. navigating back).
            final previousId = state.selectedPricing?.id;
            PricingModel effective = data.first;
            if (previousId != null) {
              for (final p in data) {
                if (p.id == previousId) {
                  effective = p;
                  break;
                }
              }
            }
            emit(state.copyWith(
        pricingStatus: ConsultationStatus.success,
        pricingPlans: data,
         selectedPricing: effective,
      )) ;}
    );
  }





  void selectPricing(PricingModel pricing) {
    emit(state.copyWith(selectedPricing: pricing));
  }

  /// Backwards-compatible read-only alias for the in-state pricing.
  /// The old mutable out-of-state field was removed (singleton leak fix);
  /// all writes must go through [selectPricing].
  PricingModel? get selectedPricing => state.selectedPricing;

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
      lawsuitTypesBySubSpecialization: s.lawsuitTypesBySubSpecialization,
      selectedLawsuitType: s.selectedLawsuitType,
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
      availability: state.selectedConsultationType != ConsultationType.scheduled,
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


  void selectDay(int index) {
    // Day change invalidates the previously picked slot to avoid
    // booking a stale slot from another date (race + UX bug).
    // start/end stay null until the user picks a real bookable slot.
    emit(state.copyWith(
      selectedDayIndex: index,
      clearSelectedBookableSlot: true,
      clearTimes: true,
    ));
    // NOTE: do NOT call _resolveScheduledTimes() here — that legacy
    // hardcoded 9AM grid would fabricate a time before slot selection.
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
          (slots) {
        // Drop a previously selected slot if it vanished from the
        // fresh server list (booked by someone else meanwhile).
        final selected = state.selectedBookableSlot;
        final stillThere = selected == null ||
            slots.slots.any((s) =>
                s.startTime.isAtSameMomentAs(selected.startTime) &&
                s.endTime.isAtSameMomentAs(selected.endTime));
        emit(state.copyWith(
          bookableSlotsStatus: ConsultationStatus.success,
          bookableSlots: slots,
          clearSelectedBookableSlot: !stillThere,
          clearTimes: !stillThere,
        ));
      },
    );
  }

  void selectBookableSlot(BookableSlotModel slot) {
    // Guard against tapping an already-past slot (stale list race).
    if (slot.startTime.isBefore(DateTime.now())) return;
    emit(state.copyWith(
      selectedBookableSlot: slot,
      startTime: slot.startTime,
      endTime: slot.endTime,
    ));
  }


  Future<void> createConsultation() async {
    // Re-entrancy guard: the bottom button is already disabled while
    // loading, this covers programmatic double-calls.
    if (state.createStatus == ConsultationStatus.loading) return;

    final lawyer =
        state.selectedLawyer ?? _lawyerFromRecommended(state.recommendedLawyer);

    // Explicit validation instead of a silent `return` (previous bug:
    // UI hung with no feedback when data was missing).
    if (lawyer == null) {
      emit(state.copyWith(
        createStatus: ConsultationStatus.failure,
        createError: 'يرجى اختيار المحامي أولاً',
      ));
      return;
    }
    if (state.selectedSpecialization == null) {
      emit(state.copyWith(
        createStatus: ConsultationStatus.failure,
        createError: 'يرجى اختيار التخصص أولاً',
      ));
      return;
    }
    if (state.selectedPricing == null) {
      emit(state.copyWith(
        createStatus: ConsultationStatus.failure,
        createError: 'يرجى اختيار باقة السعر أولاً',
      ));
      return;
    }
    if (state.consultationTitle.trim().isEmpty ||
        state.consultationDetails.trim().isEmpty) {
      emit(state.copyWith(
        createStatus: ConsultationStatus.failure,
        createError: 'يرجى إدخال عنوان وتفاصيل الاستشارة',
      ));
      return;
    }
    if (state.isScheduled) {
      final slot = state.selectedBookableSlot;
      final start = state.startTime;
      if (slot == null || start == null) {
        emit(state.copyWith(
          createStatus: ConsultationStatus.failure,
          createError: 'يرجى اختيار موعد الجلسة أولاً',
        ));
        return;
      }
      if (start.isBefore(DateTime.now())) {
        emit(state.copyWith(
          createStatus: ConsultationStatus.failure,
          createError: 'الموعد المختار انتهى، يرجى اختيار موعد آخر',
          clearSelectedBookableSlot: true,
          clearTimes: true,
        ));
        return;
      }
      // Stale-slot race: picked slot must still exist in the last fetch.
      final stillAvailable = state.bookableSlots?.slots.any((s) =>
              s.startTime.isAtSameMomentAs(slot.startTime) &&
              s.endTime.isAtSameMomentAs(slot.endTime)) ??
          true;
      if (!stillAvailable) {
        emit(state.copyWith(
          createStatus: ConsultationStatus.failure,
          createError: 'هذا الموعد تم حجزه، يرجى اختيار موعد آخر',
          clearSelectedBookableSlot: true,
          clearTimes: true,
        ));
        return;
      }
    }

    emit(state.copyWith(
      createStatus: ConsultationStatus.loading,
      createError: null,
    ));

    _createIdempotencyKey ??= const Uuid().v4();

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

    final result = await _repo.createConsultation(
      params,
      lawsuitTypeId: state.selectedLawsuitType?.id,
      idempotencyKey: _createIdempotencyKey,
    );

    result.fold(
          (error) => emit(state.copyWith(
        createStatus: ConsultationStatus.failure,
        createError: error,
      )),
          (data) {
        // Fresh key for the next consultation; retry of THIS one
        // would have reused the same key above.
        _createIdempotencyKey = null;
        emit(state.copyWith(
          createStatus: ConsultationStatus.success,
          createdConsultation: data,
        ));
      },
    );
  }

  LawyerModel? _lawyerFromRecommended(LawyerDetailModel? detail) {
    if (detail == null) return null;
    return LawyerModel(
      id: detail.id,
      fullName: detail.fullName,
      photoUrl: detail.photoUrl,
      city: detail.city,
      cities: detail.cities,
      experienceYears: detail.experienceYears,
      rating: detail.rating,
      mainSpecializations: detail.mainSpecializations,
      consultationFee: detail.consultationFee,
      isCompany: detail.isCompany,
      bio: detail.bio,
    );
  }


  void resetFlow() {
    _createIdempotencyKey = null;
    emit(const ConsultationState());
  }

  /// Clears ONLY payment-related state (retry keeps [createdConsultation]).
  void clearPaymentState() {
    emit(state.copyWith(
      paymentStatus: ConsultationStatus.initial,
      clearPaymentData: true,
    ));
  }


  Future<void> loadExistingConsultationForPayment(
      CreatedConsultationModel consultation) async {
    emit(state.copyWith(
      createdConsultation: consultation,
      createStatus: ConsultationStatus.success,
    ));
  }


  Future<void> payWithWallet() async {
    final consultationId = state.createdConsultation?.id;
    if (consultationId == null) {
      emit(state.copyWith(
        paymentStatus: ConsultationStatus.failure,
        paymentError: 'يرجى إنشاء الاستشارة أولاً',
      ));
      return;
    }
    if (state.paymentStatus == ConsultationStatus.loading) return;

    emit(state.copyWith(
      paymentStatus: ConsultationStatus.loading,
      paymentError: null,
    ));

    final result = await _repo.payWithWallet(consultationId: consultationId);

    result.fold(
      (error) => emit(state.copyWith(
        paymentStatus: ConsultationStatus.failure,
        paymentError: error,
      )),
      (data) => emit(state.copyWith(
        paymentStatus: ConsultationStatus.success,
        paymentData: data,
      )),
    );
  }

  Future<void> initiatePayment() async {
    final consultationId = state.createdConsultation?.id;
    if (consultationId == null) {
      emit(state.copyWith(
        paymentStatus: ConsultationStatus.failure,
        paymentError: 'يرجى إنشاء الاستشارة أولاً',
      ));
      return;
    }
    if (state.paymentStatus == ConsultationStatus.loading) return;

    emit(state.copyWith(
      paymentStatus: ConsultationStatus.loading,
      paymentError: null,
    ));

    final result = await _repo.initiatePayment(consultationId: consultationId);

    result.fold(
      (error) => emit(state.copyWith(
        paymentStatus: ConsultationStatus.failure,
        paymentError: error,
      )),
      (data) => emit(state.copyWith(
        paymentStatus: ConsultationStatus.success,
        paymentData: data,
      )),
    );
  }


  Future<String> checkPaymentStatus() async {
    final consultationId = state.createdConsultation?.id;
    if (consultationId == null) return 'error';

    // 30 × 2s ≈ 60s to tolerate slow MyFatoorah webhooks.
    for (int i = 0; i < 30; i++) {
      final result = await _repo.checkPaymentStatus(
        consultationId: consultationId,
      );

      final resultStatus = await result.fold(
        (error) async {
          await Future.delayed(const Duration(seconds: 2));
          return null;
        },
        (paymentData) async {
          final normalized =
              ConsultationRepo.normalizePaymentStatus(paymentData);
          if (normalized == 'paid' || normalized == 'failed') {
            return normalized;
          }
          await Future.delayed(const Duration(seconds: 2));
          return null;
        },
      );

      if (resultStatus != null) {
        return resultStatus;
      }
    }

    return 'pending';
  }
}