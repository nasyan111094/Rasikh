
import 'package:rasikh/config/localization/loc_keys.dart';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';
import '../repo/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final GeneralAuthRepo _repo;

  AuthCubit(this._repo) : super(const AuthState());

  Timer? _timer;

  /// Returns the selected vendor, or emits a clear error when none was
  /// chosen yet (e.g. account-type step skipped) instead of crashing on `!`.
  VendorType? _requireVendor() {
    final vendor = getIt<CacheHelper>().cachedVendorType;
    if (vendor == null) {
      emit(state.copyWith(
        sendOtpStatus: RequestStatus.error,
        errorMessage: Loc.unexpectedError(),
      ));
    }
    return vendor;
  }


  Future<void> login({required String phone}) async {
    if (phone.trim().isEmpty) {
      emit(state.copyWith(
        sendOtpStatus: RequestStatus.error,
        errorMessage:  Loc.pleaseEnterPhoneNumber(),
      ));
      return;
    }

    final vendor = _requireVendor();
    if (vendor == null) return;

    emit(state.copyWith(
      sendOtpStatus: RequestStatus.loading,
      errorMessage:  '',
      isRegister:    false,
    ));

    final result = await _repo.login(
      phone:  phone,
      vendor: vendor,
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


  Future<void> register({required String phone}) async {
    if (phone.trim().isEmpty) {
      emit(state.copyWith(
        sendOtpStatus: RequestStatus.error,
        errorMessage:  Loc.pleaseEnterPhoneNumber(),
      ));
      return;
    }

    final vendor = _requireVendor();
    if (vendor == null) return;

    emit(state.copyWith(
      sendOtpStatus: RequestStatus.loading,
      errorMessage:  '',
      isRegister:    true,
    ));

    final result = await _repo.register(
      phone:  phone,
      vendor: vendor,
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


  Future<void> verifyOtp({
    required String phone,
    required String code,
  }) async {
    if (code.length != 6) {
      emit(state.copyWith(
        verifyOtpStatus: RequestStatus.error,
        errorMessage:    Loc.pleaseEnterFullVerificationCode(),
      ));
      return;
    }

    emit(state.copyWith(
      verifyOtpStatus: RequestStatus.loading,
      errorMessage:    '',
    ));

    final vendor = getIt<CacheHelper>().cachedVendorType;
    if (vendor == null) {
      emit(state.copyWith(
        verifyOtpStatus: RequestStatus.error,
        errorMessage:    Loc.unexpectedError(),
      ));
      return;
    }

    final result = await _repo.verifyOtp(
      phone:  phone,
      code:   code,
      vendor: vendor,
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


  Future<void> resendOtp({required String phone}) async {
    // Guard: ignore taps while the cooldown timer is still running.
    if (!state.canResend || state.resendOtpStatus == RequestStatus.loading) {
      return;
    }

    final vendor = getIt<CacheHelper>().cachedVendorType;
    if (vendor == null) {
      emit(state.copyWith(
        resendOtpStatus: RequestStatus.error,
        errorMessage:    Loc.unexpectedError(),
      ));
      return;
    }

    emit(state.copyWith(resendOtpStatus: RequestStatus.loading));

    final result = await _repo.resendOtp(
      phone:      phone,
      vendor:     vendor,
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


  void resetSendOtpState()   => emit(state.resetSendOtp());
  void resetVerifyOtpState() => emit(state.resetVerifyOtp());
  void resetResendOtpState() => emit(state.resetResendOtp());
  void clearErrors()         => emit(state.copyWith(errorMessage: ''));

  /// Stops the resend cooldown (e.g. after a successful verification so a
  /// stale timer can't keep emitting into a dead page).
  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}