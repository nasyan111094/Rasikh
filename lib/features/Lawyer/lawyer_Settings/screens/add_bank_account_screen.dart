import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:size_config/size_config.dart';
import '../../../User/profile/bloc/wallet_cubit.dart';
import '../../../User/profile/bloc/wallet_state.dart';

/// Call this to show the "Add Bank Account" dialog.
Future<void> showAddBankAccountDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => const AddBankAccountDialog(),
  );
}

class AddBankAccountDialog extends StatefulWidget {
  const AddBankAccountDialog({super.key});

  @override
  State<AddBankAccountDialog> createState() => _AddBankAccountDialogState();
}

class _AddBankAccountDialogState extends State<AddBankAccountDialog> {
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountHolderNameController =
  TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountHolderNameController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  void _handleAddBankAccount(WalletCubit cubit) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    cubit.addBankAccount(
      bankName: _bankNameController.text.trim(),
      accountHolderName: _accountHolderNameController.text.trim(),
      iban: _ibanController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return BlocProvider(
      create: (_) => getIt<WalletCubit>(),
      child: BlocListener<WalletCubit, WalletState>(
        listener: (context, state) {
          if (state.bankAccountsStatus == WalletStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إضافة الحساب البنكي بنجاح')),
            );
            Navigator.pop(context);
          } else if (state.bankAccountsStatus == WalletStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                Text(state.bankAccountsError ?? 'فشل إضافة الحساب البنكي'),
              ),
            );
          }
        },
        child: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            final isLoading = state.bankAccountsStatus == WalletStatus.loading;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.h),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row with title + close button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'إضافة حساب بنكي',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        Gap(10.h),

                        // Name of Bank
                        Text(
                          'اسم البنك *',
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(10.h),
                        TextFormField(
                          controller: _bankNameController,
                          decoration: InputDecoration(
                            hintText: 'مثال: مصرف الراجحي',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.h),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال اسم البنك';
                            }
                            return null;
                          },
                        ),
                        Gap(16.h),

                        // Account Holder Name
                        Text(
                          'اسم صاحب الحساب *',
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(10.h),
                        TextFormField(
                          controller: _accountHolderNameController,
                          decoration: InputDecoration(
                            hintText: 'الاسم الكامل',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.h),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال اسم صاحب الحساب';
                            }
                            return null;
                          },
                        ),
                        Gap(16.h),

                        // IBAN
                        Text(
                          'رقم الآيبان (IBAN) *',
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(10.h),
                        TextFormField(
                          controller: _ibanController,
                          textDirection: TextDirection.ltr,
                          maxLength: 24,
                          decoration: InputDecoration(
                            hintText: 'SA1234567890123456789012',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.h),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال رقم الآيبان';
                            }
                            if (value.length < 24) {
                              return 'رقم الآيبان يجب أن يكون 24 حرف على الأقل';
                            }
                            return null;
                          },
                        ),
                        Gap(24.h),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.h),
                                  ),
                                ),
                                child: Text(
                                  'إلغاء',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Gap(12.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _handleAddBankAccount(
                                    context.read<WalletCubit>()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC7A47B),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
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
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                                    : Text(
                                  'إضافة الحساب',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}