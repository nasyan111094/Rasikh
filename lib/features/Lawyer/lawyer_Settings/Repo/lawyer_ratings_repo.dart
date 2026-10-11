
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';

import '../../../../../../core/get_it_service/get_it_service.dart';
import '../../../../../../core/utils/api/api_handler.dart';
import '../models/lawyer_ratings_model.dart';


class _RatingsEndpoints {
  static const String ratings = 'lawyer/ratings';

  static String ratingById(String id) => 'lawyer/ratings/$id';
  static String reportRating(String id) => 'lawyer/ratings/$id/report';
  static String replyToRating(String id) => 'lawyer/ratings/$id/reply';
}


class LawyerRatingsRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;


  Future<Either<String, LawyerRatingsModel>> getRatings({
    int page = 1,
    int limit = 10,
  }) async {
    final result = await _adapter.get(
      _RatingsEndpoints.ratings,
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


  Future<Either<String, RatingDetailModel>> getRatingById(String ratingId) async {
    final result = await _adapter.get(
      _RatingsEndpoints.ratingById(ratingId),
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
      
      print('DEBUG: getRatingById parsed data: $ratingJson');
      return Right(RatingDetailModel.fromJson(ratingJson));
    }
    return Left(_extractError(result.left));
  }


  Future<Either<String, String>> replyToRating({
    required String ratingId,
    required String reply,
  }) async {
    final result = await _adapter.post(
      _RatingsEndpoints.replyToRating(ratingId),
      body: ReplyRatingRequest(reply: reply).toJson(),
    );

    if (result.isRight) {
      final data = result.right.data;
      final responseMessage =
          data['message']?.toString() ?? Loc.replySentSuccessfully();
      return Right(responseMessage);
    }
    return Left(_extractError(result.left));
  }


  Future<Either<String, String>> reportRating({
    required String ratingId,
    required String message,
  }) async {
    final result = await _adapter.post(
      _RatingsEndpoints.reportRating(ratingId),
      body: ReportRatingRequest(message: message).toJson(),
    );

    if (result.isRight) {
      final data = result.right.data;
      final responseMessage =
          data['message']?.toString() ?? Loc.reportSentSuccessfully();
      return Right(responseMessage);
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
