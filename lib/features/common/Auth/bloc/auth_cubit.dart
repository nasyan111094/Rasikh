// ─────────────────────────────────────────────────────────────────────────────
// shared/auth/bloc/auth_cubit.dart
//
// Manages the entire phone-OTP auth flow:
//   1. login / register  → sends OTP → state.sendOtpStatus
//   2. verifyOtp         → validates code → state.verifyOtpStatus
//   3. resendOtp         → re-fires OTP   → state.resendOtpStatus
//   4. Timer             → counts from 60 down to 0, then canResend = true
//
// Validation at the UI layer (Form + PhoneField validator) guards against empty
// input before any cubit method is called.  Guards inside the cubit act as a
// second line of defence only.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';

import '../models/auth_model.dart';
import '../repo/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final GeneralAuthRepo _repo;

  AuthCubit(this._repo) : super(const AuthState());

  Timer? _timer;

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGIN — send OTP for existing account
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> login({required String phone}) async {
    if (phone.trim().isEmpty) {
      emit(state.copyWith(
        sendOtpStatus: RequestStatus.error,
        errorMessage:  'يرجى إدخال رقم الهاتف',
      ));
      return;
    }

    emit(state.copyWith(
      sendOtpStatus: RequestStatus.loading,
      errorMessage:  '',
      isRegister:    false,
    ));

    final result = await _repo.login(
      phone:  phone,
      vendor: getIt<CacheHelper>().cachedVendorType!,
    );

    result.fold(
          (error) => emit(state.copyWith(
        sendOtpStatus: RequestStatus.error,
        errorMessage:  error,
      )),
          (model) => emit(state.copyWith(
        sendOtpStatus: RequestStatus.success,
        otpSentModel:  model,
        isRegister:    false,
      )),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REGISTER — send OTP for new account
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> register({required String phone}) async {
    if (phone.trim().isEmpty) {
      emit(state.copyWith(
        sendOtpStatus: RequestStatus.error,
        errorMessage:  'يرجى إدخال رقم الهاتف',
      ));
      return;
    }

    emit(state.copyWith(
      sendOtpStatus: RequestStatus.loading,
      errorMessage:  '',
      isRegister:    true,
    ));

    final result = await _repo.register(
      phone:  phone,
      vendor: getIt<CacheHelper>().cachedVendorType!,
    );

    result.fold(
          (error) => emit(state.copyWith(
        sendOtpStatus: RequestStatus.error,
        errorMessage:  error,
      )),
          (model) => emit(state.copyWith(
        sendOtpStatus: RequestStatus.success,
        otpSentModel:  model,
        isRegister:    true,
      )),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VERIFY OTP
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> verifyOtp({
    required String phone,
    required String code,
  }) async {
    if (code.length != 6) {
      emit(state.copyWith(
        verifyOtpStatus: RequestStatus.error,
        errorMessage:    'يرجى إدخال رمز التحقق كاملاً',
      ));
      return;
    }

    emit(state.copyWith(
      verifyOtpStatus: RequestStatus.loading,
      errorMessage:    '',
    ));

    final result = await _repo.verifyOtp(
      phone:  phone,
      code:   code,
      vendor: getIt<CacheHelper>().cachedVendorType!,
    );

    result.fold(
          (error) => emit(state.copyWith(
        verifyOtpStatus: RequestStatus.error,
        errorMessage:    error,
      )),
          (model) => emit(state.copyWith(
        verifyOtpStatus: RequestStatus.success,
        verifyOtpModel:  model,
      )),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESEND OTP
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> resendOtp({required String phone}) async {
    emit(state.copyWith(resendOtpStatus: RequestStatus.loading));

    final result = await _repo.resendOtp(
      phone:      phone,
      vendor:     getIt<CacheHelper>().cachedVendorType!,
      isRegister: state.isRegister,
    );

    result.fold(
          (error) => emit(state.copyWith(
        resendOtpStatus: RequestStatus.error,
        errorMessage:    error,
      )),
          (model) => emit(state.copyWith(
        resendOtpStatus: RequestStatus.success,
        resendOtpModel:  model,
      )),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TIMER — 60 s countdown; canResend becomes true at 0
  // ═══════════════════════════════════════════════════════════════════════════

  /// Starts (or restarts) the 60-second OTP cooldown timer.
  /// Call this right after navigating to OtpPage and after a successful resend.
  void startOtpTimer() {
    _timer?.cancel();
    emit(state.copyWith(secondsLeft: 60, canResend: false));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.secondsLeft;

      if (remaining <= 1) {
        timer.cancel();
        emit(state.copyWith(secondsLeft: 0, canResend: true));
      } else {
        emit(state.copyWith(secondsLeft: remaining - 1));
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESETTERS — called after UI handles a completed state
  // ═══════════════════════════════════════════════════════════════════════════

  void resetSendOtpState()   => emit(state.resetSendOtp());
  void resetVerifyOtpState() => emit(state.resetVerifyOtp());
  void resetResendOtpState() => emit(state.resetResendOtp());
  void clearErrors()         => emit(state.copyWith(errorMessage: ''));

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}