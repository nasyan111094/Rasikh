import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:rasikh/config/app_config.dart';
import 'package:rasikh/config/localization/lang_repo.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/services/app_logger.dart';
import 'package:rasikh/features/common/Auth/repo/auth_repo.dart';

import '../../../config/navigation/nav.dart';
import '../../../features/common/account_type_selection/screens/account_type_screen.dart';
import '../../cache/pref_keys.dart';

class ApiHandler {
  ApiHandler() {
    _adapterBase = _apiConfig();
  }

  DioAdapterBase? _adapterBase;
  DioAdapterBase get dioAdapterBase => _adapterBase!;

  // ── Centralized session/refresh orchestration ─────────────────────────────
  // Single-flight: concurrent 401s share ONE refresh call instead of firing N.
  static Future<bool>? _refreshFuture;

  // Guards the forced-logout navigation so stacked 401s navigate only once.
  static bool _logoutNavigated = false;

  DioAdapterBase _apiConfig() {
    return DioAdapterBase(

      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      responseTypeEnum: ResponseTypeEnum.json,
      customRequestHandler: _customRequestHandler,
      customResponseHandler: _customResponseHandler,
      customErrorHandler: _customErrorHandler,
      contentTypeEnum: ContentTypeEnum.applicationJson,
    );
  }

  Future<RequestOptions> _customRequestHandler(
      RequestOptions options, _) async {

    final cacheHelper = getIt<CacheHelper>();
    String? token = getIt<CacheHelper>().registerToken ??  getIt<CacheHelper>().currentToken;

    if (options.path == EndPoints.updateProfileWithDataBase) {
      options.contentType = 'multipart/form-data';
    }

    // Always send Accept-Language: ar for all requests
    if (token == null) {
      options.headers.addAll({'Accept-Language': 'ar'});
    } else {
      options.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      });
    }
    return options;
  }

  Future<Response> _customResponseHandler(response, _) async {
    return response;
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Central error interceptor — single entry point for EVERY request/response.
  //
  // 401 → always treated as expired session: single-flight refresh, then the
  //        original request is retried once with the new token.
  // 400 → refresh ONLY when the body carries an auth signal (expired/invalid
  //        token, unauthorized...). Plain validation 400s must NOT trigger a
  //        refresh, otherwise every form error would log the user out.
  // Refresh failure (or nothing to refresh with) → wipe all cached data and
  // navigate to AccountTypeScreen removing every route.
  // ═════════════════════════════════════════════════════════════════════════

  Future<DioException> _customErrorHandler(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldAttemptRefresh(error)) {
      final retried = await _refreshAndRetry(error.requestOptions);
      if (retried != null) {
        handler.resolve(retried);
        return error;
      }
      await _forceLogout(handler, error);
      return error;
    }

    handler.reject(_cleanError(error));
    return error;
  }

  // ── Should this failure enter the refresh flow? ───────────────────────────

  bool _shouldAttemptRefresh(DioException error) {
    // Never intercept the auth endpoints themselves (login/register/OTP/
    // refresh) — a 401 there means wrong credentials, not an expired session,
    // and intercepting refresh would loop forever.
    if (_isAuthEndpoint(error.requestOptions.path)) return false;

    // Only requests that actually sent credentials participate. Public calls
    // (or logged-out users) are rejected untouched — never wipe their cache.
    final sentAuth =
        error.requestOptions.headers['Authorization']?.toString().isNotEmpty ==
            true;
    if (!sentAuth) return false;

    final status = error.response?.statusCode;
    if (status == 401) return true;
    if (status == 400) return _looksLikeAuthError(error.response?.data);
    return false;
  }

  bool _isAuthEndpoint(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('/refresh')) return true;
    const markers = [
      '/login',
      '/register',
      '/verify-otp',
      '/resend-otp',
      '/confirm-login',
      '/confirm-register',
      '/initialize-otp',
      'user-management/refresh-token',
    ];
    for (final m in markers) {
      if (p.contains(m)) return true;
    }
    return false;
  }

  /// A 400 counts as auth-related only when its payload says so.
  bool _looksLikeAuthError(dynamic data) {
    final buffer = StringBuffer();
    void collect(dynamic value) {
      if (value == null) return;
      if (value is String) {
        buffer.write(value);
        buffer.write(' ');
      } else if (value is Map) {
        value.values.forEach(collect);
      } else if (value is List) {
        value.forEach(collect);
      }
    }

    collect(data);
    final text = buffer.toString().toLowerCase();

    const signals = [
      'token',
      'unauthor',
      'unauthen',
      'expired',
      'session',
      'authenticate',
      'login again',
      // Arabic backend messages
      'انتهت',
      'منتهي',
      'تسجيل الدخول',
      'غير مصرح',
      'غير مسموح',
      'رمز',
      'الجلسة',
    ];
    for (final s in signals) {
      if (text.contains(s)) return true;
    }
    return false;
  }

  // ── Single-flight refresh + one retry of the failed request ───────────────

  Future<Response?> _refreshAndRetry(RequestOptions failedRequest) async {
    final future = _refreshFuture ??= _performRefresh();
    bool refreshed = false;
    try {
      refreshed = await future;
    } catch (_) {
      refreshed = false;
    } finally {
      if (identical(_refreshFuture, future)) _refreshFuture = null;
    }

    if (!refreshed) return null;

    String? newToken;
    try {
      newToken = await getIt.get<CacheHelper>().getUserToken();
    } catch (_) {
      return null;
    }
    if (newToken == null || newToken.isEmpty) return null;

    failedRequest.headers['Authorization'] = 'Bearer $newToken';
    failedRequest.headers['Accept-Language'] = 'ar';

    try {
      return await _retryRequest(failedRequest)
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      return null;
    }
  }

  /// Returns true when fresh tokens were obtained AND persisted.
  Future<bool> _performRefresh() async {
    try {
      final cacheHelper = getIt.get<CacheHelper>();
      final refreshToken = await cacheHelper.getRefreshToken();
      final vendorType = await cacheHelper.getCachedVendorType();
      if (refreshToken == null ||
          refreshToken.isEmpty ||
          vendorType == null) {
        return false;
      }

      final refreshEither = await GeneralAuthRepo()
          .refreshToken(refreshToken: refreshToken, vendor: vendorType)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Token refresh timeout'),
          );

      return await refreshEither.fold(
        (_) async => false,
        (tokens) async {
          if (tokens.accessToken.isEmpty) return false;
          await cacheHelper.setUserToken(tokens.accessToken);
          if (tokens.refreshToken.isNotEmpty) {
            await cacheHelper.setRefreshToken(tokens.refreshToken);
          }
          Logger().i('Access token refreshed — retrying queued requests');
          return true;
        },
      );
    } catch (e) {
      Logger().e('Token refresh failed: $e');
      return false;
    }
  }

  // ── Unrecoverable session: wipe everything + hard reset navigation ────────

  Future<void> _forceLogout(
    ErrorInterceptorHandler handler,
    DioException error,
  ) async {
    try {
      await getIt<CacheHelper>().clearAllData();
    } catch (_) {
      // Storage must never block the logout navigation.
    }

    if (!_logoutNavigated) {
      _logoutNavigated = true;
      try {
        await Nav.mainNavKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const AccountTypeScreen(),
          ),
          (route) => false,
        );
      } catch (_) {
        // Navigator may be unavailable (background isolate, tests).
      }
      // Re-arm for the next login session.
      Future.delayed(
        const Duration(seconds: 2),
        () => _logoutNavigated = false,
      );
    }

    handler.reject(DioException(
      message: 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى',
      requestOptions: error.requestOptions,
      response: error.response,
      type: DioExceptionType.badResponse,
    ));
  }

  // ── Plain (non-auth) failures: clean, user-readable message ───────────────

  DioException _cleanError(DioException error) {
    String? errorMessage;
    final data = error.response?.data;
    if (data is Map) {
      errorMessage = data['message']?.toString();
    } else if (data is String && data.isNotEmpty) {
      errorMessage = data;
    }
    if (errorMessage != null) AppLogger.info(errorMessage);
    return DioException(
      message: errorMessage ?? error.message?.toString() ?? 'An error occurred',
      error: error.error,
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      stackTrace: error.stackTrace,
    );
  }

  // Helper method to retry the original request
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final dio = Dio();
    dio.options.baseUrl = AppConfig.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    // Create a new request with the updated options
    return await dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        contentType: requestOptions.contentType,
        responseType: requestOptions.responseType,
        followRedirects: requestOptions.followRedirects,
        maxRedirects: requestOptions.maxRedirects,
        receiveTimeout: requestOptions.receiveTimeout,
        sendTimeout: requestOptions.sendTimeout,
      ),
    );
  }
}