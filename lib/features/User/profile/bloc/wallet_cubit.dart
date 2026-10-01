// ─────────────────────────────────────────────────────────────────────────────
// wallet_cubit.dart
// Cubit for wallet state management
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/wallet_models.dart';
import '../repo/wallet_repo.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit(this._repo) : super(const WalletState());

  final WalletRepo _repo;

  // ── Wallet ─────────────────────────────────────────────────────────────────

  Future<void> getWallet() async {
    emit(state.copyWith(
      walletStatus: WalletStatus.loading,
      walletError: null,
    ));

    final result = await _repo.getWallet();

    result.fold(
      (error) => emit(state.copyWith(
        walletStatus: WalletStatus.failure,
        walletError: error,
      )),
      (wallet) => emit(state.copyWith(
        walletStatus: WalletStatus.success,
        wallet: wallet,
      )),
    );
  }

  // ── Bank Accounts ─────────────────────────────────────────────────────────

  Future<void> getBankAccounts() async {
    emit(state.copyWith(
      bankAccountsStatus: WalletStatus.loading,
      bankAccountsError: null,
    ));

    final result = await _repo.getBankAccounts();

    result.fold(
      (error) => emit(state.copyWith(
        bankAccountsStatus: WalletStatus.failure,
        bankAccountsError: error,
      )),
      (accounts) => emit(state.copyWith(
        bankAccountsStatus: WalletStatus.success,
        bankAccounts: accounts,
      )),
    );
  }

  Future<void> addBankAccount({
    required String bankName,
    required String accountHolderName,
    required String iban,
  }) async {
    emit(state.copyWith(
      bankAccountsStatus: WalletStatus.loading,
      bankAccountsError: null,
    ));

    final result = await _repo.addBankAccount(
      bankName: bankName,
      accountHolderName: accountHolderName,
      iban: iban,
    );

    result.fold(
      (error) => emit(state.copyWith(
        bankAccountsStatus: WalletStatus.failure,
        bankAccountsError: error,
      )),
      (account) {
        final updatedAccounts = [...state.bankAccounts, account];
        emit(state.copyWith(
          bankAccountsStatus: WalletStatus.success,
          bankAccounts: updatedAccounts,
        ));
      },
    );
  }

  Future<void> deleteBankAccount({required String id}) async {
    emit(state.copyWith(
      bankAccountsStatus: WalletStatus.loading,
      bankAccountsError: null,
    ));

    final result = await _repo.deleteBankAccount(id: id);

    result.fold(
      (error) => emit(state.copyWith(
        bankAccountsStatus: WalletStatus.failure,
        bankAccountsError: error,
      )),
      (message) {
        final updatedAccounts = state.bankAccounts.where((acc) => acc.id != id).toList();
        emit(state.copyWith(
          bankAccountsStatus: WalletStatus.success,
          bankAccounts: updatedAccounts,
        ));
      },
    );
  }

  Future<void> setDefaultBankAccount({required String id}) async {
    emit(state.copyWith(
      bankAccountsStatus: WalletStatus.loading,
      bankAccountsError: null,
    ));

    final result = await _repo.setDefaultBankAccount(id: id);

    result.fold(
      (error) => emit(state.copyWith(
        bankAccountsStatus: WalletStatus.failure,
        bankAccountsError: error,
      )),
      (updatedAccount) {
        final updatedAccounts = state.bankAccounts.map((acc) {
          if (acc.id == id) {
            return updatedAccount;
          }
          return acc.copyWith(isDefault: false);
        }).toList();
        emit(state.copyWith(
          bankAccountsStatus: WalletStatus.success,
          bankAccounts: updatedAccounts,
        ));
      },
    );
  }

  Future<void> updateBankAccount({
    required String id,
    String? bankName,
    String? accountHolderName,
    String? iban,
  }) async {
    emit(state.copyWith(
      bankAccountsStatus: WalletStatus.loading,
      bankAccountsError: null,
    ));

    final result = await _repo.updateBankAccount(
      id: id,
      bankName: bankName,
      accountHolderName: accountHolderName,
      iban: iban,
    );

    result.fold(
      (error) => emit(state.copyWith(
        bankAccountsStatus: WalletStatus.failure,
        bankAccountsError: error,
      )),
      (updatedAccount) {
        final updatedAccounts = state.bankAccounts.map((acc) {
          if (acc.id == id) {
            return updatedAccount;
          }
          return acc;
        }).toList();
        emit(state.copyWith(
          bankAccountsStatus: WalletStatus.success,
          bankAccounts: updatedAccounts,
        ));
      },
    );
  }

  // ── Top-up ─────────────────────────────────────────────────────────────────

  Future<void> getTopupLimits() async {
    emit(state.copyWith(
      topupLimitsStatus: WalletStatus.loading,
      topupLimitsError: null,
    ));

    final result = await _repo.getTopupLimits();

    result.fold(
      (error) => emit(state.copyWith(
        topupLimitsStatus: WalletStatus.failure,
        topupLimitsError: error,
      )),
      (limits) => emit(state.copyWith(
        topupLimitsStatus: WalletStatus.success,
        topupLimits: limits,
      )),
    );
  }

  Future<void> initiateTopup({required double amount}) async {
    emit(state.copyWith(
      topupStatus: WalletStatus.loading,
      topupError: null,
    ));

    final result = await _repo.initiateTopup(amount: amount);

    result.fold(
      (error) => emit(state.copyWith(
        topupStatus: WalletStatus.failure,
        topupError: error,
      )),
      (response) => emit(state.copyWith(
        topupStatus: WalletStatus.success,
        topupResponse: response,
      )),
    );
  }

  // ── Transactions ────────────────────────────────────────────────────────────

  Future<void> getTransactions({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    emit(state.copyWith(
      transactionsStatus: WalletStatus.loading,
      transactionsError: null,
    ));

    final result = await _repo.getTransactions(
      type: type,
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );

    result.fold(
      (error) => emit(state.copyWith(
        transactionsStatus: WalletStatus.failure,
        transactionsError: error,
      )),
      (response) => emit(state.copyWith(
        transactionsStatus: WalletStatus.success,
        transactions: response.transactions,
        transactionsTotal: response.total,
        transactionsPage: response.page,
        transactionsLimit: response.limit,
        transactionsTotalPages: response.totalPages,
        transactionsIsLoadingMore: false,
      )),
    );
  }

  /// Appends the next page of transactions (infinite scroll).
  /// No-op when already loading, on first-load, or when all pages are loaded.
  Future<void> loadMoreTransactions({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    if (state.transactionsIsLoadingMore) return;
    if (state.transactionsStatus == WalletStatus.loading) return;
    if (state.transactionsPage >= state.transactionsTotalPages) return;

    emit(state.copyWith(transactionsIsLoadingMore: true));

    final nextPage = state.transactionsPage + 1;
    final result = await _repo.getTransactions(
      type: type,
      startDate: startDate,
      endDate: endDate,
      page: nextPage,
      limit: limit ?? state.transactionsLimit,
    );

    result.fold(
      // Keep the old list visible on failure.
      (error) => emit(state.copyWith(
        transactionsIsLoadingMore: false,
        transactionsError: error,
      )),
      (response) => emit(state.copyWith(
        transactionsStatus: WalletStatus.success,
        transactions: [...state.transactions, ...response.transactions],
        transactionsTotal: response.total,
        transactionsPage: response.page,
        transactionsLimit: response.limit,
        transactionsTotalPages: response.totalPages,
        transactionsIsLoadingMore: false,
      )),
    );
  }

  Future<void> getTransactionById({required String id}) async {
    emit(state.copyWith(
      transactionDetailStatus: WalletStatus.loading,
      transactionDetailError: null,
    ));

    final result = await _repo.getTransactionById(id: id);

    result.fold(
      (error) => emit(state.copyWith(
        transactionDetailStatus: WalletStatus.failure,
        transactionDetailError: error,
      )),
      (transaction) => emit(state.copyWith(
        transactionDetailStatus: WalletStatus.success,
        transactionDetail: transaction,
      )),
    );
  }

  // ── Withdrawals ────────────────────────────────────────────────────────────

  Future<void> getWithdrawals() async {
    emit(state.copyWith(
      withdrawalsStatus: WalletStatus.loading,
      withdrawalsError: null,
    ));

    final result = await _repo.getWithdrawals();

    result.fold(
      (error) => emit(state.copyWith(
        withdrawalsStatus: WalletStatus.failure,
        withdrawalsError: error,
      )),
      (withdrawals) => emit(state.copyWith(
        withdrawalsStatus: WalletStatus.success,
        withdrawals: withdrawals,
      )),
    );
  }

  Future<void> createWithdrawal({
    required double amount,
    required String bankAccountId,
  }) async {
    emit(state.copyWith(
      withdrawalRequestStatus: WalletStatus.loading,
      withdrawalRequestError: null,
    ));

    final result = await _repo.createWithdrawal(
      amount: amount,
      bankAccountId: bankAccountId,
    );

    String? errorMessage;
    WithdrawalModel? created;
    result.fold(
      (error) => errorMessage = error,
      (withdrawal) => created = withdrawal,
    );

    if (errorMessage != null || created == null) {
      emit(state.copyWith(
        withdrawalRequestStatus: WalletStatus.failure,
        withdrawalRequestError: errorMessage ?? 'فشل إرسال طلب السحب',
      ));
      return;
    }

    // Success: refresh every dependent section FIRST so the shared state
    // already carries the new balances/transactions when success is emitted.
    // Individual refreshes swallow their own errors — the withdrawal itself
    // was created, so success must still be emitted.
    await Future.wait([
      getWallet(),
      getTransactions(page: 1, limit: 5),
      getWithdrawals(),
    ]);

    final createdId = created!.id;
    final withdrawals = state.withdrawals.any((w) => w.id == createdId)
        ? state.withdrawals
        : [created!, ...state.withdrawals];

    emit(state.copyWith(
      withdrawalRequestStatus: WalletStatus.success,
      withdrawalRequest: created,
      withdrawals: withdrawals,
    ));
  }

  /// Refreshes every wallet section at once (balances, accounts, recent
  /// operations, withdrawals) — used when returning from withdrawal/top-up.
  Future<void> refreshAll({int transactionsLimit = 10}) async {
    await Future.wait([
      getWallet(),
      getBankAccounts(),
      getTransactions(page: 1, limit: transactionsLimit),
      getWithdrawals(),
    ]);
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void resetTopup() {
    emit(state.copyWith(
      topupStatus: WalletStatus.initial,
      topupResponse: null,
      topupError: null,
    ));
  }

  void resetWithdrawalRequest() {
    emit(state.copyWith(
      withdrawalRequestStatus: WalletStatus.initial,
      withdrawalRequest: null,
      withdrawalRequestError: null,
    ));
  }
}
