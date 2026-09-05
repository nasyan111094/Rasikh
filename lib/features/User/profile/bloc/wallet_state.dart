// ─────────────────────────────────────────────────────────────────────────────
// wallet_state.dart
// State management for wallet functionality
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

import '../models/wallet_models.dart';

enum WalletStatus {
  initial,
  loading,
  success,
  failure,
}

class WalletState extends Equatable {
  // ── Wallet data ─────────────────────────────────────────────────────────────
  final WalletStatus walletStatus;
  final WalletModel? wallet;
  final String? walletError;

  // ── Bank accounts ───────────────────────────────────────────────────────────
  final WalletStatus bankAccountsStatus;
  final List<BankAccountModel> bankAccounts;
  final String? bankAccountsError;

  // ── Top-up ─────────────────────────────────────────────────────────────────
  final WalletStatus topupStatus;
  final TopupResponseModel? topupResponse;
  final String? topupError;
  final TopupLimitsModel? topupLimits;
  final WalletStatus topupLimitsStatus;
  final String? topupLimitsError;

  // ── Transactions ────────────────────────────────────────────────────────────
  final WalletStatus transactionsStatus;
  final List<TransactionModel> transactions;
  final int transactionsTotal;
  final int transactionsPage;
  final int transactionsLimit;
  final int transactionsTotalPages;
  final String? transactionsError;

  // ── Transaction detail ──────────────────────────────────────────────────────
  final WalletStatus transactionDetailStatus;
  final TransactionModel? transactionDetail;
  final String? transactionDetailError;

  // ── Withdrawals ────────────────────────────────────────────────────────────
  final WalletStatus withdrawalsStatus;
  final List<WithdrawalModel> withdrawals;
  final String? withdrawalsError;

  // ── Withdrawal request ────────────────────────────────────────────────────
  final WalletStatus withdrawalRequestStatus;
  final WithdrawalModel? withdrawalRequest;
  final String? withdrawalRequestError;

  const WalletState({
    // Wallet
    this.walletStatus = WalletStatus.initial,
    this.wallet,
    this.walletError,

    // Bank accounts
    this.bankAccountsStatus = WalletStatus.initial,
    this.bankAccounts = const [],
    this.bankAccountsError,

    // Top-up
    this.topupStatus = WalletStatus.initial,
    this.topupResponse,
    this.topupError,
    this.topupLimits,
    this.topupLimitsStatus = WalletStatus.initial,
    this.topupLimitsError,

    // Transactions
    this.transactionsStatus = WalletStatus.initial,
    this.transactions = const [],
    this.transactionsTotal = 0,
    this.transactionsPage = 1,
    this.transactionsLimit = 10,
    this.transactionsTotalPages = 1,
    this.transactionsError,

    // Transaction detail
    this.transactionDetailStatus = WalletStatus.initial,
    this.transactionDetail,
    this.transactionDetailError,

    // Withdrawals
    this.withdrawalsStatus = WalletStatus.initial,
    this.withdrawals = const [],
    this.withdrawalsError,

    // Withdrawal request
    this.withdrawalRequestStatus = WalletStatus.initial,
    this.withdrawalRequest,
    this.withdrawalRequestError,
  });

  WalletState copyWith({
    // Wallet
    WalletStatus? walletStatus,
    WalletModel? wallet,
    String? walletError,

    // Bank accounts
    WalletStatus? bankAccountsStatus,
    List<BankAccountModel>? bankAccounts,
    String? bankAccountsError,

    // Top-up
    WalletStatus? topupStatus,
    TopupResponseModel? topupResponse,
    String? topupError,
    TopupLimitsModel? topupLimits,
    WalletStatus? topupLimitsStatus,
    String? topupLimitsError,

    // Transactions
    WalletStatus? transactionsStatus,
    List<TransactionModel>? transactions,
    int? transactionsTotal,
    int? transactionsPage,
    int? transactionsLimit,
    int? transactionsTotalPages,
    String? transactionsError,

    // Transaction detail
    WalletStatus? transactionDetailStatus,
    TransactionModel? transactionDetail,
    String? transactionDetailError,

    // Withdrawals
    WalletStatus? withdrawalsStatus,
    List<WithdrawalModel>? withdrawals,
    String? withdrawalsError,

    // Withdrawal request
    WalletStatus? withdrawalRequestStatus,
    WithdrawalModel? withdrawalRequest,
    String? withdrawalRequestError,
  }) {
    return WalletState(
      walletStatus: walletStatus ?? this.walletStatus,
      wallet: wallet ?? this.wallet,
      walletError: walletError ?? this.walletError,

      bankAccountsStatus: bankAccountsStatus ?? this.bankAccountsStatus,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      bankAccountsError: bankAccountsError ?? this.bankAccountsError,

      topupStatus: topupStatus ?? this.topupStatus,
      topupResponse: topupResponse ?? this.topupResponse,
      topupError: topupError ?? this.topupError,
      topupLimits: topupLimits ?? this.topupLimits,
      topupLimitsStatus: topupLimitsStatus ?? this.topupLimitsStatus,
      topupLimitsError: topupLimitsError ?? this.topupLimitsError,

      transactionsStatus: transactionsStatus ?? this.transactionsStatus,
      transactions: transactions ?? this.transactions,
      transactionsTotal: transactionsTotal ?? this.transactionsTotal,
      transactionsPage: transactionsPage ?? this.transactionsPage,
      transactionsLimit: transactionsLimit ?? this.transactionsLimit,
      transactionsTotalPages: transactionsTotalPages ?? this.transactionsTotalPages,
      transactionsError: transactionsError ?? this.transactionsError,

      transactionDetailStatus: transactionDetailStatus ?? this.transactionDetailStatus,
      transactionDetail: transactionDetail ?? this.transactionDetail,
      transactionDetailError: transactionDetailError ?? this.transactionDetailError,

      withdrawalsStatus: withdrawalsStatus ?? this.withdrawalsStatus,
      withdrawals: withdrawals ?? this.withdrawals,
      withdrawalsError: withdrawalsError ?? this.withdrawalsError,

      withdrawalRequestStatus: withdrawalRequestStatus ?? this.withdrawalRequestStatus,
      withdrawalRequest: withdrawalRequest ?? this.withdrawalRequest,
      withdrawalRequestError: withdrawalRequestError ?? this.withdrawalRequestError,
    );
  }

  @override
  List<Object?> get props => [
        walletStatus,
        wallet,
        walletError,
        bankAccountsStatus,
        bankAccounts,
        bankAccountsError,
        topupStatus,
        topupResponse,
        topupError,
        topupLimits,
        topupLimitsStatus,
        topupLimitsError,
        transactionsStatus,
        transactions,
        transactionsTotal,
        transactionsPage,
        transactionsLimit,
        transactionsTotalPages,
        transactionsError,
        transactionDetailStatus,
        transactionDetail,
        transactionDetailError,
        withdrawalsStatus,
        withdrawals,
        withdrawalsError,
        withdrawalRequestStatus,
        withdrawalRequest,
        withdrawalRequestError,
      ];
}
