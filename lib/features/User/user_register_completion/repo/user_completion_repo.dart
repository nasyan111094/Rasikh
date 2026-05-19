// ─────────────────────────────────────────────────────────────────────────────
// user_completion/repo/user_completion_repo.dart
//
// Handles the user (non-lawyer) profile-completion API call.
// Replace the stub endpoint and body with your real user API contract.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dio_adapter/dio_adapter.dart';


import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/utils/api/api_handler.dart';
import '../model/user_completion_model.dart';

class UserCompletionRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;

  // TODO: replace with your real user profile endpoint.
  static const String _profileEndpoint = 'users/profile/form';

  Future<Either<String, UserProfileModel>> completeProfile({
    required String fullName,
    required String email,
  }) async {
    final result = await _adapter.put(
      _profileEndpoint,
      body: {
        'fullName': fullName,
        'email':    email,
      },
    );
    if (result.isRight) {
      return Right(UserProfileModel.fromJson(result.right.data));
    }
    return Left(result.left.toString());
  }
}