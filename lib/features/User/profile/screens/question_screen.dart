import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/widgets/error_state_widget.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:rasikh/core/widgets/no_data_widget.dart';
import 'package:rasikh/features/Lawyer/lawyer_Settings/bloc/help_center/contact_cubit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';

import '../../../../core/get_it_service/get_it_service.dart';
import '../../../Lawyer/lawyer_Settings/Repo/help_center_repo.dart';
import '../models/faq_model.dart';
import '../widgets/header_capsule_appbar_widget.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContactCubit(getIt<HelpCenterRepo>())..fetchFaqs(),
      child: const _FaqView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FaqView extends StatelessWidget {
  const _FaqView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const GeneralAppBar(
          title: 'الأسئلة الشائعة',

        ),
        body: BlocConsumer<ContactCubit, ContactState>(
          listenWhen: (_, s) => s is FaqFailure,
          listener: (context, state) {
            if (state is FaqFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is FaqLoading) return const _FaqShimmer();

            if (state is FaqFailure) {
              return ErrorStateWidget(
                message: state.message,
                onAction: () => context.read<ContactCubit>().fetchFaqs(), title: "تعذر تحميل الأسئله الشائعه",
              );
            }

            if (state is FaqLoaded) {
              if (state.faqs.isEmpty) {
                return NoDataWidget(title:  'لا توجد أسئلة متاحة حالياً');
              }

              return RefreshIndicator(
                onRefresh: () => context.read<ContactCubit>().refreshFaqs(),
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.faqs.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) =>
                      _FaqTile(item: state.faqs[index]),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tile
// ─────────────────────────────────────────────────────────────────────────────

class _FaqTile extends StatefulWidget {
  final FaqModel item;
  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final cardRadius = 16.w;
    final borderColor = colorScheme.outlineVariant.withOpacity(0.3);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: borderColor, width: 1.w),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (v) => setState(() => _expanded = v),
          maintainState: true,
          tilePadding:
          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          childrenPadding:
          EdgeInsets.fromLTRB(12.w, 0, 12.w, 18.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          trailing: _CapsulePlusMinus(isExpanded: _expanded),
          title: Row(
            children: [
              // Q icon bubble
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(_expanded ? 0.15 : 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Text(
                    widget.item.question,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
          children: [
            Container(
              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(12.w),

              ),

              child: Column(
                children: [
                  GeneralDivider(
                    color: borderColor,
                    thickness: 1.w,
                    height: 1.h,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(

                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.arrow_forward_ios, size: 15.sp,color: primary,),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        widget.item.answer,
                        textAlign: TextAlign.right,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 13.w,
                          height: 1.6,
                          color: textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────────────────────────────────────

class _FaqShimmer extends StatelessWidget {
  const _FaqShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, __) => Container(
          height: 64.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.w),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error body
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 56.w, color: Colors.red.shade300),
            SizedBox(height: 12.w),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.red.shade400),
            ),
            SizedBox(height: 20.w),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plus/Minus toggle
// ─────────────────────────────────────────────────────────────────────────────

class _CapsulePlusMinus extends StatelessWidget {
  final bool isExpanded;
  const _CapsulePlusMinus({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: isExpanded
            ? colorScheme.primary
            : colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8.w),
      ),
      alignment: Alignment.center,
      child: Icon(
        isExpanded ? Icons.remove_rounded : Icons.add_rounded,
        size: 20.w,
        color: isExpanded
            ? colorScheme.onPrimary
            : (Theme.of(context).iconTheme.color ?? colorScheme.onSurface),
      ),
    );
  }
}