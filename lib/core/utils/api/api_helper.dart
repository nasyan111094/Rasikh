import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:event_bus/event_bus.dart';
import 'package:http/http.dart' as http;

import '../../../config/app_config.dart';
import '../vaildData/valid_data.dart';

abstract class ApiHelper {
  Future<String> getData(
    String url, {
    String? token,
    String queries,
    Map<String, String> headers = const {},
    bool typeJSON = true,
    bool signOutOn = true,
    String? lang,
  });

  Future<String> postData(
    String url, {
    String? token,
    dynamic data,
    Map<String, String> headers,
    bool typeJSON = true,
    bool signOutOn = true,
    String? lang,
  });

  Future<String> patchData(
    String url, {
    String? token,
    Map<String, dynamic> data,
    Map<String, String> headers,
    bool typeJSON = true,
    bool signOutOn = true,
    String? lang,
  });

  Future<String> putData(
    String url, {
    String? token,
    Map<String, dynamic> data,
    Map<String, String> headers,
    bool typeJSON = true,
    bool signOutOn = true,
    String? lang,
  });

  Future<dynamic> deleteData(
    String url, {
    String? token,
    Map<String, String> headers,
    Map<String, String> data,
    bool typeJSON = true,
    bool signOutOn = true,
    String? lang,
  });
}

class ApiImpl extends ApiHelper {
  ApiImpl({
    String? baseUrl,
  }) : baseUrl = baseUrl ?? AppConfig.baseUrl;

  final String baseUrl;

  @override
  Future<String> getData(
    String url, {
    String? token,
    String queries = '',
    Map<String, String> headers = const {},
    bool typeJSON = false,
    bool signOutOn = true,
    String? lang,
  }) async {
    final base = baseUrl;
    String req = '$base$url$queries';
    if (req.contains('??')) {
      req = req.replaceAll('??', '?');
    }
    final headersAll = {
      ...headers,
      if (validString(token)) "Authorization": "Bearer $token",
      if (typeJSON) 'Content-Type': 'application/json',
      // if (lang != null) 'lang': lang,
      'Accept-Language': lang ?? 'ar',
    };
    return await _request(
      () async => await http.get(
        Uri.parse(req),
        headers: headersAll,
      ),
      req,
      method: 'GET',
      headers: headersAll,
      signOutOn: signOutOn,
    );
  }

  @override
  Future<String> postData(
    String url, {
    String? token,
    dynamic data,
    Map<String, String> headers = const {},
    bool typeJSON = false,
    bool signOutOn = true,
    String? lang,
  }) async {
    final base = baseUrl;
    String req = '$base$url';
    if (req.contains('??')) {
      req = req.replaceAll('??', '?');
    }
    final headersAll = {
      ...headers,
      if (validString(token)) "Authorization": "Bearer $token",
      'Accept-Language': lang ?? 'ar',
      if (typeJSON) 'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    return await _request(
      () async => await http.post(
        Uri.parse(req),
        headers: headersAll,
        body: jsonEncode(data),
      ),
      req,
      method: 'POST',
      headers: headersAll,
      data: data,
      signOutOn: signOutOn,
    );
  }

  @override
  Future<String> patchData(
    String url, {
    String? token,
    Map<String, dynamic> data = const {},
    Map<String, String> headers = const {},
    bool signOutOn = true,
    bool typeJSON = false,
    String? lang,
  }) async {
    String req = '$baseUrl$url';
    if (req.contains('??')) {
      req = req.replaceAll('??', '?');
    }
    final headersAll = {
      ...headers,
      if (validString(token)) "Authorization": "Bearer $token",
      if (typeJSON) 'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (lang != null) 'lang': lang,
    };
    return await _request(
      () async => await http.patch(
        Uri.parse(req),
        headers: headersAll,
        body: jsonEncode(data),
      ),
      req,
      method: 'POST',
      headers: headersAll,
      signOutOn: signOutOn,
      data: data,
    );
  }

  @override
  Future<String> putData(
    String url, {
    String? token,
    Map<String, dynamic> data = const {},
    Map<String, String> headers = const {},
    bool typeJSON = false,
    bool signOutOn = true,
    String? lang,
  }) async {
    String req = '$baseUrl$url';
    if (req.contains('??')) {
      req = req.replaceAll('??', '?');
    }
    final headersAll = {
      ...headers,
      if (validString(token)) "Authorization": "Bearer $token",
      if (typeJSON) 'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (lang != null) 'lang': lang,
    };
    return await _request(
      () async => await http.put(
        Uri.parse(req),
        headers: headersAll,
        body: jsonEncode(data),
      ),
      req,
      method: 'POST',
      headers: headersAll,
      data: data,
      signOutOn: signOutOn,
    );
  }

  @override
  Future deleteData(
    String url, {
    String? token,
    Map<String, String> headers = const {},
    Map<String, String> data = const {},
    bool typeJSON = false,
    bool signOutOn = true,
    String? lang,
  }) async {
    String req = '$baseUrl$url';
    if (req.contains('??')) {
      req = req.replaceAll('??', '?');
    }
    final headersAll = {
      ...headers,
      if (validString(token)) "Authorization": "Bearer $token",
      if (typeJSON) 'Accept': 'application/json',
      if (lang != null) 'lang': lang,
    };
    return await _request(
      () async => await http.delete(
        Uri.parse(req),
        headers: headersAll,
        body: data,
      ),
      req,
      method: 'Delete',
      headers: headersAll,
      data: data,
      signOutOn: signOutOn,
    );
  }
}

extension on ApiHelper {
  Future<String> _request(
    Future<http.Response> Function() request,
    String url, {
    Map<String, String>? headers,
    dynamic data,
    required bool signOutOn,
    required String method,
  }) async {
    try {
      log('Call URL => $url');
      log('Call Method => $method');
      log('Call Headers => ${prettify(headers)}');
      log('Call Data => $data');

      var r = await request.call();

      log('Response URL => ${r.request?.url}');
      log('Response Method => ${r.request?.method}');
      log('Response Headers => ${prettify(headers)}');
      log('Response Data => ${prettify(data)}');
      log('Response Code => ${r.statusCode}');
      log('Response Body => ${r.body}');

      if (r.statusCode == 401 && signOutOn) {
        eventBus.fire(UserLoggedOutEvent());
      }

      return r.body;
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
      rethrow;
    }
  }
}

EventBus eventBus = EventBus();

class UserLoggedOutEvent {
  UserLoggedOutEvent();
}

class AddAddressEvent {
  final String address;
  AddAddressEvent(this.address);
}

class FetchUserContracts {}
