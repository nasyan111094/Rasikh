// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/profile/data/repos/lawyer_profile_repo.dart
//
// Handles all lawyer profile endpoints:
//   GET  /api/v1/lawyers/me                          → fetch profile
//   PUT  /api/v1/lawyers/update/form                 → update profile (multipart)
//   PUT  /api/v1/lawyers/update/form                 → update specializations
//   POST /api/v1/lawyers/change-phone/request        → request phone change OTP
//   POST /api/v1/lawyers/change-phone/verify         → verify phone change OTP
//   POST /api/v1/lawyers/account/deletion/otp        → send deletion OTP
//   POST /api/v1/lawyers/account/deletion/request    → confirm account deletion
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';

import '../../../../../../core/cache/cache_helper.dart';
import '../../../../../../core/get_it_service/get_it_service.dart';
import '../../../../../../core/utils/api/api_handler.dart';
import '../models/lawyer_profile_model.dart';

// ── Endpoint constants ────────────────────────────────────────────────────────

class _ProfileEndpoints {
  static const String me = 'lawyers/me';
  static const String update = 'lawyers/update/form';
  static const String changePhoneRequest = 'lawyers/change-phone/request';
  static const String changePhoneVerify = 'lawyers/change-phone/verify';
  static const String deletionOtp = 'lawyers/account/deletion/otp';
  static const String deletionRequest = 'lawyers/account/deletion/request';
}

// ── Repository ────────────────────────────────────────────────────────────────

class LawyerProfileRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;
  CacheHelper get _cache => getIt<CacheHelper>();

  // ── GET profile ────────────────────────────────────────────────────────────

  Future<Either<String, LawyerProfileModel>> getProfile() async {
    final result = await _adapter.get(_ProfileEndpoints.me);
    if (result.isRight) {
      final data = result.right.data['data'] ?? result.right.data;
      return Right(LawyerProfileModel.fromJson(data));
    }
    return Left(_extractError(result.left));
  }

  // ── UPDATE profile (multipart/form-data) ───────────────────────────────────

  Future<Either<String, LawyerProfileModel>> updateProfile({
    required UpdateProfileRequest request,
    File? photo,
  }) async {
    final formData = FormData.fromMap({
      ...request.toFormFields(),
      if (photo != null)
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: photo.path.split('/').last,
        ),
    });

    final result = await _adapter.put(
      _ProfileEndpoints.update,
      body: formData,
    );

    if (result.isRight) {
      return getProfile();
    }
    return Left(_extractError(result.left));
  }

  // ── UPDATE specializations (multipart/form-data) ───────────────────────────
  //
  // Sends only the specialization fields:
  //   mainSpecializations  → JSON-encoded array of main spec IDs
  //   subSpecializations   → JSON-encoded array of sub  spec IDs
  //
  // Returns the refreshed profile so the cubit can cache it.

  Future<Either<String, LawyerProfileModel>> updateSpecializations({
    required List<String> mainSpecializationIds,
    required List<String> subSpecializationIds,
  }) async {
    final formData = FormData.fromMap({
      'mainSpecializations': jsonEncode(mainSpecializationIds),
      'subSpecializations': jsonEncode(subSpecializationIds),
    });

    final result = await _adapter.put(
      _ProfileEndpoints.update,
      body: formData,
    );

    if (result.isRight) {
      // Re-fetch the full profile so callers always get the canonical model.
      return getProfile();
    }
    return Left(_extractError(result.left));
  }

  // ── UPDATE licence (multipart/form-data) ───────────────────────────────────

  Future<Either<String, LawyerProfileModel>> updateLicence({
    required UpdateLicenceRequest request,
    File? licenseImage,
    File? nationalIdDocument,
    File? commercialRegistrationDocument,
  }) async {
    final fields = <String, dynamic>{
      ...request.toFormFields(),
    };

    if (licenseImage != null) {
      fields['licenseImage'] = await MultipartFile.fromFile(
        licenseImage.path,
        filename: licenseImage.path.split('/').last,
      );
    }
    if (nationalIdDocument != null) {
      fields['nationalIdDocument'] = await MultipartFile.fromFile(
        nationalIdDocument.path,
        filename: nationalIdDocument.path.split('/').last,
      );
    }
    if (commercialRegistrationDocument != null) {
      fields['commercialRegistrationDocument'] =
      await MultipartFile.fromFile(
        commercialRegistrationDocument.path,
        filename: commercialRegistrationDocument.path.split('/').last,
      );
    }

    final formData = FormData.fromMap(fields);

    final result = await _adapter.put(
      _ProfileEndpoints.update,
      body: formData,
    );

    if (result.isRight) {
      return Right(LawyerProfileModel.fromJson(result.right.data));
    }
    return Left(_extractError(result.left));
  }

  // ── REQUEST phone change OTP ───────────────────────────────────────────────

  Future<Either<String, String>> requestPhoneChange({
    required String phone,
  }) async {
    final result = await _adapter.post(
      _ProfileEndpoints.changePhoneRequest,
      body: ChangePhoneRequestModel(phone: phone).toJson(),
    );

    if (result.isRight) {
      final data = result.right.data;
      final message = data['message']?.toString() ??
          'تم إرسال كود التحقق إلى رقم الهاتف';
      return Right(message);
    }
    return Left(_extractError(result.left));
  }

  // ── VERIFY phone change OTP ────────────────────────────────────────────────

  Future<Either<String, ChangePhoneResponseModel>> verifyPhoneChange({
    required String phone,
    required String code,
  }) async {
    final result = await _adapter.post(
      _ProfileEndpoints.changePhoneVerify,
      body: ChangePhoneVerifyModel(phone: phone, code: code).toJson(),
    );

    if (result.isRight) {
      return Right(ChangePhoneResponseModel.fromJson(result.right.data));
    }
    return Left(_extractError(result.left));
  }

  // ── SEND account deletion OTP ──────────────────────────────────────────────

  Future<Either<String, String>> sendDeletionOtp() async {
    final result = await _adapter.post(_ProfileEndpoints.deletionOtp);

    if (result.isRight) {
      final data = result.right.data;
      final phone = data['data']?['phone']?.toString() ?? '';
      return Right(phone);
    }
    return Left(_extractError(result.left));
  }

  // ── CONFIRM account deletion ───────────────────────────────────────────────

  Future<Either<String, DeleteAccountResponseModel>> requestAccountDeletion({
    required String otp,
  }) async {
    final result = await _adapter.post(
      _ProfileEndpoints.deletionRequest,
      body: DeleteAccountRequestBody(otp: otp).toJson(),
    );

    if (result.isRight) {
      return Right(
        DeleteAccountResponseModel.fromJson(result.right.data),
      );
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