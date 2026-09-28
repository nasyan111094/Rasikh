// ─────────────────────────────────────────────────────────────────────────────
// features/common/app_version/repo/app_version_repo.dart
//
// Public endpoint (no auth required):
//   GET /api/app-version/check?appType=android|ios&version=X.Y.Z
// NOTE: lives under /api/ (not /api/v1/), so an absolute URL is used.
// ─────────────────────────────────────────────────────────────────────────────

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

  /// Current platform key expected by the API.
  String get currentAppType {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'android';
  }

  /// Installed semantic version (e.g. 1.0.0).
  Future<String> getInstalledVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  /// Calls the check endpoint for the currently installed app version.
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
        return const Left('تعذر قراءة نتيجة فحص الإصدار');
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
              'حدث خطأ غير متوقع';
        }
      }
      return left.toString();
    } catch (_) {
      return 'حدث خطأ غير متوقع';
    }
  }
}
