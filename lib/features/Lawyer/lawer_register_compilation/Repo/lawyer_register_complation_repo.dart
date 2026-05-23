// ─────────────────────────────────────────────────────────────────────────────
// lawyer_completion/repo/lawyer_completion_repo.dart
//
// Handles:
//   GET  /api/v1/enums/cities                  – city dropdown data
//   GET  /api/v1/specializations/active         – specialization list
//   PUT  /api/v1/lawyers/profile/form           – multipart profile submission
//
// The PUT uses raw Dio (bypassing the shared interceptor) because the
// interceptor's token-refresh logic is wired for the user flow only.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';


import '../../../../Shared/models/city_model.dart';
import '../../../../config/app_config.dart';
import '../../../../core/cache/cache_helper.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/utils/api/api_handler.dart';
import '../models/lawyer_registeration_complation_model.dart';

class LawyerCompletionRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;
  CacheHelper get _cache => getIt<CacheHelper>();

  // ── Endpoint constants ────────────────────────────────────────────────────
  static const String _cities            = 'enums/cities';
  static const String _specializations   = 'specializations/active';
  static const String _profileForm       = 'lawyers/profile/form';

  // ══════════════════════════════════════════════════════════════════════════
  // Cities
  // ══════════════════════════════════════════════════════════════════════════

  Future<Either<String, List<CityEnumModel>>> getCities() async {
    final result = await _adapter.get(_cities);
    if (result.isRight) {
      final list = result.right.data['data'] as List<dynamic>? ?? [];
      return Right(
        list
            .map((e) => CityEnumModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    return Left(result.left.toString());
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Active specializations
  // ══════════════════════════════════════════════════════════════════════════

  Future<Either<String, List<SpecializationModel>>> getSpecializations({
    int    page  = 1,
    int    limit = 50,
    String? search,
  }) async {
    final result = await _adapter.get(
      _specializations,
      queryParameters: {
        'page':  page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    if (result.isRight) {
      final list = result.right.data['data'] as List<dynamic>? ?? [];
      return Right(
        list
            .map((e) =>
            SpecializationModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    return Left(result.left.toString());
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Submit profile (multipart) – raw Dio to bypass user interceptor
  // ══════════════════════════════════════════════════════════════════════════

  Future<Either<String, LawyerProfileCompletionModel>> completeProfile({
    required LawyerRegistrationFormData formData,
  }) async {
    final token =_cache.registerToken;


    if (token == null || token.isEmpty) {
      return const Left(
          'لم يتم العثور على رمز المصادقة، يرجى تسجيل الدخول مجدداً');
    }


      final fields = formData.toFormFields();
      final parts  = <String, dynamic>{...fields};

      if (formData.photo != null) {
        parts['photo'] = await MultipartFile.fromFile(
          formData.photo!.path,
          filename: 'photo.jpg',
        );
      }
      if (formData.licenseImage != null) {
        parts['licenseImage'] = await MultipartFile.fromFile(
          formData.licenseImage!.path,
          filename: 'license.jpg',
        );
      }
      if (formData.nationalIdDocument != null) {
        parts['nationalIdDocument'] = await MultipartFile.fromFile(
          formData.nationalIdDocument!.path,
          filename: 'national_id.jpg',
        );
      }
      if (formData.commercialRegistrationDocument != null &&
          formData.isCompany) {
        parts['commercialRegistrationDocument'] =
        await MultipartFile.fromFile(
          formData.commercialRegistrationDocument!.path,
          filename: 'commercial_reg.jpg',
        );
      }


      final response = await _adapter.put(
        '${AppConfig.baseUrl}$_profileForm',
        body: FormData.fromMap(parts),

      );


      if (response.isRight) {
        _cache.registerToken = null ;
        return Right(LawyerProfileCompletionModel.fromJson(response.right.data));
      }
      return  Left(response.left);

  }
}