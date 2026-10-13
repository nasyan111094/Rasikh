// ─────────────────────────────────────────────────────────────────────────────
// company_completion/repo/company_completion_repo.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dio_adapter/dio_adapter.dart';


import '../../../../core/cache/cache_helper.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/utils/api/api_handler.dart';
import '../model/company_completion_model.dart';

class CompanyCompletionRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;

  // TODO: replace with your real company profile endpoint.
  static const String _profileEndpoint = 'companies/profile/form';

  Future<Either<String, CompanyProfileModel>> completeProfile({
    required String companyName,
    required String commercialRegNumber,
    required String email,
    required String representativeName,
  }) async {
    final result = await _adapter.put(
      _profileEndpoint,
      body: {
        'companyName':          companyName,
        'commercialRegNumber':  commercialRegNumber,
        'email':                email,
        'representativeName':   representativeName,
      },
    );
    if (result.isRight) {
      // Promote the registration token to a full session (verifyOtp keeps
      // it in registerToken until the profile is completed).
      final cache = getIt<CacheHelper>();
      final pending = cache.registerToken;
      if (pending != null && pending.isNotEmpty) {
        await cache.setUserToken(pending);
        cache.registerToken = null;
      }
      return Right(CompanyProfileModel.fromJson(result.right.data));
    }
    return Left(result.left.toString());
  }
}