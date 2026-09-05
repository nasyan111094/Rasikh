// ─────────────────────────────────────────────────────────────────────────────
// wallet_models.dart
// Models for wallet functionality (client and lawyer)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';

import '../../../../core/get_it_service/get_it_service.dart';

class WalletModel {
  final String id;
  final String clientId;
  final double availableBalance;
  final double disputePendingBalance;
  final double withdrawalPendingBalance;
  final double pendingBalance;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletModel({
    required this.id,
    required this.clientId,
    required this.availableBalance,
    required this.disputePendingBalance,
    required this.withdrawalPendingBalance,
    required this.pendingBalance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      clientId: getIt<CacheHelper>().cachedVendorType==VendorType.user ?json['clientId'] :json['lawyerId'] as String,
      availableBalance: (json['availableBalance'] as num).toDouble(),
      disputePendingBalance: (json['disputePendingBalance'] as num?)?.toDouble() ?? 0,
      withdrawalPendingBalance: (json['withdrawalPendingBalance'] as num?)?.toDouble() ?? 0,
      pendingBalance: (json['pendingBalance'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'availableBalance': availableBalance,
      'disputePendingBalance': disputePendingBalance,
      'withdrawalPendingBalance': withdrawalPendingBalance,
      'pendingBalance': pendingBalance,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class BankAccountModel {
  final String id;
  final String clientId;
  final String bankName;
  final String accountHolderName;
  final String iban;
  final bool isDefault;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  BankAccountModel({
    required this.id,
    required this.clientId,
    required this.bankName,
    required this.accountHolderName,
    required this.iban,
    required this.isDefault,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] as String,
      clientId: getIt<CacheHelper>().cachedVendorType==VendorType.user ?json['clientId'] :json['lawyerId'] as String,
      bankName: json['bankName'] as String,
      accountHolderName: json['accountHolderName'] as String,
      iban: json['iban'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'bankName': bankName,
      'accountHolderName': accountHolderName,
      'iban': iban,
      'isDefault': isDefault,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BankAccountModel copyWith({
    String? id,
    String? clientId,
    String? bankName,
    String? accountHolderName,
    String? iban,
    bool? isDefault,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BankAccountModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      bankName: bankName ?? this.bankName,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      iban: iban ?? this.iban,
      isDefault: isDefault ?? this.isDefault,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TransactionModel {
  final String id;
  final String referenceNumber;
  final String clientId;
  final String type;
  final String typeLabel;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String description;
  final String? referenceId;
  final String? referenceModel;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.referenceNumber,
    required this.clientId,
    required this.type,
    required this.typeLabel,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.description,
    this.referenceId,
    this.referenceModel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      referenceNumber: json['referenceNumber'] as String,
      clientId: getIt<CacheHelper>().cachedVendorType==VendorType.user ?json['clientId'] :json['lawyerId'] as String,
      type: json['type'] as String,
      typeLabel: json['typeLabel'] as String,
      amount: (json['amount'] as num).toDouble(),
      balanceBefore: (json['balanceBefore'] as num).toDouble(),
      balanceAfter: (json['balanceAfter'] as num).toDouble(),
      description: json['description'] as String,
      referenceId: json['referenceId'] as String?,
      referenceModel: json['referenceModel'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referenceNumber': referenceNumber,
      'clientId': clientId,
      'type': type,
      'typeLabel': typeLabel,
      'amount': amount,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'description': description,
      'referenceId': referenceId,
      'referenceModel': referenceModel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class TransactionListResponse {
  final List<TransactionModel> transactions;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  TransactionListResponse({
    required this.transactions,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) {
    final transactionsList = json['transactions'] as List<dynamic>? ?? [];
    return TransactionListResponse(
      transactions: transactionsList
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

class WithdrawalModel {
  final String id;
  final String clientId;
  final String bankAccountId;
  final double amount;
  final String status;
  final String accountHolderName;
  final String iban;
  final String bankName;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? adminNotes;
  final String? rejectionReason;
  final String? processedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  WithdrawalModel({
    required this.id,
    required this.clientId,
    required this.bankAccountId,
    required this.amount,
    required this.status,
    required this.accountHolderName,
    required this.iban,
    required this.bankName,
    required this.requestedAt,
    this.processedAt,
    this.adminNotes,
    this.rejectionReason,
    this.processedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: json['id'] as String,
      clientId: getIt<CacheHelper>().cachedVendorType==VendorType.user ?json['clientId'] :json['lawyerId'] as String,
      bankAccountId: json['bankAccountId'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      accountHolderName: json['accountHolderName'] as String,
      iban: json['iban'] as String,
      bankName: json['bankName'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
      adminNotes: json['adminNotes'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      processedBy: json['processedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'bankAccountId': bankAccountId,
      'amount': amount,
      'status': status,
      'accountHolderName': accountHolderName,
      'iban': iban,
      'bankName': bankName,
      'requestedAt': requestedAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'adminNotes': adminNotes,
      'rejectionReason': rejectionReason,
      'processedBy': processedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class TopupLimitsModel {
  final double minSar;
  final double maxSar;

  TopupLimitsModel({
    required this.minSar,
    required this.maxSar,
  });

  factory TopupLimitsModel.fromJson(Map<String, dynamic> json) {
    return TopupLimitsModel(
      minSar: (json['minSar'] as num).toDouble(),
      maxSar: (json['maxSar'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minSar': minSar,
      'maxSar': maxSar,
    };
  }
}

class TopupResponseModel {
  final String topupId;
  final PaymentModel payment;

  TopupResponseModel({
    required this.topupId,
    required this.payment,
  });

  factory TopupResponseModel.fromJson(Map<String, dynamic> json) {
    return TopupResponseModel(
      topupId: json['topupId'] as String,
      payment: PaymentModel.fromJson(json['payment'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topupId': topupId,
      'payment': payment.toJson(),
    };
  }
}

class PaymentModel {
  final int invoiceId;
  final String invoiceURL;
  final String customerReference;
  final String userDefinedField;
  final String paymentURL;

  PaymentModel({
    required this.invoiceId,
    required this.invoiceURL,
    required this.customerReference,
    required this.userDefinedField,
    required this.paymentURL,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      invoiceId: json['InvoiceId'] as int,
      invoiceURL: json['InvoiceURL'] as String,
      customerReference: json['CustomerReference'] as String,
      userDefinedField: json['UserDefinedField'] as String,
      paymentURL: json['PaymentURL'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'InvoiceId': invoiceId,
      'InvoiceURL': invoiceURL,
      'CustomerReference': customerReference,
      'UserDefinedField': userDefinedField,
      'PaymentURL': paymentURL,
    };
  }
}
