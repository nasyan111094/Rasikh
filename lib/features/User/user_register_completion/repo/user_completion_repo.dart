// ─────────────────────────────────────────────────────────────────────────────
// user_completion/repo/user_completion_repo.dart
//
// The API contract for PUT /clients/complete-profile sends the Arabic city
// display-name directly in the "city" field — there is no separate numeric key.
//
// Example body:
// {
//   "fullName":      "أحمد محمد السعيد",
//   "email":         "client@example.com",
//   "city":          "الرياض",          ← display value, NOT a numeric key
//   "acceptedTerms": true
// }
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dio_adapter/dio_adapter.dart';

import '../../../../Shared/models/city_model.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/utils/api/api_handler.dart';
import '../model/user_completion_model.dart';

class UserCompletionRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;

  static const String _cities      = 'enums/cities';
  static const String _profileForm = 'clients/complete-profile';

  // ── Cities ────────────────────────────────────────────────────────────────

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

  // ── Complete profile ──────────────────────────────────────────────────────

  /// [cityDisplayValue] is the Arabic city name exactly as returned by
  /// the /enums/cities endpoint (e.g. "الرياض").  The API does NOT accept
  /// a numeric key — it expects the human-readable value.
  Future<Either<String, UserProfileModel>> completeProfile({
    required String fullName,
    required String email,
    required String cityDisplayValue,
  }) async {
    final result = await _adapter.put(
      _profileForm,
      body: {
        'fullName':      fullName,
        'email':         email,
        'city':          cityDisplayValue, // ← send the display value directly
        'acceptedTerms': true,
      },
    );
    if (result.isRight) {
      return Right(UserProfileModel.fromJson(result.right.data));
    }
    return Left(result.left.toString());
  }
}