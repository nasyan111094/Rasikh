
import 'package:rasikh/config/localization/loc_keys.dart';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';
import 'package:flutter/cupertino.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';

import '../../../../../../core/cache/cache_helper.dart';
import '../../../../../../core/get_it_service/get_it_service.dart';
import '../../../../../../core/utils/api/api_handler.dart';
import '../models/lawyer_profile_model.dart';


class _ProfileEndpoints {
  static const String me = 'lawyers/me';
  static const String update = 'lawyers/update/form';
  static const String lawyerchangePhoneRequest = 'lawyers/change-phone/request';
  static const String clientchangePhoneRequest = 'clients/change-phone/request';
  static const String lawyerchangePhoneVerify = 'lawyers/change-phone/verify';
  static const String clientchangePhoneVerify = 'clients/change-phone/verify';
  static const String lawyerdeletionOtp = 'lawyers/account/deletion/otp';
  static const String clientdeletionOtp = 'clients/account/deletion/otp';
  static const String lawyerdeletionRequest = 'lawyers/account/deletion/request';
  static const String clientdeletionRequest = 'clients/account/deletion/request';
}


class LawyerProfileRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;
  CacheHelper get _cache => getIt<CacheHelper>();


  Future<Either<String, LawyerProfileModel>> getProfile() async {
    final result = await _adapter.get(_ProfileEndpoints.me);
    if (result.isRight) {
      final data = result.right.data['data'] ?? result.right.data;
      return Right(LawyerProfileModel.fromJson(data));
    }
    return Left(_extractError(result.left));
  }


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


  Future<Either<String, LawyerProfileModel>> updateSpecializations({
    required List<String> mainSpecializationIds,
    required List<String> subSpecializationIds,
  }) async {
    final formData = FormData();

    for (final id in mainSpecializationIds) {
      formData.fields.add(
        MapEntry('mainSpecializations[]', id),
      );
    }

    for (final id in subSpecializationIds) {
      formData.fields.add(
        MapEntry('subSpecializations[]', id),
      );
    }

    debugPrint('========== FormData ==========');
    for (final field in formData.fields) {
      debugPrint('${field.key}: ${field.value}');
    }

    if (formData.files.isNotEmpty) {
      for (final file in formData.files) {
        debugPrint('${file.key}: ${file.value.filename}');
      }
    }
    debugPrint('==============================');

    final result = await _adapter.put(
      _ProfileEndpoints.update,
      body: formData,
    );

    if (result.isRight) {
      return getProfile();
    }

    return Left(_extractError(result.left));
  }


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


  Future<Either<String, String>> requestPhoneChange({
    required String phone,
  }) async {
    final result = await _adapter.post(
     _cache.cachedVendorType == VendorType.lawyer ? _ProfileEndpoints.lawyerchangePhoneRequest : _ProfileEndpoints.clientchangePhoneRequest,
      body: ChangePhoneRequestModel(phone: phone).toJson(),
    );

    if (result.isRight) {
      final data = result.right.data;
      final message = data['message']?.toString() ??
          Loc.verificationCodeSentToPhone();
      return Right(message);
    }
    return Left(_extractError(result.left));
  }


  Future<Either<String, ChangePhoneResponseModel>> verifyPhoneChange({
    required String phone,
    required String code,
  }) async {
    final result = await _adapter.post(
      _cache.cachedVendorType == VendorType.lawyer ? _ProfileEndpoints.lawyerchangePhoneVerify : _ProfileEndpoints.clientchangePhoneVerify,
      body: ChangePhoneVerifyModel(phone: phone, code: code).toJson(),
    );

    if (result.isRight) {
      return Right(ChangePhoneResponseModel.fromJson(result.right.data));
    }
    return Left(_extractError(result.left));
  }


  Future<Either<String, String>> sendDeletionOtp() async {
    final result = await _adapter.post( _cache.cachedVendorType == VendorType.lawyer ?_ProfileEndpoints.lawyerdeletionOtp:_ProfileEndpoints.clientdeletionOtp);

    if (result.isRight) {
      final data = result.right.data;
      final phone = data['data']?['phone']?.toString() ?? '';
      return Right(phone);
    }
    return Left(_extractError(result.left));
  }


  Future<Either<String, DeleteAccountResponseModel>> requestAccountDeletion({
    required String otp,
  }) async {
    final result = await _adapter.post(
      _cache.cachedVendorType == VendorType.lawyer ? _ProfileEndpoints.lawyerdeletionRequest:_ProfileEndpoints.clientdeletionRequest,
      body: DeleteAccountRequestBody(otp: otp).toJson(),
    );

    if (result.isRight) {
      return Right(
        DeleteAccountResponseModel.fromJson(result.right.data),
      );
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
}