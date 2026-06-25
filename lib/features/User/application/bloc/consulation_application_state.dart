// ─────────────────────────────────────────────────────────────────────────────
// consulation_application_state.dart
// Master state shared across all steps of the Create-Consultation flow.
// Added: citiesStatus/cities/citiesError for /api/v1/enums/cities
// Added: consultationTypesStatus for /api/v1/enums/consultation-types
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import '../models/consultation_model.dart';
import '../models/bookable_slot_model.dart';

enum ConsultationStatus { initial, loading, success, failure }

class ConsultationState {
  // ── Step-1: Specializations ────────────────────────────────────────────────
  final ConsultationStatus specializationsStatus;
  final List<SpecializationModel> specializations;
  final String? specializationsError;

  final SpecializationModel? selectedSpecialization;
  final List<SubSpecializationModel> selectedSubSpecializations;

  // ── Enums: Consultation types (from /api/v1/enums/consultation-types) ──────
  final ConsultationStatus consultationTypesStatus;
  final List<EnumValueModel> consultationTypes;
  final String? consultationTypesError;

  // ── Enums: Cities (from /api/v1/enums/cities) ─────────────────────────────
  final ConsultationStatus citiesStatus;
  final List<EnumValueModel> cities;
  final String? citiesError;

  // ── Step-2: Consultation type ──────────────────────────────────────────────
  final ConsultationType selectedConsultationType;

  // ── Step-3: Consultation details ──────────────────────────────────────────
  final ConsultationStatus pricingStatus;
  final List<PricingModel> pricingPlans;
  final PricingModel? selectedPricing;
  final String? pricingError;

  final String consultationTitle;
  final String consultationDetails;
  final bool hideClientFromLawyer;

  final File? voiceNote;
  final int? voiceNoteDurationSeconds;
  final List<File> attachments;

  // ── Step-4: Lawyer selection ───────────────────────────────────────────────
  final ConsultationStatus lawyersStatus;
  final List<LawyerDetailModel> lawyers;
  final String? lawyersError;

  final ConsultationStatus recommendedLawyerStatus;
  final LawyerDetailModel? recommendedLawyer;
  final String? recommendedLawyerError;

  final ConsultationStatus lawyerDetailStatus;
  final LawyerDetailModel? selectedLawyerDetail;
  final String? lawyerDetailError;

  final LawyerModel? selectedLawyer;

  // ── Step-5: Schedule ──────────────────────────────────────────────────────
  final int selectedDayIndex;
  final int selectedTimeIndex;
  final DateTime? startTime;
  final DateTime? endTime;

  // ── Bookable slots for scheduled consultations ──────────────────────────────
  final ConsultationStatus bookableSlotsStatus;
  final BookableSlotsResponse? bookableSlots;
  final String? bookableSlotsError;
  final BookableSlotModel? selectedBookableSlot;

  // ── Step-6: Create consultation ───────────────────────────────────────────
  final ConsultationStatus createStatus;
  final CreatedConsultationModel? createdConsultation;
  final String? createError;

  const ConsultationState({
    // Specializations
    this.specializationsStatus = ConsultationStatus.initial,
    this.specializations = const [],
    this.specializationsError,

    this.selectedSpecialization,
    this.selectedSubSpecializations = const [],

    // Consultation type enums
    this.consultationTypesStatus = ConsultationStatus.initial,
    this.consultationTypes = const [],
    this.consultationTypesError,

    // Cities enum
    this.citiesStatus = ConsultationStatus.initial,
    this.cities = const [],
    this.citiesError,

    // Consultation type selection
    this.selectedConsultationType = ConsultationType.instant,

    // Pricing
    this.pricingStatus = ConsultationStatus.initial,
    this.pricingPlans = const [],
    this.selectedPricing,
    this.pricingError,

    // Details
    this.consultationTitle = '',
    this.consultationDetails = '',
    this.hideClientFromLawyer = false,
    this.voiceNote,
    this.voiceNoteDurationSeconds,
    this.attachments = const [],

    // Lawyers
    this.lawyersStatus = ConsultationStatus.initial,
    this.lawyers = const [],
    this.lawyersError,

    this.recommendedLawyerStatus = ConsultationStatus.initial,
    this.recommendedLawyer,
    this.recommendedLawyerError,

    this.lawyerDetailStatus = ConsultationStatus.initial,
    this.selectedLawyerDetail,
    this.lawyerDetailError,

    this.selectedLawyer,

    // Schedule
    this.selectedDayIndex = 0,
    this.selectedTimeIndex = 0,
    this.startTime,
    this.endTime,

    // Bookable slots
    this.bookableSlotsStatus = ConsultationStatus.initial,
    this.bookableSlots,
    this.bookableSlotsError,
    this.selectedBookableSlot,

    // Create
    this.createStatus = ConsultationStatus.initial,
    this.createdConsultation,
    this.createError,
  });

  ConsultationState copyWith({
    // Specializations
    ConsultationStatus? specializationsStatus,
    List<SpecializationModel>? specializations,
    String? specializationsError,
    SpecializationModel? selectedSpecialization,
    List<SubSpecializationModel>? selectedSubSpecializations,

    // Consultation type enums
    ConsultationStatus? consultationTypesStatus,
    List<EnumValueModel>? consultationTypes,
    String? consultationTypesError,

    // Cities enum
    ConsultationStatus? citiesStatus,
    List<EnumValueModel>? cities,
    String? citiesError,

    // Type selection
    ConsultationType? selectedConsultationType,

    // Pricing
    ConsultationStatus? pricingStatus,
    List<PricingModel>? pricingPlans,
    PricingModel? selectedPricing,
    String? pricingError,

    // Details
    String? consultationTitle,
    String? consultationDetails,
    bool? hideClientFromLawyer,
    File? voiceNote,
    int? voiceNoteDurationSeconds,
    List<File>? attachments,

    // Lawyers
    ConsultationStatus? lawyersStatus,
    List<LawyerDetailModel>? lawyers,
    String? lawyersError,

    ConsultationStatus? recommendedLawyerStatus,
    LawyerDetailModel? recommendedLawyer,
    String? recommendedLawyerError,

    ConsultationStatus? lawyerDetailStatus,
    LawyerDetailModel? selectedLawyerDetail,
    String? lawyerDetailError,

    LawyerModel? selectedLawyer,

    // Schedule
    int? selectedDayIndex,
    int? selectedTimeIndex,
    DateTime? startTime,
    DateTime? endTime,

    // Bookable slots
    ConsultationStatus? bookableSlotsStatus,
    BookableSlotsResponse? bookableSlots,
    String? bookableSlotsError,
    BookableSlotModel? selectedBookableSlot,

    // Create
    ConsultationStatus? createStatus,
    CreatedConsultationModel? createdConsultation,
    String? createError,
  }) =>
      ConsultationState(
        specializationsStatus:
        specializationsStatus ?? this.specializationsStatus,
        specializations: specializations ?? this.specializations,
        specializationsError: specializationsError ?? this.specializationsError,
        selectedSpecialization:
        selectedSpecialization ?? this.selectedSpecialization,
        selectedSubSpecializations:
        selectedSubSpecializations ?? this.selectedSubSpecializations,

        consultationTypesStatus:
        consultationTypesStatus ?? this.consultationTypesStatus,
        consultationTypes: consultationTypes ?? this.consultationTypes,
        consultationTypesError:
        consultationTypesError ?? this.consultationTypesError,

        citiesStatus: citiesStatus ?? this.citiesStatus,
        cities: cities ?? this.cities,
        citiesError: citiesError ?? this.citiesError,

        selectedConsultationType:
        selectedConsultationType ?? this.selectedConsultationType,

        pricingStatus: pricingStatus ?? this.pricingStatus,
        pricingPlans: pricingPlans ?? this.pricingPlans,
        selectedPricing: selectedPricing ?? this.selectedPricing,
        pricingError: pricingError ?? this.pricingError,

        consultationTitle: consultationTitle ?? this.consultationTitle,
        consultationDetails: consultationDetails ?? this.consultationDetails,
        hideClientFromLawyer: hideClientFromLawyer ?? this.hideClientFromLawyer,
        voiceNote: voiceNote ?? this.voiceNote,
        voiceNoteDurationSeconds:
        voiceNoteDurationSeconds ?? this.voiceNoteDurationSeconds,
        attachments: attachments ?? this.attachments,

        lawyersStatus: lawyersStatus ?? this.lawyersStatus,
        lawyers: lawyers ?? this.lawyers,
        lawyersError: lawyersError ?? this.lawyersError,

        recommendedLawyerStatus:
        recommendedLawyerStatus ?? this.recommendedLawyerStatus,
        recommendedLawyer: recommendedLawyer ?? this.recommendedLawyer,
        recommendedLawyerError:
        recommendedLawyerError ?? this.recommendedLawyerError,

        lawyerDetailStatus: lawyerDetailStatus ?? this.lawyerDetailStatus,
        selectedLawyerDetail: selectedLawyerDetail ?? this.selectedLawyerDetail,
        lawyerDetailError: lawyerDetailError ?? this.lawyerDetailError,

        selectedLawyer: selectedLawyer ?? this.selectedLawyer,

        selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
        selectedTimeIndex: selectedTimeIndex ?? this.selectedTimeIndex,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,

        bookableSlotsStatus: bookableSlotsStatus ?? this.bookableSlotsStatus,
        bookableSlots: bookableSlots ?? this.bookableSlots,
        bookableSlotsError: bookableSlotsError ?? this.bookableSlotsError,
        selectedBookableSlot: selectedBookableSlot ?? this.selectedBookableSlot,

        createStatus: createStatus ?? this.createStatus,
        createdConsultation: createdConsultation ?? this.createdConsultation,
        createError: createError ?? this.createError,
      );

  // ── Convenience getters ───────────────────────────────────────────────────

  bool get canProceedFromSpecialty =>
      selectedSpecialization != null && selectedSubSpecializations.isNotEmpty;

  bool get canProceedFromDetails =>
      consultationTitle.trim().isNotEmpty &&
          consultationDetails.trim().isNotEmpty &&
          selectedPricing != null;

  bool get isScheduled =>
      selectedConsultationType == ConsultationType.scheduled;

  /// City names derived from the enum API (falls back to empty list).
  List<String> get cityNames => cities.map((e) => e.value).toList();
}