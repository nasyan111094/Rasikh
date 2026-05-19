import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';
import 'package:logger/logger.dart';
import 'package:rasikh/config/app_config.dart';
import 'package:rasikh/config/localization/lang_repo.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';

import '../../cache/pref_keys.dart';

class ApiHandler {
  ApiHandler() {
    _adapterBase = _apiConfig();
  }

  DioAdapterBase? _adapterBase;
  DioAdapterBase get dioAdapterBase => _adapterBase!;

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
        final refreshToken = await getIt<CacheHelper>().getData(PrefKeys.refreshToken);

        if (refreshToken != null) {
          // Refresh the token
          final refreshEither = await dioAdapterBase.post(
              EndPoints.refreshToken + "?refreshToken=$refreshToken");

          final refreshResponse = refreshEither.fold(
                (l) => throw Exception(l),
                (r) => r,
          );

          final newAccessToken = refreshResponse.data['data']['token'];
          Logger().e(" 😍 Your New Token is: $newAccessToken ");

          // Save the new token
          await getIt<CacheHelper>().setUserToken(newAccessToken);

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
            handler.resolve(retryResponse);
            return error; // This won't be used since we resolved
          } catch (retryError) {
            Logger().e("Failed to retry request after token refresh: $retryError");
            return DioException(
              message: "Failed to retry request after token refresh",
              requestOptions: error.requestOptions,
              type: DioExceptionType.badResponse,
            );
          }
        } else {
          // No refresh token available
          return DioException(
            message: "No refresh token available, please login again.",
            requestOptions: error.requestOptions,
            type: DioExceptionType.badResponse,
          );
        }
      } catch (e) {
        Logger().e("Token refresh failed: $e");
        return DioException(
          message: "Session expired, please login again.",
          requestOptions: error.requestOptions,
          type: DioExceptionType.badResponse,
        );
      }
    }

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