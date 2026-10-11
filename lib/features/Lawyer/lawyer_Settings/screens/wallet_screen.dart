import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/custom_app_bar_all_screens.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:rasikh/core/widgets/no_data_widget.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/features/User/profile/bloc/wallet_cubit.dart';
import 'package:rasikh/features/User/profile/bloc/wallet_state.dart';
import 'package:rasikh/features/User/profile/models/wallet_models.dart';
import 'package:rasikh/features/User/profile/screens/financial_transactions_screen.dart';
import 'package:rasikh/features/User/profile/widgets/transaction_card.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';
import 'package:size_config/size_config.dart';

import '../../../../Shared/widgets/icon_with_bg.dart';
import '../../../../config/navigation/nav.dart';
import '../../../../config/navigation/nav_obs.dart';
import '../../../../config/theme/colors.dart' as colors;
import '../../../../core/widgets/general_app_bar.dart';
import '../../../User/profile/widgets/header_capsule_appbar_widget.dart';
import 'add_bank_account_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with RouteAware {
  WalletCubit? _cubit;
  Route<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route != _route) {
      _route = route;
      NavObs.instance.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    _refreshWallet().ignore();
  }

  @override
  void dispose() {
    if (_route != null) {
      NavObs.instance.unsubscribe(this);
    }
    _route = null;
    super.dispose();
  }

  Future<void> _refreshWallet() {
    final cubit = _cubit;
    if (!mounted || cubit == null) return Future<void>.value();
    return Future.wait([
      cubit.getWallet(),
      cubit.getBankAccounts(),
      cubit.getTransactions(limit: 5),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocProvider(
      create: (_) => _cubit = getIt<WalletCubit>()
        ..getWallet()
        ..getBankAccounts()
        ..getTransactions(limit: 5),
      child: Scaffold(
        appBar:  GeneralAppBar(
          title: Loc.electronicWallet(),

        ),
        bottomNavigationBar: Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.fromLTRB(
              16.0.w,
              30.h,
              16.0.w,
              30.h + MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: OutlinedButton.icon(
                onPressed: () {
                  showAddBankAccountDialog(context);
                },
                icon: const Icon(Icons.add_circle_outline, size: 18, color: primary),
                label: Text(Loc.addNewAccount(),
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(color: primary)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.primary.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ),
        body: BlocListener<WalletCubit, WalletState>(
          listener: (context, state) {
            if (state.bankAccountsStatus == WalletStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.bankAccountsError ??
                        Loc.updateBankAccountsFailed())),
              );
            }
          },
          child:
          BlocBuilder<WalletCubit, WalletState>(builder: (context, state) {
            final wallet = state.wallet;
            final transactions = state.transactions;
            final bankAccounts = state.bankAccounts;
            final isLoading = state.walletStatus == WalletStatus.loading;

            if (isLoading && wallet == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              color: const Color(0xFFC7A47B),
              onRefresh: _refreshWallet,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                children: [
                  _buildBalanceCard(
                      theme, colorScheme, textTheme, context, wallet)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Picture(
                            getAssetIcon("dot.svg"),
                            width: 20.h,
                            height: 20.h,
                          ),
                          Gap(6.w),
                          Text(
                            Loc.recentTransactions(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      InkWell(
                        borderRadius: BorderRadius.circular(12.h),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const FinancialTransactionsScreen()));
                        },
                        child: Row(
                          children: [
                            Text(
                              Loc.viewAll(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                color: const Color(0xFFC7A47B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap(12.h),

                  if (transactions.isNotEmpty)
                    ...transactions
                        .take(3)
                        .map((tx) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () =>
                            showTransactionDetailsDialog(context, tx),
                        child: _buildTransactionItemFromApi(
                            tx, theme, colorScheme, textTheme),
                      ),
                    ))
                        .toList()
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0)
                  else if (state.transactionsStatus == WalletStatus.loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    NoDataWidget(title: Loc.noTransactions()),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Picture(getAssetIcon("dot.svg"),
                          width: 20.h, height: 20.h),
                      Gap(5.w),
                      Text(Loc.bankAccounts(),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildBankAccountsCard(theme, colorScheme, textTheme,
                      context, bankAccounts, state)
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(ThemeData theme, ColorScheme colors, TextTheme text,
      BuildContext context, WalletModel? wallet) {
    final isUser = getIt<CacheHelper>().cachedVendorType == VendorType.user;
    final totalBalance = wallet?.totalBalance ?? 0;
    final availableBalance = wallet?.availableBalance ?? 10;
    final pendingBalance = wallet?.pendingBalance ?? 0;
    final clientTotalBalance = availableBalance + pendingBalance;



    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.disabledColor.withOpacity(.05)),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary.withOpacity(.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Picture(getAssetIcon("wallet.svg")),
          ),
          Gap(10.h),
          Text(Loc.currentBalance(), style: text.bodyMedium),
          const SizedBox(height: 8),
          Text(
            Loc.amountRiyal((isUser ? clientTotalBalance : totalBalance).toStringAsFixed(2)),
            style: text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFC7A47B),
            ),
          ),
          GeneralDivider(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(Loc.availableBalance(),
                      style: text.bodySmall?.copyWith(color: colors.onSurface)),
                  const SizedBox(height: 4),
                  Text(
                    Loc.amountRiyal(availableBalance.toStringAsFixed(2)),
                    style: text.bodyMedium?.copyWith(
                        color: Colors.green, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.disabledColor.withOpacity(.05),
              ),
              Column(
                children: [
                  Text(Loc.pendingBalance(),
                      style: text.bodySmall?.copyWith(color: colors.onSurface)),
                  const SizedBox(height: 4),
                  Text(
                    Loc.amountRiyal(pendingBalance.toStringAsFixed(2)),
                    style: text.bodyMedium?.copyWith(
                        color: Colors.redAccent, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          GeneralDivider(height: 20.h),
          Row(
            children: [
              if (getIt<CacheHelper>().cachedVendorType == VendorType.user)
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Nav.topUpWalletScreen(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC7A47B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(Loc.topUpWallet(),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              Gap(16.w),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Nav.withdrawRequestScreen(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary.withOpacity(.1),
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(Loc.withdrawRequest(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: primary, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  MaterialColor _getStatusColor(String type) {
    switch (type) {
      case 'topup':
        return Colors.green;
      case 'consultation_payment':
        return Colors.blue;
      case 'consultation_refund':
        return Colors.orange;
      case 'withdrawal_request':
        return Colors.purple;
      case 'withdrawal_rejected':
        return Colors.red;
      case 'withdrawal_transferred':
        return Colors.teal;
      case 'admin_adjustment':
        return Colors.amber;
      case 'consultation_earning':
        return Colors.green;
      case 'dispute_deposit':
        return Colors.orange;
      case 'dispute_hold':
        return Colors.deepOrange;
      case 'dispute_release':
        return Colors.green;
      case 'dispute_forfeit':
        return Colors.red;
      case 'consultation_earnings_accrual':
        return Colors.blue;
      case 'consultation_earnings_release':
        return Colors.green;
      case 'consultation_earnings_reversal':
        return Colors.red;
      case 'commission_penalty':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String type) {
    switch (type) {
      case 'withdrawal_rejected':
        return Icons.cancel;
      case 'withdrawal_request':
        return Icons.hourglass_top;
      case 'dispute_hold':
        return Icons.lock;
      case 'dispute_forfeit':
        return Icons.cancel;
      case 'consultation_earnings_reversal':
        return Icons.undo;
      case 'commission_penalty':
        return Icons.warning;
      default:
        return Icons.check_circle;
    }
  }

  String _getStatusText(String type) {
    switch (type) {
      case 'topup':
        return Loc.paid();
      case 'consultation_payment':
        return Loc.paid();
      case 'consultation_refund':
        return Loc.refunded();
      case 'withdrawal_request':
        return Loc.processing();
      case 'withdrawal_rejected':
        return Loc.paymentFailed();
      case 'withdrawal_transferred':
        return Loc.transferred();
      case 'admin_adjustment':
        return Loc.adjusted();
      case 'consultation_earning':
        return Loc.consultationEarning();
      case 'dispute_deposit':
        return Loc.disputeDeposit();
      case 'dispute_hold':
        return Loc.disputeHold();
      case 'dispute_release':
        return Loc.disputeRelease();
      case 'dispute_forfeit':
        return Loc.disputeLoss();
      case 'consultation_earnings_accrual':
        return Loc.earningsAccrual();
      case 'consultation_earnings_release':
        return Loc.earningsRelease();
      case 'consultation_earnings_reversal':
        return Loc.earningsReversal();
      case 'commission_penalty':
        return Loc.commissionPenalty();
      default:
        return Loc.unknown();
    }
  }

  Widget _buildTransactionItemFromApi(TransactionModel tx, ThemeData theme,
      ColorScheme colors, TextTheme text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '${tx.referenceNumber}',
                style: text.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Builder(builder: (context) {
                final statusColor = _getStatusColor(tx.type);
                return Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(tx.type),
                        style: TextStyle(
                          color: statusColor.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 10),
          GeneralDivider(height: 1, color: borderColor),
          const SizedBox(height: 10),
          Row(
            children: [
              Picture(getAssetIcon("transactions.svg"),
                  width: 30.h, height: 30.h),
              Gap(16.w),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      tx.description,
                      textAlign: TextAlign.right,
                      style: text.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          Loc.amountRiyal(tx.amount.toStringAsFixed(0)),
                          style: text.bodyMedium?.copyWith(
                            color: primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Picture(getAssetIcon("Calendar.svg"),
                            width: 20.h, height: 20.h),
                        const SizedBox(width: 4),
                        Text(
                          '${tx.createdAt.day} / ${tx.createdAt.month} / ${tx.createdAt.year}',
                          style: text.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }



  Widget _buildBankAccountsCard(
      ThemeData theme,
      ColorScheme colors,
      TextTheme text,
      BuildContext context,
      List<BankAccountModel> bankAccounts,
      WalletState state) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bankAccounts.isNotEmpty)
            ...bankAccounts.map(
                  (acc) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildBankItemFromApi(acc, colors, text, context, state),
              ),
            )
          else if (state.bankAccountsStatus == WalletStatus.loading)
            const Center(child: CircularProgressIndicator())
          else
            NoDataWidget(title: Loc.noBankAccounts()),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBankItemFromApi(
      BankAccountModel acc,
      ColorScheme colors,
      TextTheme text,
      BuildContext context,
      WalletState state,
      ) {
    final isLoading = state.bankAccountsStatus == WalletStatus.loading;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          CircleIconContainer(
            icon: "transactions.svg",
            size: 40,
            backgroundColor: const Color(0xffF7F4F0),
            iconColor: const Color(0xFFC7A47B),
            iconSize: 20,
            hasShadow: false,
          ),
          Gap(5.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        acc.bankName,
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (acc.isDefault) ...[
                      Gap(8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC7A47B).withOpacity(.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          Loc.defaultLabel(),
                          style: text.bodySmall?.copyWith(
                            color: const Color(0xFFC7A47B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  acc.iban,
                  style: text.labelLarge,
                ),
              ],
            ),
          ),

          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: isLoading
                ? null
                : () => _showEditBankAccountDialog(context, acc),
            child: CircleIconContainer(
              icon: "edit.svg",
              size: 40,
              backgroundColor: Colors.green.withOpacity(.1),
              iconColor: Colors.green,
              iconSize: 20,
              hasShadow: false,
              borderRadius: 15,
            ),
          ),

          Gap(5.w),

          if (!acc.isDefault) ...[
            InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: isLoading
                  ? null
                  : () => context
                  .read<WalletCubit>()
                  .setDefaultBankAccount(id: acc.id),
              child: CircleIconContainer(
                icon: "star.svg",
                size: 40,
                backgroundColor: Colors.amber.withOpacity(.1),
                iconColor: Colors.amber,
                iconSize: 20,
                hasShadow: false,
                borderRadius: 15,
              ),
            ),
            Gap(5.w),
          ],

          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: isLoading
                ? null
                : () => _showDeleteConfirmationDialog(
              context,
              acc.id,
              acc.bankName,
            ),
            child: CircleIconContainer(
              icon: "Trash_Bin.svg",
              size: 40,
              backgroundColor: Colors.red.withOpacity(.1),
              iconColor: Colors.red,
              iconSize: 20,
              hasShadow: false,
              borderRadius: 15,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String accountId, String bankName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(Loc.confirmDeletion()),
        content: Text(Loc.deleteBankAccountConfirmation(bankName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(Loc.cancel()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<WalletCubit>().deleteBankAccount(id: accountId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(Loc.delete(), style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditBankAccountDialog(
      BuildContext context, BankAccountModel account) {
    final bankNameController = TextEditingController(text: account.bankName);
    final accountHolderNameController =
    TextEditingController(text: account.accountHolderName);
    final ibanController = TextEditingController(text: account.iban);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<WalletCubit>(),
        child: BlocListener<WalletCubit, WalletState>(
          listener: (context, state) {
            if (state.bankAccountsStatus == WalletStatus.success) {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(Loc.bankAccountUpdatedSuccessfully())),
              );
            } else if (state.bankAccountsStatus == WalletStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        state.bankAccountsError ?? Loc.updateBankAccountFailed())),
              );
            }
          },
          child: AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(Loc.editBankAccount()),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Loc.bankName(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: bankNameController,
                      decoration: InputDecoration(
                        hintText: Loc.enterBankName(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Loc.pleaseEnterBankName();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Loc.accountHolderName(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: accountHolderNameController,
                      decoration: InputDecoration(
                        hintText: Loc.enterAccountHolderName(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Loc.pleaseEnterAccountHolderName();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Loc.iban(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: ibanController,
                      textDirection: TextDirection.ltr,
                      maxLength: 24,
                      decoration: InputDecoration(
                        hintText: 'SA1234567890123456789012',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Loc.pleaseEnterIban();
                        }
                        if (value.length != 24) {
                          return Loc.ibanExactLength();
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(Loc.cancel()),
              ),
              BlocBuilder<WalletCubit, WalletState>(
                builder: (context, state) {
                  final isLoading =
                      state.bankAccountsStatus == WalletStatus.loading;
                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      if (formKey.currentState!.validate()) {
                        context.read<WalletCubit>().updateBankAccount(
                          id: account.id,
                          bankName: bankNameController.text.trim(),
                          accountHolderName:
                          accountHolderNameController.text.trim(),
                          iban: ibanController.text.trim(),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC7A47B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(Loc.save(),
                        style: TextStyle(color: Colors.white)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankItem(
      Map<String, String> acc, ColorScheme colors, TextTheme text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleIconContainer(
            icon: "transactions.svg",
            size: 40,
            backgroundColor: const Color(0xffF7F4F0),
            iconColor: const Color(0xFFC7A47B),
            iconSize: 20,
            hasShadow: false,
          ),
          Gap(5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(acc['bank']!,
                    style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(acc['iban']!, style: text.labelLarge),
              ],
            ),
          ),
          CircleIconContainer(
            icon: "edit.svg",
            size: 40,
            backgroundColor: Colors.green.withOpacity(.1),
            iconColor: Colors.green,
            iconSize: 20,
            hasShadow: false,
            borderRadius: 15,
          ),
          Gap(5.w),
          CircleIconContainer(
            icon: "Trash_Bin.svg",
            size: 40,
            backgroundColor: Colors.red.withOpacity(.1),
            iconColor: Colors.red,
            iconSize: 20,
            hasShadow: false,
            borderRadius: 15,
          ),
        ],
      ),
    );
  }
}