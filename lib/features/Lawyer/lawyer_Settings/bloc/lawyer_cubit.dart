// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/profile/logic/cubit/lawyer_profile_cubit.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../Repo/lawyer_profile_repo.dart';
import '../models/lawyer_profile_model.dart';
import 'lawyer_state.dart';

class LawyerProfileCubit extends Cubit<LawyerProfileState> {
  final LawyerProfileRepo _repo;

  LawyerProfileCubit(this._repo) : super(LawyerProfileInitial());

  // Cached profile so widgets can read it without re-fetching
  LawyerProfileModel? cachedProfile;

  // ── Fetch ─────────────────────────────────────────────────────────────────

  Future<void> getProfile() async {
    emit(LawyerProfileLoading());
    final result = await _repo.getProfile();
    result.fold(
          (error) => emit(LawyerProfileError(error)),
          (profile) {
        cachedProfile = profile;
        emit(LawyerProfileLoaded(profile));
      },
    );
  }

  // ── Update profile ────────────────────────────────────────────────────────

  Future<void> updateProfile({
    required UpdateProfileRequest request,
    File? photo,
  }) async {
    emit(UpdateProfileLoading());
    final result = await _repo.updateProfile(request: request, photo: photo);
    result.fold(
          (error) => emit(UpdateProfileError(error)),
          (profile) {
        cachedProfile = profile;
        emit(UpdateProfileSuccess(profile));
      },
    );
  }

  // ── Update licence ────────────────────────────────────────────────────────

  Future<void> updateLicence({
    required UpdateLicenceRequest request,
    File? licenseImage,
    File? nationalIdDocument,
    File? commercialRegistrationDocument,
  }) async {
    emit(UpdateLicenceLoading());
    final result = await _repo.updateLicence(
      request: request,
      licenseImage: licenseImage,
      nationalIdDocument: nationalIdDocument,
      commercialRegistrationDocument: commercialRegistrationDocument,
    );
    result.fold(
          (error) => emit(UpdateLicenceError(error)),
          (profile) {
        cachedProfile = profile;
        emit(UpdateLicenceSuccess(profile));
      },
    );
  }

  // ── Change phone – step 1: request OTP ───────────────────────────────────

  Future<void> requestPhoneChange({required String phone}) async {
    emit(ChangePhoneRequestLoading());
    final result = await _repo.requestPhoneChange(phone: phone);
    result.fold(
          (error) => emit(ChangePhoneRequestError(error)),
          (message) => emit(ChangePhoneRequestSuccess(message)),
    );
  }

  // ── Change phone – step 2: verify OTP ────────────────────────────────────

  Future<void> verifyPhoneChange({
    required String phone,
    required String code,
  }) async {
    emit(ChangePhoneVerifyLoading());
    final result = await _repo.verifyPhoneChange(phone: phone, code: code);
    result.fold(
          (error) => emit(ChangePhoneVerifyError(error)),
          (response) {
        // Update cached phone
        if (cachedProfile != null) {
          cachedProfile = LawyerProfileModel(
            id: cachedProfile!.id,
            phone: response.newPhoneNumber ?? phone,
            fullName: cachedProfile!.fullName,
            email: cachedProfile!.email,
            city: cachedProfile!.city,
            photoUrl: cachedProfile!.photoUrl,
            nationalId: cachedProfile!.nationalId,
            nationalIdDocumentUrl: cachedProfile!.nationalIdDocumentUrl,
            commercialRegistrationDocumentUrl:
            cachedProfile!.commercialRegistrationDocumentUrl,
            bio: cachedProfile!.bio,
            license: cachedProfile!.license,
            isCompany: cachedProfile!.isCompany,
            commercialRegistrationNumber:
            cachedProfile!.commercialRegistrationNumber,
            qualifications: cachedProfile!.qualifications,
            experienceYears: cachedProfile!.experienceYears,
            mainSpecializations: cachedProfile!.mainSpecializations,
            subSpecializations: cachedProfile!.subSpecializations,
            specializationsByMain: cachedProfile!.specializationsByMain,
            acceptedTerms: cachedProfile!.acceptedTerms,
            status: cachedProfile!.status,
            accountStatus: cachedProfile!.accountStatus,
            activityStatus: cachedProfile!.activityStatus,
            profileCompleted: cachedProfile!.profileCompleted,
            otpVerified: cachedProfile!.otpVerified,
            rating: cachedProfile!.rating,
            createdAt: cachedProfile!.createdAt,
            updatedAt: cachedProfile!.updatedAt,
          );
        }
        emit(ChangePhoneVerifySuccess(response.newPhoneNumber ?? phone));
      },
    );
  }

  // ── Delete account – step 1: send OTP ────────────────────────────────────
  // Calls POST /api/v1/lawyers/account/deletion/otp
  // On success emits [DeleteAccountOtpSuccess] with the masked phone so the
  // UI can open the OTP dialog and show the user where the code was sent.

  Future<void> sendDeletionOtp() async {
    emit(DeleteAccountOtpLoading());
    final result = await _repo.sendDeletionOtp();
    result.fold(
          (error) => emit(DeleteAccountOtpError(error)),
          (phone) => emit(DeleteAccountOtpSuccess(phone)),
    );
  }

  // ── Delete account – step 2: confirm with OTP ─────────────────────────────
  // Calls POST /api/v1/lawyers/account/deletion/request
  // Body: { "confirm": true, "otp": "<code>" }
  // On success emits [DeleteAccountRequestSuccess] with the grace-period
  // details. The UI should then clear the token and navigate to the login
  // screen (or show a "deletion scheduled" banner first).

  Future<void> requestAccountDeletion({required String otp}) async {
    emit(DeleteAccountRequestLoading());
    final result = await _repo.requestAccountDeletion(otp: otp);
    result.fold(
          (error) => emit(DeleteAccountRequestError(error)),
          (response) => emit(DeleteAccountRequestSuccess(response)),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Call after a successful update to re-emit loaded state
  /// so all BlocBuilder listeners refresh.
  void reloadFromCache() {
    if (cachedProfile != null) {
      emit(LawyerProfileLoaded(cachedProfile!));
    }
  }
}