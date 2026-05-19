import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';

import '../../../../config/app_config.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/paramaters/update_profile_parameters.dart';
import '../../../../core/utils/api/api_handler.dart';

class ProfileRepo {
  ProfileRepo();

  final DioAdapterBase _dio = getIt.get<ApiHandler>().dioAdapterBase;

  Future<Either<String, UserProfileData>> fetchProfile() async {
    final result = await _dio.get(
      EndPoints.profileDataWithDataBase,
    );

    if (result.isRight) {
      final data = UserProfileModel.fromJson(result.right.data).data;
      return Right(data);
    } else {
      return Left(result.left.toString());
    }
  }

  Future<Either<String, UserProfileData>> updateProfile(
      UpdateProfileParam params,
      ) async {
    dynamic body;

    // Build multipart form if file present; ApiHandler switches content-type automatically
    if (params.file != null && params.file is File) {
      body = FormData.fromMap({
        if (params.name != null) 'fullName': params.name,
        if (params.email != null) 'email': params.email,
        if (params.phone != null) 'phoneNumber': params.phone,
        if (params.nationalId != null) 'nationalId': params.nationalId,
        if (params.nationalityId != null) 'nationalityId': params.nationalityId,
        if (params.gender != null) 'gender': params.gender,
        'image': await MultipartFile.fromFile(params.file!.path),
      });
    } else {
      body = {
        if (params.name != null) 'fullName': params.name,
        if (params.email != null) 'email': params.email,
        if (params.phone != null) 'phoneNumber': params.phone,
        if (params.nationalId != null) 'nationalId': params.nationalId,
        if (params.nationalityId != null) 'nationalityId': params.nationalityId,
        if (params.gender != null) 'gender': params.gender,
      };
    }

    final result = await _dio.post(
      EndPoints.updateProfileWithDataBase,
      body: body,
    );

    if (result.isRight) {
      final data = UserProfileModel.fromJson(result.right.data).data;
      return Right(data);
    } else {
      return Left(result.left.toString());
    }
  }
}