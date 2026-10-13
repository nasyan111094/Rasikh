
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:dartz/dartz.dart';
import 'package:dio_adapter/dio_adapter.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/api/api_handler.dart';
import 'package:uuid/uuid.dart';

import '../../../../config/app_config.dart';
import '../models/wallet_models.dart';

/// Normalizes an IBAN: strips spaces and uppercases.
String normalizeIban(String input) => input.replaceAll(' ', '').toUpperCase();

/// Shared IBAN validation (SA, 24 chars, digits after SA).
/// Returns the localized error message or null when valid.
String? validateIban(String? value) {
  if (value == null || value.isEmpty) {
    return Loc.pleaseEnterIban();
  }
  final cleanValue = normalizeIban(value);
  if (cleanValue.length < 24) {
    return Loc.ibanMinLength();
  }
  if (cleanValue.length > 24) {
    return Loc.ibanMaxLength();
  }
  if (!cleanValue.startsWith('SA')) {
    return Loc.ibanMustStartWithSa();
  }
  if (!RegExp(r'^[0-9]+$').hasMatch(cleanValue.substring(2))) {
    return Loc.ibanDigitsOnlyAfterSa();
  }
  return null;
}

class WalletRepo {
  WalletRepo();

  final DioAdapterBase _dio = getIt.get<ApiHandler>().dioAdapterBase;

  
  String? _getVendorType() {
    final vendorType = getIt<CacheHelper>().cachedVendorType;
    return vendorType?.name;
  }

  /// Explicit error when the vendor type is unknown — callers surface it
  /// as a failure state instead of silently falling back to `client`.
  String? _missingVendorError() {
    if (_getVendorType() == null) {
      return Loc.unexpectedError();
    }
    return null;
  }


  Future<Either<String, WalletModel>> getWallet() async {
    final vendorError = _missingVendorError();
    if (vendorError != null) return Left(vendorError);
    final vendorType = _getVendorType();
    
    final result = await _dio.get(EndPoints.wallet(vendorType: vendorType));

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(WalletModel.fromJson(data));
    }
    return Left(result.left.toString());
  }


  Future<Either<String, List<BankAccountModel>>> getBankAccounts() async {
    final vendorError = _missingVendorError();
    if (vendorError != null) return Left(vendorError);
    final vendorType = _getVendorType();
    
    final result = await _dio.get(EndPoints.walletBankAccounts(vendorType: vendorType));

    if (result.isRight) {
      final rawList = result.right.data['data'] as List<dynamic>? ?? [];
      final accounts = rawList
          .map((e) => BankAccountModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(accounts);
    }
    return Left(result.left.toString());
  }


  Future<Either<String, BankAccountModel>> addBankAccount({
    required String bankName,
    required String accountHolderName,
    required String iban,
  }) async {
    final vendorError = _missingVendorError();
    if (vendorError != null) return Left(vendorError);
    final vendorType = _getVendorType();
    
    final result = await _dio.post(
      EndPoints.walletBankAccounts(vendorType: vendorType),
      body: {
        'bankName': bankName,
        'accountHolderName': accountHolderName,
        'iban': iban,
      },
    );

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(BankAccountModel.fromJson(data));
    }
    return Left(_extractError(result.left));
  }


  String _extractError(dynamic left) {
    try {
      if (left is DioException) {
        final data = left.response?.data;
        if (data is Map) {
          final errors = data['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final first = errors.values.first;
            if (first is List && first.isNotEmpty) {
              return first.first.toString();
            }
            if (first is String && first.isNotEmpty) return first;
          }
          if (errors is List && errors.isNotEmpty) {
            final first = errors.first;
            if (first is Map) {
              return (first['message'] ?? first['msg'] ?? first.toString())
                  .toString();
            }
            return first.toString();
          }
          final message = data['message']?.toString() ??
              data['error']?['details']?.toString();
          if (message != null && message.isNotEmpty) return message;
          return Loc.unexpectedError();
        }
      }
      return left.toString();
    } catch (_) {
      return Loc.unexpectedError();
    }
  }


  Future<Either<String, TopupResponseModel>> initiateTopup({
    required double amount,
    String? idempotencyKey,
  }) async {
    final vendorError = _missingVendorError();
    if (vendorError != null) return Left(vendorError);
    final vendorType = _getVendorType();
    // Stable per attempt: the caller (cubit) generates the key once per user
    // action and passes it in, so retries of the same attempt reuse it.
    final key = idempotencyKey ?? const Uuid().v4();
    
    final result = await _dio.post(
      EndPoints.walletTopupInitiate(vendorType: vendorType),
      options: Options(headers: {
        'Idempotency-Key': key,
      }),
      body: {
        'amount': amount,
      },
    );

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(TopupResponseModel.fromJson(data));
    }
    return Left(result.left.toString());
  }


  Future<Either<String, TopupLimitsModel>> getTopupLimits() async {
    final vendorError = _missingVendorError();
    if (vendorError != null) return Left(vendorError);
    final vendorType = _getVendorType();
    
    final result = await _dio.get(EndPoints.walletTopupLimits(vendorType: vendorType));

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(TopupLimitsModel.fromJson(data));
    }
    return Left(result.left.toString());
  }


  Future<Either<String, TransactionListResponse>> getTransactions({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    final vendorError = _missingVendorError();
    if (vendorError != null) return Left(vendorError);
    final vendorType = _getVendorType();
    
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (type != null && type.isNotEmpty) 'type': type,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    };

    final result = await _dio.get(
      EndPoints.walletTransactions(vendorType: vendorType),
      queryParameters: queryParams,
    );

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(TransactionListResponse.fromJson(data));
    }
    return Left(result.left.toString());
  }


  Future<Either<String, TransactionModel>> getTransactionById({
    required String id,
  }) async {
    final vendorError = _missingVendorError();
    if (vendorError != null) return Left(vendorError);
    final vendorType = _getVendorType();
    
    final result = await _dio.get(
      EndPoints.walletTransactionById(id: id, vendorType: vendorType),
    );

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(TransactionModel.fromJson(data));
    }
    return Left(result.left.toString());
  }


  Future<Either<String, List<WithdrawalModel>>> getWithdrawals() async {
    final vendorError = _missingVendorError();
    if (vendorError != null) return Left(vendorError);
    final vendorType = _getVendorType();
    
    final result = await _dio.get(EndPoints.walletWithdrawals(vendorType: vendorType));

    if (result.isRight) {
      final rawList = result.right.data['data'] as List<dynamic>? ?? [];
      final withdrawals = rawList
          .map((e) => WithdrawalModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(withdrawals);
    }
    return Left(result.left.toString());
  }


  Future<Either<String, WithdrawalModel>> createWithdrawal({
    required double amount,
    required String bankAccountId,
    String? idempotencyKey,
  }) async {
    final vendorError = _missingVendorError();
    if (vendorError != null) return Left(vendorError);
    final vendorType = _getVendorType();
    // Stable per attempt: the caller (cubit) generates the key once per user
    // action and passes it in, so retries of the same attempt reuse it.
    final key = idempotencyKey ?? const Uuid().v4();

    final result = await _dio.post(
      EndPoints.walletWithdrawals(vendorType: vendorType),
      options: Options(headers: {
        'Idempotency-Key': key,
      }),
      body: {
        'amount': amount,
        'bankAccountId': bankAccountId,
      },
    );

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(WithdrawalModel.fromJson(data));
    }
    return Left(result.left.toString());
  }


  Future<Either<String, String>> deleteBankAccount({
    required String id,
  }) async {
    final vendorError = _missingVendorError();
    if (vendorError != null) return Left(vendorError);
    final vendorType = _getVendorType();
    
    final result = await _dio.delete(
      EndPoints.walletDeleteBankAccount(id: id, vendorType: vendorType),
    );

    if (result.isRight) {
      return Right(result.right.data['message'] as String? ?? Loc.bankAccountDeletedSuccessfully());
    }
    return Left(result.left.toString());
  }


  Future<Either<String, BankAccountModel>> setDefaultBankAccount({
    required String id,
  }) async {
    final vendorError = _missingVendorError();
    if (vendorError != null) return Left(vendorError);
    final vendorType = _getVendorType();
    
    final result = await _dio.put(
      EndPoints.walletSetDefaultBankAccount(id: id, vendorType: vendorType),
    );

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(BankAccountModel.fromJson(data));
    }
    return Left(result.left.toString());
  }


  Future<Either<String, BankAccountModel>> updateBankAccount({
    required String id,
    String? bankName,
    String? accountHolderName,
    String? iban,
  }) async {
    final vendorError = _missingVendorError();
    if (vendorError != null) return Left(vendorError);
    final vendorType = _getVendorType();
    
    final body = <String, dynamic>{};
    if (bankName != null) body['bankName'] = bankName;
    if (accountHolderName != null) body['accountHolderName'] = accountHolderName;
    if (iban != null) body['iban'] = iban;

    final result = await _dio.put(
      EndPoints.walletUpdateBankAccount(id: id, vendorType: vendorType),
      body: body.isNotEmpty ? body : null,
    );

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(BankAccountModel.fromJson(data));
    }
    return Left(result.left.toString());
  }
}
