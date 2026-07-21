import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';
import 'package:logger/logger.dart';
import 'package:rasikh/config/app_config.dart';
import 'package:rasikh/config/localization/lang_repo.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/services/app_logger.dart';
import 'package:rasikh/features/common/Auth/repo/auth_repo.dart';

import '../../cache/pref_keys.dart';

class ApiHandler {
  ApiHandler() {
    _adapterBase = _apiConfig();
  }

  DioAdapterBase? _adapterBase;
  DioAdapterBase get dioAdapterBase => _adapterBase!;

  // Single Refresh Mechanism: Prevent concurrent token refresh operations
  static bool _isRefreshing = false;
  static Completer<void>? _refreshCompleter;

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

    if (options.path == EndPoints.loginWithDataBase) {
      options.headers.addAll({'Accept-Language': 'ar'});
    } else {
      await getIt.get<LangRepo>().getLang();
      final appLang = getIt.get<LangRepo>().lang ?? "ar";

      if (token == null) {
        options.headers.addAll({'Accept-Language': appLang});
      } else {
        options.headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept-Language': appLang,
        });
      }
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

    if (error.response?.statusCode == 401 /*|| error.response?.statusCode == 400*/) {
      Logger().e(" 😭 Your Token Is Expired, SO: I Will Refresh Your Token Now ");

      try {
        final cacheHelper = getIt.get<CacheHelper>();
        final refreshToken = await cacheHelper.getRefreshToken();
        final vendorType = await cacheHelper.getCachedVendorType();

        if (refreshToken == null || vendorType == null) {
          // No refresh token available or vendor type not set
          await cacheHelper.clearUserSession();
          return DioException(
            message: "No refresh token available, please login again.",
            requestOptions: error.requestOptions,
            type: DioExceptionType.badResponse,
          );
        }

        // Check if refresh is already in progress
        if (_isRefreshing) {
          Logger().i("Token refresh already in progress, waiting for completion...");
          // Wait for the ongoing refresh to complete
          await _refreshCompleter!.future;
          
          // After refresh completes, retry the original request with updated token
          try {
            final newToken = await cacheHelper.getUserToken();
            if (newToken != null) {
              final RequestOptions requestOptions = error.requestOptions;
              requestOptions.headers['Authorization'] = 'Bearer $newToken';

              // Get the current language
              await getIt.get<LangRepo>().getLang();
              final appLang = getIt.get<LangRepo>().lang ?? "ar";
              requestOptions.headers["Accept-Language"] = appLang;

              final retryResponse = await _retryRequest(requestOptions);
              handler.resolve(retryResponse);
              return error;
            }
          } catch (retryError) {
            Logger().e("Failed to retry request after waiting for token refresh: $retryError");
            handler.next(error);
            return error;
          }
        }

        // Mark that refresh is starting
        _isRefreshing = true;
        _refreshCompleter = Completer<void>();

        try {
          // Use the auth repo to refresh the token
          final authRepo = GeneralAuthRepo();
          final refreshEither = await authRepo.refreshToken(
            refreshToken: refreshToken,
            vendor: vendorType,
          );

          final refreshResponse = refreshEither.fold(
                (l) => throw Exception(l),
                (r) => r,
          );

          final newAccessToken = refreshResponse.accessToken;
          final newRefreshToken = refreshResponse.refreshToken;
          
          Logger().e(" 😍 Your New Token is: $newAccessToken ");

          // Save the new tokens
          await cacheHelper.setUserToken(newAccessToken);
          await cacheHelper.setRefreshToken(newRefreshToken);

          // Update the original request with new token
          final RequestOptions requestOptions = error.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          // Get the current language
          await getIt.get<LangRepo>().getLang();
          final appLang = getIt.get<LangRepo>().lang ?? "ar";
          requestOptions.headers["Accept-Language"] = appLang;

          // Retry the original request with new token
          try {
            final retryResponse = await _retryRequest(requestOptions);
            
            // Mark refresh as complete
            _isRefreshing = false;
            _refreshCompleter?.complete();
            
            handler.resolve(retryResponse);
            return error;
          } catch (retryError) {
            Logger().e("Failed to retry request after token refresh: $retryError");
            
            // Mark refresh as complete before clearing session
            _isRefreshing = false;
            _refreshCompleter?.complete();
            
            handler.next(error);
            return error;
          }
        } catch (e) {
          Logger().e("Token refresh failed: $e");
          
          // Mark refresh as complete
          _isRefreshing = false;
          _refreshCompleter?.complete();
          
          // Only clear session if refresh endpoint itself failed (not a generic exception)
          await getIt<CacheHelper>().clearUserSession();
          return DioException(
            message: "Session expired, please login again.",
            requestOptions: error.requestOptions,
            type: DioExceptionType.badResponse,
          );
        }
      } catch (e) {
        Logger().e("Unexpected error in token refresh: $e");
        
        // Mark refresh as complete
        _isRefreshing = false;
        _refreshCompleter?.complete();
        
        return DioException(
          message: "An unexpected error occurred, please login again.",
          requestOptions: error.requestOptions,
          type: DioExceptionType.badResponse,
        );
      }
    }
    AppLogger.info(error.response?.data['message']?.toString()) ;
    // Handle other errors
    print('Error: ${error.message}');
    return DioException(
      message: error.response?.data['message']?.toString() ?? error.message.toString(),
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