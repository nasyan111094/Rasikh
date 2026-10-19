
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';

import '../../../../core/cache/cache_helper.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/utils/api/api_handler.dart';
import '../../../../features/Lawyer/lawyer_Settings/bloc/Profile_cubit/lawyer_cubit.dart';
import '../../../../features/User/profile/cubit/profile_cubit.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';


class _AuthEndpoints {
  static String register(VendorType v)   => '${_prefix(v)}/register';
  static String login(VendorType v)      => '${_prefix(v)}/login';
  static String verifyOtp(VendorType v)  => '${_prefix(v)}/verify-otp';
  static String resendOtp(VendorType v)  => '${_prefix(v)}/resend-otp';
  static String refresh(VendorType v)    => '${_prefix(v)}/refresh';

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


  Future<Either<String, SharedOtpSentModel>> register({
    required String phone,
    required VendorType vendor,
  }) async {
    final result = await _adapter.post(
      _AuthEndpoints.register(vendor),
      body: {'phone': normalizeSaudiPhone(phone)},
    );
    if (result.isRight) {
      return Right(SharedOtpSentModel.fromJson(result.right.data));
    }
    return Left(_extractError(result.left));
  }


  Future<Either<String, SharedOtpSentModel>> login({
    required String phone,
    required VendorType vendor,
  }) async {
    final result = await _adapter.post(
      _AuthEndpoints.login(vendor),
      body: {'phone': normalizeSaudiPhone(phone)},
    );
    if (result.isRight) {




      return Right(SharedOtpSentModel.fromJson(result.right.data));
    }
    return Left(_extractError(result.left));
  }


  Future<Either<String, SharedVerifyOtpModel>> verifyOtp({
    required String phone,
    required String code,
    required VendorType vendor,
  }) async {
    final result = await _adapter.post(
      _AuthEndpoints.verifyOtp(vendor),
      body: {
        'phone': normalizeSaudiPhone(phone),
        'code': code,
      },
    );
    if (result.isRight) {
      final model = SharedVerifyOtpModel.fromJson(result.right.data);

      _cache.currentUser = null;
      
      if (getIt.isRegistered<LawyerProfileCubit>()) {
        try {
          getIt<LawyerProfileCubit>().cachedProfile = null;
        } catch (e) {
        }
      }
      
      if (getIt.isRegistered<ProfileCubit>()) {
        try {
          getIt<ProfileCubit>().emit(const ProfileState());
        } catch (e) {
        }
      }
      
      _cache.registerToken = model.accessToken;

      // Only promote to a full session when the profile is already
      // completed (login flow). During registration the token stays in
      // registerToken until completeProfile finishes (it authenticates
      // via the registerToken fallback in ApiHandler).
      final profileCompleted = switch (vendor) {
        VendorType.user => model.client.profileCompleted,
        VendorType.lawyer => model.lawyer.profileCompleted,
        // Verify-OTP response carries no company snapshot; fall back to
        // the client snapshot. TODO: use a dedicated company flag.
        VendorType.company => model.client.profileCompleted,
      };
      if (profileCompleted) {
        await _cache.setUserToken(model.accessToken);
      }
      // Refresh token is valid in both flows; keep it whenever present so
      // a fresh registrant can still refresh after completeProfile
      // promotes the access token below.
      if (model.refreshToken.isNotEmpty) {
        await _cache.setRefreshToken(model.refreshToken);
      }
      
      await _cache.setCurrentVendorType(vendor);
      
      return Right(model);
    }
    return Left(_extractError(result.left));
  }


  Future<Either<String, SharedOtpSentModel>> resendOtp({
    required String phone,
    required VendorType vendor,
    required bool isRegister,
  }) async {
    final result = isRegister
        ? await _adapter.post(
      _AuthEndpoints.register(vendor),
      body: {'phone': normalizeSaudiPhone(phone)},
    )
        : await _adapter.post(
      _AuthEndpoints.login(vendor),
      body: {'phone': normalizeSaudiPhone(phone)},
    );

    if (result.isRight) {

      return Right(SharedOtpSentModel.fromJson(result.right.data));
    }
    return Left(_extractError(result.left));
  }


  String _extractError(dynamic left) {
    try {
      if (left is DioException) {
        final data = left.response?.data;
        if (data is Map) {
          return data['message']?.toString() ??
              data['error']?['details']?.toString() ??
              Loc.unexpectedError();
        }
      }
      return left.toString();
    } catch (_) {
      return Loc.unexpectedError();
    }
  }


  Future<Either<String, SharedRefreshTokenModel>> refreshToken({
    required String refreshToken,
    required VendorType vendor,
  }) async {
    final result = await _adapter.post(
      _AuthEndpoints.refresh(vendor),
      body: {'refreshToken': refreshToken},
    );
    if (result.isRight) {
      return Right(SharedRefreshTokenModel.fromJson(result.right.data));
    }
    return Left(_extractError(result.left));
  }
}

/// Normalizes a Saudi phone number to E.164 (`+966XXXXXXXXX`).
///
/// Strips any pre-existing `+966`/`966` prefix, whitespace/dashes and a
/// leading `0`, so passing an already-prefixed number never produces a
/// duplicate prefix. The server expects the `+966` prefix (all OTP
/// endpoints historically sent `'+966$phone'`).
String normalizeSaudiPhone(String phone) {
  var digits = phone.trim().replaceAll(RegExp(r'[\s\-()]'), '');
  if (digits.startsWith('+')) digits = digits.substring(1);
  if (digits.startsWith('00966')) {
    digits = digits.substring(5);
  } else if (digits.startsWith('966')) {
    digits = digits.substring(3);
  }
  if (digits.startsWith('0')) digits = digits.substring(1);
  digits = digits.replaceAll(RegExp(r'[^0-9]'), '');
  return '+966$digits';
}
