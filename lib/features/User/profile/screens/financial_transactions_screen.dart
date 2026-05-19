import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../widgets/transaction_card.dart';
import '../widgets/header_capsule_appbar_widget.dart';

class FinancialTransactionsScreen extends StatelessWidget {
  const FinancialTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final items = <_TxVM>[
      _TxVM(
        id: '9010982',
        title: 'إستشارة فورية',
        amountText: '1200 ريال',
        date: '16 / 10 / 2025',
        status: TxStatus.paid,
      ),
      _TxVM(
        id: '9010983',
        title: 'إستشارة كتابية',
        amountText: '450 ريال',
        date: '22 / 10 / 2025',
        status: TxStatus.failed,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const HeaderCapsuleAppBar(
        title: 'المعاملات المالية',
        icon: Icons.arrow_back_ios_rounded,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(
          color: colorScheme.outline.withOpacity(0.15),
          thickness: 0.6,
          height: 24,
        ),
        itemBuilder: (context, i) {
          final tx = items[i];
          return TransactionCard(
            id: tx.id,
            title: tx.title,
            date: tx.date,
            amountText: tx.amountText,
            status: tx.status,
          )
          // 🌀 أنيميشن دخول كل عنصر بالتدريج
              .animate(
            delay: (i * 150).ms,
          )
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic)
              .scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1));
        },
      )
      // ✨ حركة بسيطة عند تحميل الصفحة كلها
          .animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.05, end: 0),
    );
  }
}

/// ViewModel بسيط للشاشة
class _TxVM {
  final String id;
  final String title;
  final String date;
  final String amountText;
  final TxStatus status;

  _TxVM({
    required this.id,
    required this.title,
    required this.date,
    required this.amountText,
    required this.status,
  });
}
