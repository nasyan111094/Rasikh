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
import 'package:url_launcher/url_launcher.dart';
import 'package:size_config/size_config.dart';
import '../../../../Shared/widgets/icon_with_bg.dart';
import '../../../../core/widgets/general_app_bar.dart';
import '../../../User/profile/widgets/header_capsule_appbar_widget.dart';

class TopUpWalletScreen extends StatefulWidget {
  const TopUpWalletScreen({super.key});

  @override
  State<TopUpWalletScreen> createState() => _TopUpWalletScreenState();
}

class _TopUpWalletScreenState extends State<TopUpWalletScreen> {
  final TextEditingController _amountController = TextEditingController();
  TopupLimitsModel? _topupLimits;


  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleTopUp(WalletCubit cubit, WalletState state) {
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

    // Validate against limits
    if (_topupLimits != null) {
      if (amount < _topupLimits!.minSar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الحد الأدنى للإيداع هو ${_topupLimits!.minSar.toStringAsFixed(2)} ريال')),
        );
        return;
      }
      if (amount > _topupLimits!.maxSar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الحد الأقصى للإيداع هو ${_topupLimits!.maxSar.toStringAsFixed(2)} ريال')),
        );
        return;
      }
    }

    // Initiate top-up
    cubit.initiateTopup(amount: amount);
  }

  Future<void> _handlePaymentUrl(String paymentUrl) async {
    final uri = Uri.parse(paymentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح رابط الدفع')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return BlocProvider(
      create: (_) => getIt<WalletCubit>()..getTopupLimits(),
      child: BlocListener<WalletCubit, WalletState>(
        listener: (context, state) {
          // Store top-up limits when loaded
          if (state.topupLimits != null) {
            _topupLimits = state.topupLimits;
          }

          // Handle top-up success
          if (state.topupStatus == WalletStatus.success && state.topupResponse != null) {
            final paymentUrl = state.topupResponse!.payment.paymentURL;
            _handlePaymentUrl(paymentUrl);
            context.read<WalletCubit>().resetTopup();
          } else if (state.topupStatus == WalletStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.topupError ?? 'فشل إرسال طلب الإيداع')),
            );
          }
        },
        child: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            final isLoading = state.topupStatus == WalletStatus.loading;
            final limitsLoading = state.topupLimitsStatus == WalletStatus.loading;

            return SafeArea(
              child: Scaffold(
                appBar: const GeneralAppBar(
                  title: 'إيداع رصيد',

                ),
                body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 💰 معلومات الإيداع
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12.h),
                          border: Border.all(color: theme.disabledColor.withOpacity(.1)),
                        ),
                        child: Row(
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "إيداع رصيد في محفظتك",
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  Gap(3.h),
                                  if (_topupLimits != null)
                                    Text(
                                      "الحد الأدنى: ${_topupLimits!.minSar.toStringAsFixed(2)} ريال | الحد الأقصى: ${_topupLimits!.maxSar.toStringAsFixed(2)} ريال",
                                      style: textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    )
                                  else if (limitsLoading)
                                    const Text(
                                      "جاري تحميل الحدود...",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Gap(40.h),

                      // 💵 المبلغ المطلوب للإيداع
                      Text(
                        "المبلغ المطلوب للإيداع *",
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
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
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

                      Gap(20.h),

                      // 💡 معلومات إضافية
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8.h),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            Gap(8.w),
                            Expanded(
                              child: Text(
                                'سيتم توجيهك إلى بوابة الدفع لإكمال عملية الإيداع',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // 🟡 زر تجديد الإيداع
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: BlocBuilder<WalletCubit, WalletState>(
                          builder: (context, state) {
                            final isLoading = state.topupStatus == WalletStatus.loading;
                            return ElevatedButton(
                              onPressed: isLoading ? null : () => _handleTopUp(context.read<WalletCubit>(), state),
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
                                  'إيداع',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            );
                          },
                        ),
                      ),
                      Gap(10.h),
                    ],
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
