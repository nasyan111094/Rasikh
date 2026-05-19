// ─────────────────────────────────────────────────────────────────────────────
// shared/auth/bloc/auth_state.dart
// PROFESSIONAL SINGLE STATE ARCHITECTURE
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';


import '../models/auth_model.dart';

class AuthState extends Equatable {
  // ── SEND OTP STATUS ───────────────────────────────────────────────────────
  final RequestStatus sendOtpStatus;

  // ── VERIFY OTP STATUS ─────────────────────────────────────────────────────
  final RequestStatus verifyOtpStatus;

  // ── RESEND OTP STATUS ─────────────────────────────────────────────────────
  final RequestStatus resendOtpStatus;

  // ── ERROR ─────────────────────────────────────────────────────────────────
  final String errorMessage;

  // ── TIMER ─────────────────────────────────────────────────────────────────
  final int secondsLeft;
  final bool canResend;

  // ── FLOW ──────────────────────────────────────────────────────────────────
  final bool isRegister;

  // ── RESPONSE MODELS ───────────────────────────────────────────────────────
  final SharedOtpSentModel? otpSentModel;
  final SharedOtpSentModel? resendOtpModel;
  final SharedVerifyOtpModel? verifyOtpModel;

  const AuthState({
    this.sendOtpStatus = RequestStatus.initial,
    this.verifyOtpStatus = RequestStatus.initial,
    this.resendOtpStatus = RequestStatus.initial,
    this.errorMessage = '',
    this.secondsLeft = 60,
    this.canResend = false,
    this.isRegister = false,
    this.otpSentModel,
    this.resendOtpModel,
    this.verifyOtpModel,
  });

  AuthState copyWith({
    RequestStatus? sendOtpStatus,
    RequestStatus? verifyOtpStatus,
    RequestStatus? resendOtpStatus,
    String? errorMessage,
    int? secondsLeft,
    bool? canResend,
    bool? isRegister,
    SharedOtpSentModel? otpSentModel,
    SharedOtpSentModel? resendOtpModel,
    SharedVerifyOtpModel? verifyOtpModel,
  }) {
    return AuthState(
      sendOtpStatus: sendOtpStatus ?? this.sendOtpStatus,
      verifyOtpStatus:
      verifyOtpStatus ?? this.verifyOtpStatus,
      resendOtpStatus:
      resendOtpStatus ?? this.resendOtpStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      canResend: canResend ?? this.canResend,
      isRegister: isRegister ?? this.isRegister,
      otpSentModel: otpSentModel ?? this.otpSentModel,
      resendOtpModel:
      resendOtpModel ?? this.resendOtpModel,
      verifyOtpModel:
      verifyOtpModel ?? this.verifyOtpModel,
    );
  }

  // ── RESET METHODS ─────────────────────────────────────────────────────────

  AuthState resetSendOtp() {
    return copyWith(
      sendOtpStatus: RequestStatus.initial,
      errorMessage: '',
    );
  }

  AuthState resetVerifyOtp() {
    return copyWith(
      verifyOtpStatus: RequestStatus.initial,
      errorMessage: '',
    );
  }

  AuthState resetResendOtp() {
    return copyWith(
      resendOtpStatus: RequestStatus.initial,
      errorMessage: '',
    );
  }

  @override
  List<Object?> get props => [
    sendOtpStatus,
    verifyOtpStatus,
    resendOtpStatus,
    errorMessage,
    secondsLeft,
    canResend,
    isRegister,
    otpSentModel,
    resendOtpModel,
    verifyOtpModel,
  ];
}


// ─────────────────────────────────────────────────────────────────────────────
// core/enums/request_status.dart
// ─────────────────────────────────────────────────────────────────────────────

enum RequestStatus {
  initial,
  loading,
  success,
  error,
}