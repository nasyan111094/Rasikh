import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';

import '../../../../config/app_config.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/models/user_model.dart';

import '../../../../core/utils/api/api_handler.dart';
import '../models/update_profile_parameters.dart';
import '../models/user_model.dart';

class ProfileRepo {
  ProfileRepo();

  final DioAdapterBase _dio = getIt.get<ApiHandler>().dioAdapterBase;

  // ── GET /api/v1/clients/profile ───────────────────────────────────────────

  Future<Either<String, UserProfileData>> fetchProfile() async {
    final result = await _dio.get(
      EndPoints.profileDataWithDataBase, // 'clients/profile'
    );

    if (result.isRight) {
      final data = UserModel.fromJson(result.right.data).data;
      return Right(data);
    }
    return Left(result.left.toString());
  }

  // ── PUT /api/v1/clients/profile ───────────────────────────────────────────
  // Always multipart/form-data (avatar is optional).
  // Fields expected by the API: fullName, email, city, avatar (binary).

  Future<Either<String, UserProfileData>> updateProfile(
      UpdateProfileParam params,
      ) async {
    final fields = <String, dynamic>{
      'fullName': params.fullName,
      'email': params.email,
      'city': params.city,
    };

    if (params.avatar != null && params.avatar is File) {
      fields['avatar'] = await MultipartFile.fromFile(
        params.avatar!.path,
        filename: 'avatar.jpg',
      );
    }

    final body = FormData.fromMap(fields);

    final result = await _dio.put(
      EndPoints.updateProfileWithDataBase, // 'clients/profile'
      body: body,
    );

    if (result.isRight) {
      final data = UserModel.fromJson(result.right.data).data;
      return Right(data);
    }
    return Left(result.left.toString());
  }
}