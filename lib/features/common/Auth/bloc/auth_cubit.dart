
import 'package:rasikh/config/localization/loc_keys.dart';
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


  Future<void> login({required String phone}) async {
    if (phone.trim().isEmpty) {
      emit(state.copyWith(
        sendOtpStatus: RequestStatus.error,
        errorMessage:  Loc.pleaseEnterPhoneNumber(),
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


  Future<void> register({required String phone}) async {
    if (phone.trim().isEmpty) {
      emit(state.copyWith(
        sendOtpStatus: RequestStatus.error,
        errorMessage:  Loc.pleaseEnterPhoneNumber(),
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

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}