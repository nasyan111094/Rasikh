
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';
import 'package:logger/logger.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';

import '../../../../../../core/get_it_service/get_it_service.dart';
import '../../../../../../core/utils/api/api_handler.dart';
import '../models/consultation_model.dart';


class _Endpoints {
  _Endpoints._();

  static bool get _isLawyer =>
      getIt<CacheHelper>().cachedVendorType == VendorType.lawyer;

  static String get list =>
      _isLawyer ? 'lawyer/consultations' : 'client/consultations';

  static String details(String id) =>
      _isLawyer ? 'lawyer/consultations/$id' : 'client/consultations/$id';

  static String reschedule(String id) =>
      'client/consultations/$id/reschedule';

  static String cancel(String id) =>
      'client/consultations/$id/cancel';

  static String rate = 'client/ratings';
}


class ConsultationsRepo {
  ConsultationsRepo() : _adapter = getIt<ApiHandler>().dioAdapterBase;

  final DioAdapterBase _adapter;


  Future<Either<String, ConsultationsModel>> getConsultations({
    int page = 1,
    int limit = 3,
    ConsultationStatus? status,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null && status != ConsultationStatus.none)
        'status': status.apiValue,
    };

    final result = await _adapter.get(
      _Endpoints.list,
      queryParameters: query,
    );

    if (result.isRight) {



      return Right(
        ConsultationsModel.fromJson(result.right.data as Map<String, dynamic>),
      );
    }
    return Left(_extractError(result.left));
  }


  Future<Either<String, ConsultationModel>> getConsultationDetails({
    required String id,
  }) async {
    final result = await _adapter.get(_Endpoints.details(id));

    if (result.isRight) {
      Logger().i(result.right.data);
      final data = result.right.data;
      
      Map<String, dynamic> json;
      if (data is Map<String, dynamic>) {
        final dataField = data['data'];
        if (dataField is List && dataField.isNotEmpty) {
          json = dataField[0] as Map<String, dynamic>;
        } else if (dataField is Map<String, dynamic>) {
          json = dataField;
        } else {
          json = data;
        }
      } else if (data is List && data.isNotEmpty) {
        json = data[0] as Map<String, dynamic>;
      } else {
        return Left('Invalid response format');
      }
      
      return Right(ConsultationModel.fromJson(json));
    }
    return Left(_extractError(result.left));
  }


  Future<Either<String, ConsultationModel>> rescheduleConsultation({
    required String id,
    required DateTime newStartTime,
  }) async {
    final result = await _adapter.post(
      _Endpoints.reschedule(id),
      body: {
        'newStartTime': newStartTime.toUtc().toIso8601String(),
      },
    );

    if (result.isRight) {
      final data = result.right.data;
      final json = data is Map<String, dynamic>
          ? (data['data'] as Map<String, dynamic>? ?? data)
          : data as Map<String, dynamic>;
      return Right(ConsultationModel.fromJson(json));
    }
    return Left(_extractError(result.left));
  }


  Future<Either<String, bool>> cancelConsultation({
    required String id,
  }) async {
    final result = await _adapter.put(
      _Endpoints.cancel(id),
    );

    if (result.isRight) {
      return const Right(true);
    }
    return Left(_extractError(result.left));
  }


  Future<Either<String, bool>> rateConsultation({
    required String consultationId,
    required String lawyerId,
    required String clientId,
    required int stars,
    String? comment,
  }) async {
    final result = await _adapter.post(
      _Endpoints.rate,
      body: {
        'consultationId': consultationId,
        'lawyerId': lawyerId,
        'clientId': clientId,
        'stars': stars,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );

    if (result.isRight) {
      return const Right(true);
    }
    return Left(_extractError(result.left));
  }


  String _extractError(dynamic error) {
    try {
      if (error is DioException) {
        final data = error.response?.data;
        if (data is Map) {
          return data['message']?.toString() ??
              data['error']?['details']?.toString() ??
              Loc.unexpectedError();
        }
      }
      return error.toString();
    } catch (_) {
      return Loc.unexpectedError();
    }
  }
}