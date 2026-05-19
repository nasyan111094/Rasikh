import 'package:flutter/material.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import '../../utils/get_asset_path.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.controller,
    this.focusNode,
    this.confirm,
    this.onChange,
    this.label,
    this.fillColor,
    this.onFilter,
    this.onTap,
    this.filter = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.onControllerClear,
    this.prefixIcon,
    this.onTextIsClear,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? confirm;
  final ValueChanged<String>? onChange;
  final VoidCallback? onControllerClear;
  final VoidCallback? onFilter;
  final VoidCallback? onTap;
  final VoidCallback? onTextIsClear;
  final String? label;
  final bool filter;
  final Color? fillColor;
  final bool? readOnly;
  final bool? autoFocus;
  final Widget? prefixIcon;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final ValueNotifier<bool> searchSuffixIcon = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(changeSearchIcon);
  }

  @override
  void dispose() {
    widget.controller.removeListener(changeSearchIcon);
    super.dispose();
  }

  void changeSearchIcon() {
    searchSuffixIcon.value = widget.controller.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 55.0.h,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              autofocus: widget.autoFocus ?? false,
              onTap: widget.onTap,
              readOnly: widget.readOnly ?? false,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              onFieldSubmitted: widget.confirm,
              onChanged: widget.onChange,
              textInputAction: widget.confirm == null
                  ? TextInputAction.next
                  : TextInputAction.search,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                contentPadding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
                hintText: widget.label ?? Loc.searchHintText(),
                hintStyle: theme.inputDecorationTheme.hintStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12.sp,
                    ),

                // Borders
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.error, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.error, width: 2),
                ),

                // Fill color (transparent or theme)
                fillColor:
                widget.fillColor ?? theme.inputDecorationTheme.fillColor ?? Colors.transparent,
                filled: true,

                // Prefix Icon
                prefixIcon: widget.prefixIcon,

                // Suffix Icon (search / clear)
                suffixIcon: ValueListenableBuilder<bool>(
                  valueListenable: searchSuffixIcon,
                  builder: (context, showClear, _) => GestureDetector(
                    onTap: () {
                      if (showClear) {
                        widget.controller.clear();
                        widget.onControllerClear?.call();
                        widget.onTextIsClear?.call();
                      }
                    },
                    child: Icon(
                      showClear ? Icons.clear : Icons.search_rounded,
                      color: showClear
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.filter)
            IconButton.filled(
              onPressed: widget.onFilter,
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primary.withOpacity(0.1),
              ),
              icon: Picture(
                getAssetIcon('filter_icon.svg'),
                height: 15.h,
                color: colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
