
import 'package:rasikh/config/localization/loc_keys.dart';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:rasikh/config/app_config.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/api/api_handler.dart';

import '../models/app_version_model.dart';

class AppVersionRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;

  static String get _checkUrl => '${AppConfig.baseApiUrl}app-version/check';

  String get currentAppType {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'android';
  }

  Future<String> getInstalledVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  Future<Either<String, AppVersionCheck>> checkCurrentVersion() async {
    try {
      final version = await getInstalledVersion();
      return await check(appType: currentAppType, version: version);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, AppVersionCheck>> check({
    required String appType,
    required String version,
  }) async {
    final result = await _adapter.get(
      _checkUrl,
      queryParameters: {
        'appType': appType,
        'version': version,
      },
    );

    if (result.isRight) {
      try {
        return Right(AppVersionCheck.fromJson(result.right.data));
      } catch (_) {
        return Left(Loc.versionCheckReadFailed());
      }
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
