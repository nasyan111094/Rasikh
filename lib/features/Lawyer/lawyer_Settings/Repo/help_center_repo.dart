// features/help_center/data/repos/help_center_repo.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';

import '../../../../../../core/get_it_service/get_it_service.dart';
import '../../../../../../core/utils/api/api_handler.dart';
import '../models/help_center_models.dart';

// ── Endpoint constants ────────────────────────────────────────────────────────

class _HelpCenterEndpoints {
  static const String contact = 'content/public/contact';
  static const String privacyPolicy = 'content/public/privacy-policy';
  static const String terms = 'content/public/terms';
}

// ── Repository ────────────────────────────────────────────────────────────────

class HelpCenterRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;

  // ── GET contact info ──────────────────────────────────────────────────────

  Future<Either<String, ContactModel>> getContactInfo() async {
    final result = await _adapter.get(_HelpCenterEndpoints.contact);

    if (result.isRight) {
      final data = result.right.data['data'] ?? result.right.data;
      return Right(ContactModel.fromJson(data as Map<String, dynamic>));
    }
    return Left(_extractError(result.left));
  }

  // ── GET privacy policy ────────────────────────────────────────────────────

  Future<Either<String, ContentModel>> getPrivacyPolicy() async {
    final result = await _adapter.get(_HelpCenterEndpoints.privacyPolicy);

    if (result.isRight) {
      final data = result.right.data['data'] ?? result.right.data;
      return Right(ContentModel.fromJson(data as Map<String, dynamic>));
    }
    return Left(_extractError(result.left));
  }

  // ── GET terms & conditions ────────────────────────────────────────────────

  Future<Either<String, ContentModel>> getTerms() async {
    final result = await _adapter.get(_HelpCenterEndpoints.terms);

    if (result.isRight) {
      final data = result.right.data['data'] ?? result.right.data;
      return Right(ContentModel.fromJson(data as Map<String, dynamic>));
    }
    return Left(_extractError(result.left));
  }

  // ── Error helper ──────────────────────────────────────────────────────────

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
