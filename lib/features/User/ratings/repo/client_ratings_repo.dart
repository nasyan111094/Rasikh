
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';

import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/api/api_handler.dart';
import 'package:rasikh/features/Lawyer/lawyer_Settings/models/lawyer_ratings_model.dart';


class _ClientRatingsEndpoints {
  static const String ratings = 'client/ratings';

  static String ratingById(String id) => 'client/ratings/$id';
}


class ClientRatingsRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;


  Future<Either<String, LawyerRatingsModel>> getRatings({
    int page = 1,
    int limit = 10,
  }) async {
    final result = await _adapter.get(
      _ClientRatingsEndpoints.ratings,
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    if (result.isRight) {
      final data = result.right.data;
      return Right(LawyerRatingsModel.fromJson(data));
    }
    return Left(_extractError(result.left));
  }


  Future<Either<String, RatingDetailModel>> getRatingById(
    String ratingId,
  ) async {
    final result = await _adapter.get(
      _ClientRatingsEndpoints.ratingById(ratingId),
    );

    if (result.isRight) {
      final data = result.right.data;

      Map<String, dynamic> ratingJson;
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        ratingJson = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
      } else {
        ratingJson = data as Map<String, dynamic>;
      }

      return Right(RatingDetailModel.fromJson(ratingJson));
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
