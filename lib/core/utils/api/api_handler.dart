import 'package:rasikh/config/localization/loc_keys.dart';
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

  static Future<bool>? _refreshFuture;

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


  bool _shouldAttemptRefresh(DioException error) {
    if (_isAuthEndpoint(error.requestOptions.path)) return false;

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
      'authenticate',
      'login again',
      // Intentionally narrow: only explicit token/session-expiry wording
      // counts as an auth error (broad Arabic words removed to avoid
      // treating validation 400s as session expiry).
      'انتهت صلاحية',
      'غير مصرح',
    ];
    for (final s in signals) {
      if (text.contains(s)) return true;
    }
    return false;
  }


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
    } catch (e) {
      Logger().e('Retry after token refresh failed: $e');
      return null;
    }
  }

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

      final refreshEither = await getIt<GeneralAuthRepo>()
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


  Future<void> _forceLogout(
    ErrorInterceptorHandler handler,
    DioException error,
  ) async {
    try {
      await getIt<CacheHelper>().clearAllData();
    } catch (_) {
    }

    if (!_logoutNavigated) {
      _logoutNavigated = true;
      // Capture UI handles before any async gap.
      final messenger =
          Nav.mainNavKey.currentContext != null
              ? ScaffoldMessenger.of(Nav.mainNavKey.currentContext!)
              : null;
      try {
        // Inform the user before leaving the screen.
        messenger?.showSnackBar(
          SnackBar(content: Text(Loc.sessionExpiredPleaseLogin())),
        );
        await Nav.mainNavKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const AccountTypeScreen(),
          ),
          (route) => false,
        );
      } catch (_) {
      }
      // Reset only after navigation completes (2s fallback).
      Future.delayed(
        const Duration(seconds: 2),
        () => _logoutNavigated = false,
      );
    }

    handler.reject(DioException(
      message: Loc.sessionExpiredPleaseLogin(),
      requestOptions: error.requestOptions,
      response: error.response,
      type: DioExceptionType.badResponse,
    ));
  }


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

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final dio = Dio();
    // Absolute URLs are requested as-is; only relative paths resolve
    // against the API base URL (avoids double-prefixing).
    if (!requestOptions.path.startsWith('http')) {
      dio.options.baseUrl = AppConfig.baseUrl;
    }
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    // A FormData body is single-use: the failed attempt already streamed it
    // (finalize() was called), so re-sending the same instance throws
    // StateError and the retry would silently degrade into a forced logout.
    // clone() rebuilds the multipart payload (same boundary) so multipart
    // endpoints such as `client/consultations` survive a token refresh.
    final originalData = requestOptions.data;
    final data = originalData is FormData ? originalData.clone() : originalData;

    // Content headers describe the first attempt; let Dio recompute them for
    // the retried body instead of replaying a stale length/boundary.
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    headers
      ..remove(Headers.contentLengthHeader)
      ..remove(Headers.contentTypeHeader);

    return await dio.request(
      requestOptions.path,
      data: data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: headers,
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