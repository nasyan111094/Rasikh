// ─────────────────────────────────────────────────────────────────────────────
// shared/auth/repo/auth_repo.dart
//
// Handles every phone-OTP endpoint that is shared between the Login and
// Register features. The repo is vendor-agnostic at the HTTP level because
// the backend uses the same endpoint paths for all vendor types; only the
// route prefix differs (lawyers/ vs users/ vs companies/).
//
// VendorType is passed in per-call so one repo covers all three vendors.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';

import '../../../../core/cache/cache_helper.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/utils/api/api_handler.dart';
import '../models/auth_model.dart';

// ── Endpoint builder ──────────────────────────────────────────────────────────

class _AuthEndpoints {
  static String register(VendorType v)   => '${_prefix(v)}/register';
  static String login(VendorType v)      => '${_prefix(v)}/login';
  static String verifyOtp(VendorType v)  => '${_prefix(v)}/verify-otp';
  static String resendOtp(VendorType v)  => '${_prefix(v)}/resend-otp';

  static String _prefix(VendorType v) {
    switch (v) {
      case VendorType.user:    return 'clients';
      case VendorType.lawyer:  return 'lawyers';
      case VendorType.company: return 'companies';
    }
  }
}

class GeneralAuthRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;
  CacheHelper get _cache => getIt<CacheHelper>();

  // ── Register – send OTP ───────────────────────────────────────────────────

  Future<Either<String, SharedOtpSentModel>> register({
    required String phone,
    required VendorType vendor,
  }) async {
    final result = await _adapter.post(
      _AuthEndpoints.register(vendor),
      body: {'phone': '+966$phone'},
    );
    if (result.isRight) {
      return Right(SharedOtpSentModel.fromJson(result.right.data));
    }
    return Left(_extractError(result.left));
  }

  // ── Login – send OTP ──────────────────────────────────────────────────────

  Future<Either<String, SharedOtpSentModel>> login({
    required String phone,
    required VendorType vendor,
  }) async {
    final result = await _adapter.post(
      _AuthEndpoints.login(vendor),
      body: {'phone': '+966$phone'},
    );
    if (result.isRight) {




      return Right(SharedOtpSentModel.fromJson(result.right.data));
    }
    return Left(_extractError(result.left));
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────

  Future<Either<String, SharedVerifyOtpModel>> verifyOtp({
    required String phone,
    required String code,
    required VendorType vendor,
  }) async {
    final result = await _adapter.post(
      _AuthEndpoints.verifyOtp(vendor),
      body: {
        'phone': '+966$phone',
        'code': code,
      },
    );
    if (result.isRight) {
      final model = SharedVerifyOtpModel.fromJson(result.right.data);



      // Persist token so completion features can read it without re-auth.
       _cache.registerToken = model.accessToken;
       await _cache.setUserToken(model.accessToken) ;
      return Right(model);
    }
    return Left(_extractError(result.left));
  }

  // ── Resend OTP (re-fires register or login depending on flow) ─────────────

  Future<Either<String, SharedOtpSentModel>> resendOtp({
    required String phone,
    required VendorType vendor,
    required bool isRegister,
  }) async {
    final result = isRegister
        ? await _adapter.post(
      _AuthEndpoints.register(vendor),
      body: {'phone': '+966$phone'},
    )
        : await _adapter.post(
      _AuthEndpoints.login(vendor),
      body: {'phone': '+966$phone'},
    );

    if (result.isRight) {

      return Right(SharedOtpSentModel.fromJson(result.right.data));
    }
    return Left(_extractError(result.left));
  }

  // ── Error helper ──────────────────────────────────────────────────────────

  String _extractError(dynamic left) {
    try {
      if (left is DioException) {
        final data = left.response?.data;
        if (data is Map) {
          return data['message']?.toString() ??
              data['error']?['details']?.toString() ??
              'حدث خطأ غير متوقع';
        }
      }
      return left.toString();
    } catch (_) {
      return 'حدث خطأ غير متوقع';
    }
  }
}