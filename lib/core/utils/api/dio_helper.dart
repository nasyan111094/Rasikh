import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../../config/app_config.dart';

abstract class DioHelper {
  Future<dynamic> postMultiPart(String url,
      {dynamic data,
      required String token,
      String? lang,
      String? contentType,
      String? acceptType});
}

class DioImpl extends DioHelper {
  final Dio dioCode = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      receiveDataWhenStatusError: true,
    ),
  )..interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
    ));

  @override
  Future postMultiPart(String url,
      {dynamic data,
      required String token,
      String? lang,
      String? contentType,
      String? acceptType}) async {
    dioCode.options.headers = {
      'Accept-Language': lang ?? 'ar',
      if (contentType != null)
        'Content-Type': contentType
      else
        'Content-Type': 'application/x-www-form-urlencoded',
      if (contentType != null)
        'Accept': acceptType
      else
        'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    if (url.contains('??')) {
      url = url.replaceAll('??', '?');
    }
    return await _request(
      () async => await dioCode.post(url, data: data),
      url,
      data,
    );
  }
}

extension on DioHelper {
  Future _request(Future<Response> Function() request, String url, data) async {
    try {
      var r = await request.call();
      return r ;
    } on DioException catch (e) {
      debugPrint('_request error $e');
      rethrow;
    } catch (e) {
      debugPrint('_request error $e');
      throw Exception();
    }
  }
}
