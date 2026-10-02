import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';
import '../../../User/profile/bloc/wallet_cubit.dart';
import '../../../User/profile/bloc/wallet_state.dart';

Future<void> showAddBankAccountDialog(BuildContext context) {
  final cubit = context.read<WalletCubit>();
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => AddBankAccountDialog(cubit: cubit),
  );
}

class AddBankAccountDialog extends StatefulWidget {
  const AddBankAccountDialog({super.key, required this.cubit});

  final WalletCubit cubit;

  @override
  State<AddBankAccountDialog> createState() => _AddBankAccountDialogState();
}

class _AddBankAccountDialogState extends State<AddBankAccountDialog> {
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountHolderNameController =
  TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _successHandled = false;

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountHolderNameController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  String? _validateIBAN(String? value) {
    if (value == null || value.isEmpty) {
      return Loc.pleaseEnterIban();
    }

    final cleanValue = value.replaceAll(' ', '').toUpperCase();

    if (cleanValue.length < 24) {
      return Loc.ibanMinLength();
    }
    if (cleanValue.length > 24) {
      return Loc.ibanMaxLength();
    }

    if (!cleanValue.startsWith('SA')) {
      return Loc.ibanMustStartWithSa();
    }

    final ibanNumbers = cleanValue.substring(2);
    if (!RegExp(r'^[0-9]+$').hasMatch(ibanNumbers)) {
      return Loc.ibanDigitsOnlyAfterSa();
    }

    return null;
  }

  void _handleAddBankAccount(WalletCubit cubit) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    cubit.addBankAccount(
      bankName: _bankNameController.text.trim(),
      accountHolderName: _accountHolderNameController.text.trim(),
      iban: _ibanController.text.trim().replaceAll(' ', '').toUpperCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return BlocProvider.value(
      value: widget.cubit,
      child: BlocListener<WalletCubit, WalletState>(
        listener: (context, state) {
          if (state.bankAccountsStatus == WalletStatus.success &&
              !_successHandled) {
            _successHandled = true;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(Loc.bankAccountAddedSuccessfully()),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            widget.cubit.getBankAccounts();
            Navigator.pop(context);
          } else if (state.bankAccountsStatus == WalletStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                Text(state.bankAccountsError ?? Loc.addBankAccountFailed()),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Loc.addBankAccount(),
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

                        Text(
                          Loc.bankNameRequired(),
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(10.h),
                        TextFormField(
                          controller: _bankNameController,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: Loc.bankNameExample(),
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
                              return Loc.pleaseEnterBankName();
                            }
                            return null;
                          },
                        ),
                        Gap(16.h),

                        Text(
                          Loc.accountHolderNameRequired(),
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(10.h),
                        TextFormField(
                          controller: _accountHolderNameController,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: Loc.fullNameLabel(),
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
                              return Loc.pleaseEnterAccountHolderName();
                            }
                            return null;
                          },
                        ),
                        Gap(16.h),

                        Text(
                          Loc.ibanRequired(),
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(10.h),
                        TextFormField(
                          controller: _ibanController,
                          enabled: !isLoading,
                          textDirection: TextDirection.ltr,
                          maxLength: 29,
                          inputFormatters: [
                            _IBANInputFormatter(),
                          ],
                          decoration: InputDecoration(
                            hintText: 'SA12 1234 5678 9012 3456 7890',
                            helperText: Loc.ibanHelperText(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.h),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                          ),
                          validator: _validateIBAN,
                        ),
                        Gap(24.h),

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
                                  Loc.cancel(),
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
                                  Loc.addAccount(),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap(16.h),
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

class _IBANInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String text = newValue.text.replaceAll(' ', '').toUpperCase();

    if (text.length > 24) {
      text = text.substring(0, 24);
    }

    StringBuffer formatted = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted.write(' ');
      }
      formatted.write(text[i]);
    }

    return TextEditingValue(
      text: formatted.toString(),
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}