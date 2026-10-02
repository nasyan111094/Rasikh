import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';

import '../../../../config/theme/colors.dart';
import '../../../../core/utils/get_asset_path.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/picture.dart';
import 'consultation_flow_widgets.dart';

Future<void> showSelectionBottomSheet({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: builder,
  );
}

class SelectionBottomSheet<T> extends StatefulWidget {
  const SelectionBottomSheet({
    super.key,
    required this.title,
    required this.searchHint,
    required this.items,
    required this.itemId,
    required this.itemName,
    required this.onConfirm,
    required this.emptyTitle,
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.showSearch = true,
    this.confirmText,
    this.selectedId,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  final String title;
  final String searchHint;
  final List<T> items;
  final String Function(T item) itemId;
  final String Function(T item) itemName;
  final ValueChanged<T> onConfirm;
  final String emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;
  final bool showSearch;
  final String? confirmText;
  final String? selectedId;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  State<SelectionBottomSheet<T>> createState() => _SelectionBottomSheetState<T>();
}

class _SelectionBottomSheetState<T> extends State<SelectionBottomSheet<T>> {
  static const Color _titleColor = Color(0xFF404040);
  static const Color _dividerColor = Color(0xFFF5F5F5);
  static const Color _handleColor = Color(0xFFEEEEEE);

  final TextEditingController _searchController = TextEditingController();
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filteredItems {
    final query = _searchController.text.trim();
    if (query.isEmpty) return widget.items;
    return widget.items
        .where((item) => widget.itemName(item).contains(query))
        .toList();
  }

  bool get _hasSelectableItems =>
      !widget.isLoading && widget.errorMessage == null && widget.items.isNotEmpty;

  bool get _showSearch =>
      widget.showSearch && (widget.isLoading || _hasSelectableItems);

  void _confirm() {
    if (!_hasSelectableItems) {
      Navigator.of(context).pop();
      return;
    }
    final selectedId = _selectedId;
    if (selectedId == null) return;
    final matches = widget.items.where((item) => widget.itemId(item) == selectedId);
    if (matches.isEmpty) return;
    if (selectedId != widget.selectedId) widget.onConfirm(matches.first);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.8),
        child: Stack(
          children: [
            ClipPath(
              clipper: _SheetNotchClipper(
                radius: 32.w,
                notchDepth: 16.5.h,
                notchHalfWidth: 62.w,
              ),
              child: ColoredBox(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Gap(46.h),
                      _buildHeader(theme),
                      Gap(5.h),
                      const Divider(height: 1, thickness: 1, color: _dividerColor),
                      Gap(15.h),
                      if (_showSearch) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: ConsultationFlowSpacing.horizontal),
                          child: _buildSearchField(theme),
                        ),
                        Gap(5.h),
                      ],
                      Flexible(child: _buildContent(theme)),
                      Gap(16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: ConsultationFlowSpacing.horizontal),
                        child: _buildConfirmButton(theme),
                      ),
                      Gap(16.h),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: _handleColor,
                    borderRadius: BorderRadius.circular(2.h),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 16.w, end: 20.w),
      child: SizedBox(
        height: 28.w,
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _titleColor,
                ),
              ),
            ),
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              customBorder: const CircleBorder(),
              child: Container(
                width: 28.w,
                height: 28.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _dividerColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 14.w, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(ConsultationFlowSpacing.radius),
      borderSide: const BorderSide(color: borderColor),
    );

    return SizedBox(
      height: ConsultationFlowSpacing.buttonHeight,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        expands: true,
        maxLines: null,
        textAlignVertical: TextAlignVertical.center,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 13.sp,
          color: _titleColor,
        ),
        decoration: InputDecoration(
          hintText: widget.searchHint,
          hintStyle: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12.sp,
            color: greyIconColors,
          ),
          prefixIcon: Padding(
            padding: EdgeInsetsDirectional.only(start: 14.w, end: 10.w),
            child: Picture(
              getAssetIcon('search.svg'),
              width: 20.w,
              height: 20.w,
              color: greyIconColors,
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 44.w, minHeight: 20.w),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (widget.isLoading) {
      return _buildShimmer(theme);
    }

    if (widget.errorMessage != null) {
      return SingleChildScrollView(
        child: ErrorStateWidget(
          title: widget.errorMessage!,
          actionLabel: widget.onRetry == null ? null : Loc.retryAgain(),
          onAction: widget.onRetry,
        ),
      );
    }

    if (widget.items.isEmpty) {
      return SingleChildScrollView(
        child: ConsultationEmptyState(
          icon: widget.emptyIcon,
          title: widget.emptyTitle,
          message: widget.emptyMessage,
        ),
      );
    }

    final items = _filteredItems;
    if (items.isEmpty) {
      return SingleChildScrollView(
        child: ConsultationEmptyState(
          icon: Icons.search_off_rounded,
          title: Loc.noResultsFound(),
          message: Loc.tryAdjustingSearchKeywords(),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ConsultationFlowSpacing.horizontal),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, thickness: 1, color: _dividerColor),
        itemBuilder: (context, index) {
          final item = items[index];
          final id = widget.itemId(item);
          return _SelectionItem(
            name: widget.itemName(item),
            isSelected: id == _selectedId,
            onTap: () => setState(() => _selectedId = id),
          );
        },
      ),
    );
  }

  Widget _buildShimmer(ThemeData theme) {
    final baseColor = theme.brightness == Brightness.light
        ? Colors.grey.shade300
        : Colors.grey.shade700;
    final highlightColor = theme.brightness == Brightness.light
        ? Colors.grey.shade100
        : Colors.grey.shade600;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ConsultationFlowSpacing.horizontal),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: 15.h),
          itemCount: 5,
          separatorBuilder: (_, __) => Gap(16.h),
          itemBuilder: (_, __) => Container(
            height: 32.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.w),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: ConsultationFlowSpacing.buttonHeight,
      child: ElevatedButton(
        onPressed: _confirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ConsultationFlowSpacing.radius),
          ),
        ),
        child: Text(
          _hasSelectableItems || widget.isLoading
              ? widget.confirmText ?? Loc.confirm()
              : Loc.close(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _SelectionItem extends StatelessWidget {
  const _SelectionItem({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 15.h, 16.w, 8.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected ? primary : greyIconColors,
                ),
              ),
            ),
            Gap(12.w),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.w,
              height: 24.w,
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: isSelected ? primary : borderColor,
                  width: isSelected ? 1.2 : 1,
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? primary : Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetNotchClipper extends CustomClipper<Path> {
  const _SheetNotchClipper({
    required this.radius,
    required this.notchDepth,
    required this.notchHalfWidth,
  });

  final double radius;
  final double notchDepth;
  final double notchHalfWidth;

  @override
  Path getClip(Size size) {
    final sheet = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Offset.zero & size,
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        ),
      );

    final cx = size.width / 2;
    final w = notchHalfWidth;
    final d = notchDepth;

    final notch = Path()
      ..moveTo(cx - w, -1)
      ..lineTo(cx - w, 0)
      ..quadraticBezierTo(cx - w * 0.82, 0, cx - w * 0.79, d * 0.21)
      ..lineTo(cx - w * 0.63, d * 0.7)
      ..quadraticBezierTo(cx - w * 0.55, d, cx - w * 0.42, d)
      ..lineTo(cx + w * 0.42, d)
      ..quadraticBezierTo(cx + w * 0.55, d, cx + w * 0.63, d * 0.7)
      ..lineTo(cx + w * 0.79, d * 0.21)
      ..quadraticBezierTo(cx + w * 0.82, 0, cx + w, 0)
      ..lineTo(cx + w, -1)
      ..close();

    return Path.combine(PathOperation.difference, sheet, notch);
  }

  @override
  bool shouldReclip(covariant _SheetNotchClipper oldClipper) =>
      oldClipper.radius != radius ||
      oldClipper.notchDepth != notchDepth ||
      oldClipper.notchHalfWidth != notchHalfWidth;
}
