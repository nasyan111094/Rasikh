import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/features/User/profile/bloc/wallet_cubit.dart';
import 'package:rasikh/features/User/profile/bloc/wallet_state.dart';
import 'package:rasikh/features/User/profile/models/wallet_models.dart';
import 'package:size_config/size_config.dart';
import '../../../../Shared/widgets/icon_with_bg.dart';
import '../../../../core/widgets/general_app_bar.dart';
import '../../../User/profile/widgets/header_capsule_appbar_widget.dart';
import 'add_bank_account_screen.dart';

class WithdrawRequestScreen extends StatefulWidget {
  const WithdrawRequestScreen({super.key});

  @override
  State<WithdrawRequestScreen> createState() => _WithdrawRequestScreenState();
}

class _WithdrawRequestScreenState extends State<WithdrawRequestScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedBankAccountId;
  final double _minWithdrawalAmount = 50.0; // Minimum withdrawal amount
  bool _hasAutoSelected = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleWithdrawal(BuildContext context, WalletState state) {
    if (_selectedBankAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار حساب بنكي')),
      );
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال المبلغ')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
      );
      return;
    }

    if (amount < _minWithdrawalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الحد الأدنى للسحب هو $_minWithdrawalAmount ريال')),
      );
      return;
    }

    final availableBalance = state.wallet?.availableBalance ?? 0;
    if (amount > availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رصيدك غير كافٍ للسحب')),
      );
      return;
    }

    // Create withdrawal request
    context.read<WalletCubit>().createWithdrawal(
      amount: amount,
      bankAccountId: _selectedBankAccountId!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return BlocProvider(
      create: (_) => getIt<WalletCubit>()
        ..getWallet()
        ..getBankAccounts(),
      child: BlocListener<WalletCubit, WalletState>(
        listener: (context, state) {
          if (state.withdrawalRequestStatus == WalletStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إرسال طلب السحب بنجاح')),
            );
            Navigator.pop(context);
            context.read<WalletCubit>().resetWithdrawalRequest();
          } else if (state.withdrawalRequestStatus == WalletStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.withdrawalRequestError ?? 'فشل إرسال طلب السحب')),
            );
          }
        },
        child: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            final wallet = state.wallet;
            final bankAccounts = state.bankAccounts;
            final availableBalance = wallet?.availableBalance ?? 0;
            final isLoading = state.withdrawalRequestStatus == WalletStatus.loading;

            // Auto-select first bank account if available and not already selected
            if (!_hasAutoSelected &&
                state.bankAccountsStatus == WalletStatus.success &&
                bankAccounts.isNotEmpty &&
                _selectedBankAccountId == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _selectedBankAccountId = bankAccounts.first.id;
                    _hasAutoSelected = true;
                  });
                }
              });
            }

            return SafeArea(
              child: Scaffold(
                appBar: const GeneralAppBar(
                  title: 'طلب سحب',
                ),
                body: Column(
                  children: [
                    // 📜 Scrollable form content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 💰 الرصيد المتاح للسحب
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12.h),
                                border: Border.all(color: theme.disabledColor.withOpacity(.1)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleIconContainer(
                                        icon: "wallet.svg",
                                        backgroundColor: const Color(0xffF7F4F0),
                                        iconColor: const Color(0xFFC7A47B),
                                        size: 40.w,
                                        iconSize: 20.w,
                                        hasShadow: false,
                                      ),
                                      Gap(10.w),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "الرصيد المتاح للسحب",
                                            style: textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          Gap(3.h),
                                          Text(
                                            "${availableBalance.toStringAsFixed(2)} ريال",
                                            style: textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFC7A47B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Gap(40.h),

                            // 🏦 اختيار الحساب البنكي
                            Text(
                              "اختر الحساب البنكي *",
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gap(15.h),
                            if (state.bankAccountsStatus == WalletStatus.loading)
                              Container(
                                height: 60.h,
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.h),
                                  border: Border.all(color: theme.disabledColor.withOpacity(.2)),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else if (bankAccounts.isEmpty)
                              Column(
                                children: [
                                  Container(
                                    height: 60.h,
                                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.h),
                                      border: Border.all(color: Colors.red.withOpacity(.5)),
                                      color: Colors.red.withOpacity(0.05),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                                        Gap(8.w),
                                        Expanded(
                                          child: Text(
                                            'لا توجد حسابات بنكية معرفة. يرجى إضافة حساب بنكي أولاً',
                                            style: textTheme.bodySmall?.copyWith(
                                              color: Colors.red.shade700,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Gap(15.h),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48.h,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showAddBankAccountDialog(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.h),
                                          side: BorderSide(
                                            color: const Color(0xFFC7A47B),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        '+ إضافة حساب بنكي',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: const Color(0xFFC7A47B),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Container(
                                height: 60.h,
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.h),
                                  border: Border.all(color: theme.disabledColor.withOpacity(.2)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.account_balance, color: Colors.grey),
                                    Gap(8.w),
                                    Expanded(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedBankAccountId,
                                          hint: Text(
                                            'اختر الحساب',
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: theme.hintColor,
                                            ),
                                          ),
                                          items: bankAccounts.map((account) {
                                            return DropdownMenuItem<String>(
                                              value: account.id,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(account.bankName),
                                                  Text(
                                                    account.accountHolderName,
                                                    style: textTheme.bodySmall?.copyWith(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedBankAccountId = value;
                                            });
                                          },
                                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                          style: textTheme.bodyMedium,
                                          isExpanded: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            Gap(40.h),

                            // 💵 المبلغ المطلوب للسحب
                            Text(
                              "المبلغ المطلوب للسحب *",
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gap(20.h),
                            Container(
                              height: 60.h,
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.h),
                                border: Border.all(color: theme.disabledColor.withOpacity(.2)),
                              ),
                              child: Row(
                                children: [
                                  Picture(
                                    getAssetIcon("riyal.svg"),
                                    width: 18.w,
                                    height: 18.w,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _amountController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '0.00',
                                        hintStyle: textTheme.bodyMedium?.copyWith(
                                          color: theme.hintColor,
                                        ),
                                      ),
                                      style: textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Small bottom padding so last field isn't flush against the footer
                            Gap(20.h),
                          ],
                        ),
                      ),
                    ),

                    // 🟡 Fixed footer with confirm button
                    Container(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _handleWithdrawal(context, state),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC7A47B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.h),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Text(
                            'تأكيد السحب',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}