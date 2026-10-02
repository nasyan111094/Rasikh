
import 'dart:io';

import '../models/consultation_model.dart';
import '../models/bookable_slot_model.dart';

enum ConsultationStatus { initial, loading, success, failure }

class ConsultationState {
  final ConsultationStatus specializationsStatus;
  final List<SpecializationModel> specializations;
  final String? specializationsError;

  final SpecializationModel? selectedSpecialization;
  final List<SubSpecializationModel> selectedSubSpecializations;
  final Map<String, List<SubSpecializationModel>>
      lawsuitTypesBySubSpecialization;
  final SubSpecializationModel? selectedLawsuitType;

  final ConsultationStatus consultationTypesStatus;
  final List<EnumValueModel> consultationTypes;
  final String? consultationTypesError;

  final ConsultationStatus citiesStatus;
  final List<EnumValueModel> cities;
  final String? citiesError;

  final ConsultationType selectedConsultationType;

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

  final int selectedDayIndex;
  final int selectedTimeIndex;
  final DateTime? startTime;
  final DateTime? endTime;

  final ConsultationStatus bookableSlotsStatus;
  final BookableSlotsResponse? bookableSlots;
  final String? bookableSlotsError;
  final BookableSlotModel? selectedBookableSlot;

  final ConsultationStatus createStatus;
  final CreatedConsultationModel? createdConsultation;
  final String? createError;

  final ConsultationStatus paymentStatus;
  final Map<String, dynamic>? paymentData;
  final String? paymentError;

  const ConsultationState({
    this.specializationsStatus = ConsultationStatus.initial,
    this.specializations = const [],
    this.specializationsError,

    this.selectedSpecialization,
    this.selectedSubSpecializations = const [],
    this.lawsuitTypesBySubSpecialization = const {},
    this.selectedLawsuitType,

    this.consultationTypesStatus = ConsultationStatus.initial,
    this.consultationTypes = const [],
    this.consultationTypesError,

    this.citiesStatus = ConsultationStatus.initial,
    this.cities = const [],
    this.citiesError,

    this.selectedConsultationType = ConsultationType.instant,

    this.pricingStatus = ConsultationStatus.initial,
    this.pricingPlans = const [],
    this.selectedPricing,
    this.pricingError,

    this.consultationTitle = '',
    this.consultationDetails = '',
    this.hideClientFromLawyer = false,
    this.voiceNote,
    this.voiceNoteDurationSeconds,
    this.attachments = const [],

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

    this.selectedDayIndex = 0,
    this.selectedTimeIndex = 0,
    this.startTime,
    this.endTime,

    this.bookableSlotsStatus = ConsultationStatus.initial,
    this.bookableSlots,
    this.bookableSlotsError,
    this.selectedBookableSlot,

    this.createStatus = ConsultationStatus.initial,
    this.createdConsultation,
    this.createError,

    this.paymentStatus = ConsultationStatus.initial,
    this.paymentData,
    this.paymentError,
  });

  ConsultationState copyWith({
    ConsultationStatus? specializationsStatus,
    List<SpecializationModel>? specializations,
    String? specializationsError,
    SpecializationModel? selectedSpecialization,
    List<SubSpecializationModel>? selectedSubSpecializations,
    Map<String, List<SubSpecializationModel>>? lawsuitTypesBySubSpecialization,
    SubSpecializationModel? selectedLawsuitType,
    bool clearSelectedLawsuitType = false,

    ConsultationStatus? consultationTypesStatus,
    List<EnumValueModel>? consultationTypes,
    String? consultationTypesError,

    ConsultationStatus? citiesStatus,
    List<EnumValueModel>? cities,
    String? citiesError,

    ConsultationType? selectedConsultationType,

    ConsultationStatus? pricingStatus,
    List<PricingModel>? pricingPlans,
    PricingModel? selectedPricing,
    String? pricingError,

    String? consultationTitle,
    String? consultationDetails,
    bool? hideClientFromLawyer,
    File? voiceNote,
    int? voiceNoteDurationSeconds,
    List<File>? attachments,

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

    int? selectedDayIndex,
    int? selectedTimeIndex,
    DateTime? startTime,
    DateTime? endTime,

    ConsultationStatus? bookableSlotsStatus,
    BookableSlotsResponse? bookableSlots,
    String? bookableSlotsError,
    BookableSlotModel? selectedBookableSlot,

    ConsultationStatus? createStatus,
    CreatedConsultationModel? createdConsultation,
    String? createError,

    ConsultationStatus? paymentStatus,
    Map<String, dynamic>? paymentData,
    String? paymentError,
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
        lawsuitTypesBySubSpecialization: lawsuitTypesBySubSpecialization ??
            this.lawsuitTypesBySubSpecialization,
        selectedLawsuitType: clearSelectedLawsuitType
            ? null
            : selectedLawsuitType ?? this.selectedLawsuitType,

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

        paymentStatus: paymentStatus ?? this.paymentStatus,
        paymentData: paymentData ?? this.paymentData,
        paymentError: paymentError ?? this.paymentError,
      );


  List<SubSpecializationModel> get availableLawsuitTypes =>
      selectedSubSpecializations.isEmpty
          ? const []
          : lawsuitTypesBySubSpecialization[
                  selectedSubSpecializations.first.id] ??
              const [];

  bool get canProceedFromSpecialty =>
      selectedSpecialization != null &&
      selectedSubSpecializations.isNotEmpty &&
      (availableLawsuitTypes.isEmpty || selectedLawsuitType != null);

  bool get canProceedFromDetails =>
      consultationTitle.trim().isNotEmpty &&
          consultationDetails.trim().isNotEmpty &&
          selectedPricing != null;

  bool get isScheduled =>
      selectedConsultationType == ConsultationType.scheduled;

  List<String> get cityNames => cities.map((e) => e.value).toList();
}