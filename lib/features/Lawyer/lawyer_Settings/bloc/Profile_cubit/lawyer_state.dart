// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/profile/logic/states/lawyer_profile_states.dart
// ─────────────────────────────────────────────────────────────────────────────

import '../../models/lawyer_profile_model.dart';

sealed class LawyerProfileState {}

// ── Initial ───────────────────────────────────────────────────────────────────

final class LawyerProfileInitial extends LawyerProfileState {}

// ── Fetch Profile ─────────────────────────────────────────────────────────────

final class LawyerProfileLoading extends LawyerProfileState {}

final class LawyerProfileLoaded extends LawyerProfileState {
  final LawyerProfileModel profile;
  LawyerProfileLoaded(this.profile);
}

final class LawyerProfileError extends LawyerProfileState {
  final String message;
  LawyerProfileError(this.message);
}

// ── Update Profile ────────────────────────────────────────────────────────────

final class UpdateProfileLoading extends LawyerProfileState {}

final class UpdateProfileSuccess extends LawyerProfileState {
  final LawyerProfileModel profile;
  UpdateProfileSuccess(this.profile);
}

final class UpdateProfileError extends LawyerProfileState {
  final String message;
  UpdateProfileError(this.message);
}

// ── Update Licence ────────────────────────────────────────────────────────────

final class UpdateLicenceLoading extends LawyerProfileState {}

final class UpdateLicenceSuccess extends LawyerProfileState {
  final LawyerProfileModel profile;
  UpdateLicenceSuccess(this.profile);
}

final class UpdateLicenceError extends LawyerProfileState {
  final String message;
  UpdateLicenceError(this.message);
}

// ── Change Phone ──────────────────────────────────────────────────────────────

final class ChangePhoneRequestLoading extends LawyerProfileState {}

final class ChangePhoneRequestSuccess extends LawyerProfileState {
  final String message;
  ChangePhoneRequestSuccess(this.message);
}

final class ChangePhoneRequestError extends LawyerProfileState {
  final String message;
  ChangePhoneRequestError(this.message);
}

final class ChangePhoneVerifyLoading extends LawyerProfileState {}

final class ChangePhoneVerifySuccess extends LawyerProfileState {
  final String newPhone;
  ChangePhoneVerifySuccess(this.newPhone);
}

final class ChangePhoneVerifyError extends LawyerProfileState {
  final String message;
  ChangePhoneVerifyError(this.message);
}

// ── Account Deletion – step 1: send OTP ──────────────────────────────────────

final class DeleteAccountOtpLoading extends LawyerProfileState {}

final class DeleteAccountOtpSuccess extends LawyerProfileState {
  /// The masked phone number returned by the server (e.g. "+966511111111")
  final String phone;
  DeleteAccountOtpSuccess(this.phone);
}

final class DeleteAccountOtpError extends LawyerProfileState {
  final String message;
  DeleteAccountOtpError(this.message);
}

// ── Account Deletion – step 2: confirm + OTP ─────────────────────────────────

final class DeleteAccountRequestLoading extends LawyerProfileState {}

final class DeleteAccountRequestSuccess extends LawyerProfileState {
  final DeleteAccountResponseModel response;
  DeleteAccountRequestSuccess(this.response);
}

final class DeleteAccountRequestError extends LawyerProfileState {
  final String message;
  DeleteAccountRequestError(this.message);
}