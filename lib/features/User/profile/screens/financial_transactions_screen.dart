import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/widgets/no_data_widget.dart';
import 'package:rasikh/features/User/profile/bloc/wallet_cubit.dart';
import 'package:rasikh/features/User/profile/bloc/wallet_state.dart';
import 'package:rasikh/features/User/profile/models/wallet_models.dart';
import 'package:size_config/size_config.dart';


import '../../../../config/theme/colors.dart';
import '../../../../core/utils/get_asset_path.dart';
import '../../../../core/widgets/general_app_bar.dart';
import '../../../../core/widgets/general_divider.dart';
import '../../../../core/widgets/picture.dart' show Picture;
import '../widgets/header_capsule_appbar_widget.dart';


class FinancialTransactionsScreen extends StatefulWidget {
  const FinancialTransactionsScreen({super.key});

  @override
  State<FinancialTransactionsScreen> createState() => _FinancialTransactionsScreenState();
}

class _FinancialTransactionsScreenState extends State<FinancialTransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (_) => getIt<WalletCubit>()..getTransactions(limit: 20),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar:  GeneralAppBar(
          title: 'المعاملات المالية',
        ),
        body: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            final transactions = state.transactions;
            final isLoading = state.transactionsStatus == WalletStatus.loading;

            if (isLoading && transactions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (transactions.isEmpty) {
              return const Center(child: NoDataWidget(title: 'لا توجد معاملات'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => Divider(
                color: colorScheme.outline.withOpacity(0.15),
                thickness: 0.6,
                height: 24,
              ),
              itemBuilder: (context, i) {
                final tx = transactions[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => showTransactionDetailsDialog(context, tx),
                  child: _buildTransactionCard(tx, theme, colorScheme, i),
                );
              },
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.05, end: 0);
          },
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
      TransactionModel tx,
      ThemeData theme,
      ColorScheme colorScheme,
      int index,
      ) {
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
          // الصف الأول: حالة العملية + رقم العملية
          Row(
            children: [
              // شارة الحالة (خضراء)
              Text(
                '${tx.referenceNumber}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(

                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getStatusColor(tx.type).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getStatusIcon(tx.type),
                        size: 14, color: _getStatusColor(tx.type).shade700),
                    const SizedBox(width: 4),
                    Text(
                      _getStatusText(tx.type),
                      style: TextStyle(
                        color: _getStatusColor(tx.type).shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // رقم العملية

            ],
          ),
          const SizedBox(height: 10),
          GeneralDivider(height: 1, color: borderColor),
          const SizedBox(height: 10),
          Row(
            children:
            [
              Picture(getAssetIcon("transactions.svg"), width: 30.h, height: 30.h),
              Gap(16.w),
              Expanded(
                child: Column(children:
                [
                  // الصف الثاني: وصف العملية
                  Text(
                    tx.description, // "فتح نزاع على استشاره فوريه"
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  // الصف الثالث: المبلغ + التاريخ
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${tx.amount.toStringAsFixed(0)} ريال',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: primary ,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Picture(getAssetIcon("Calendar.svg"), width:20.h, height: 20.h),
                      const SizedBox(width: 4),
                      Text(
                        '${tx.createdAt.day} / ${tx.createdAt.month} / ${tx.createdAt.year}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],),
              )

            ],
          )
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
        return 'تم الدفع';
      case 'consultation_payment':
        return 'تم الدفع';
      case 'consultation_refund':
        return 'تم الاسترداد';
      case 'withdrawal_request':
        return 'قيد المعالجة';
      case 'withdrawal_rejected':
        return 'فشل الدفع';
      case 'withdrawal_transferred':
        return 'تم التحويل';
      case 'admin_adjustment':
        return 'تم التعديل';
      case 'consultation_earning':
        return 'ربح استشارة';
      case 'dispute_deposit':
        return 'إيداع نزاع';
      case 'dispute_hold':
        return 'تعليق نزاع';
      case 'dispute_release':
        return 'إطلاق نزاع';
      case 'dispute_forfeit':
        return 'خسارة نزاع';
      case 'consultation_earnings_accrual':
        return 'تراكم أرباح';
      case 'consultation_earnings_release':
        return 'إطلاق أرباح';
      case 'consultation_earnings_reversal':
        return 'عكس أرباح';
      case 'commission_penalty':
        return 'غرامة عمولة';
      default:
        return 'غير معروف';
    }
  }
}



/// Shows the transaction-details dialog for [tx].
Future<void> showTransactionDetailsDialog(
    BuildContext context,
    TransactionModel tx,
    ) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => TransactionDetailsDialog(transaction: tx),
  );
}

class TransactionDetailsDialog extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsDialog({super.key, required this.transaction});

  // Same type -> (color, icon, label) mapping used for the badge on the
  // list card, kept here so the dialog's status badge matches it exactly.
  MaterialColor _statusColor(String type) {
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

  IconData _statusIcon(String type) {
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

  String _statusText(String type) {
    switch (type) {
      case 'topup':
        return 'تم الدفع';
      case 'consultation_payment':
        return 'تم الدفع';
      case 'consultation_refund':
        return 'تم الاسترداد';
      case 'withdrawal_request':
        return 'قيد المعالجة';
      case 'withdrawal_rejected':
        return 'فشل الدفع';
      case 'withdrawal_transferred':
        return 'تم التحويل';
      case 'admin_adjustment':
        return 'تم التعديل';
      case 'consultation_earning':
        return 'ربح استشارة';
      case 'dispute_deposit':
        return 'إيداع نزاع';
      case 'dispute_hold':
        return 'تعليق نزاع';
      case 'dispute_release':
        return 'إطلاق نزاع';
      case 'dispute_forfeit':
        return 'خسارة نزاع';
      case 'consultation_earnings_accrual':
        return 'تراكم أرباح';
      case 'consultation_earnings_release':
        return 'إطلاق أرباح';
      case 'consultation_earnings_reversal':
        return 'عكس أرباح';
      case 'commission_penalty':
        return 'غرامة عمولة';
      default:
        return 'غير معروف';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} / ${date.month} / ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final color = _statusColor(transaction.type);

    final notes = transaction.description.trim().isEmpty
        ? 'لا توجد ملاحظات'
        : transaction.description;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.h),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تفاصيل العملية :',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Gap(8.h),

            // Details table
            ClipRRect(
              borderRadius: BorderRadius.circular(10.h),
              child: Column(
                children: [
                  _detailRow(
                    context,
                    label: 'نوع العملية',
                    value: transaction.typeLabel,
                    index: 0,
                  ),
                  _detailRow(
                    context,
                    label: 'الرقم المرجعي',
                    value: '#${transaction.referenceNumber}',
                    index: 1,
                  ),
                  _detailRow(
                    context,
                    label: 'التاريخ/الوقت',
                    value: _formatDate(transaction.createdAt),
                    index: 2,
                  ),
                  _detailRow(
                    context,
                    label: 'المبلغ',
                    value: '${transaction.amount.toStringAsFixed(0)} ريال',
                    index: 3,
                  ),
                  _detailRow(
                    context,
                    label: 'الحالة',
                    index: 4,
                    valueWidget: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8.h),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(transaction.type),
                              size: 14, color: color.shade700),
                          Gap(4.w),
                          Text(
                            _statusText(transaction.type),
                            style: TextStyle(
                              color: color.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _detailRow(
                    context,
                    label: 'الرصيد بعد العملية',
                    value: '${transaction.balanceAfter.toStringAsFixed(0)} ريال',
                    index: 5,
                  ),
                  _detailRow(
                    context,
                    label: 'ملاحظات إضافية',
                    value: notes,
                    index: 6,
                    isLast: true,
                  ),
                ],
              ),
            ),
            Gap(20.h),

            // Close button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC7A47B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.h),
                  ),
                ),
                child: Text(
                  'إغلاق',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
      BuildContext context, {
        required String label,
        String? value,
        Widget? valueWidget,
        required int index,
        bool isLast = false,
      }) {
    final theme = Theme.of(context);
    final isEven = index % 2 == 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(

        border: isLast
            ? null
            : Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          Flexible(
            child: valueWidget ??
                Text(
                  value ?? '',
                  textAlign: TextAlign.left,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}