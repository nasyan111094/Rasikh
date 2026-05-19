import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

class SearchableDropdown extends StatefulWidget {
  final List<String> items;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? prefixIconPath;
  final bool showPrefixIcon;
  final String label;
  final bool enableSearch;
  final String? Function(String?)? validator;

  const SearchableDropdown({
    super.key,
    required this.items,
    required this.controller,
    required this.label,
    required this.enableSearch,
    this.validator,
    required this.hint,
    required this.onChanged,
    this.prefixIconPath,
    this.showPrefixIcon = true,
  });

  @override
  _SearchableDropdownState createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  void _showDialog() async {
    final selectedItem = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Search',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: _SearchDialog(
            items: widget.items,
            enableSearch: widget.enableSearch,
            myLabel: widget.label,
          ),
        ),
      ),
      transitionBuilder: (_, animation, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );

    if (selectedItem != null) {
      setState(() => widget.controller.text = selectedItem);
      widget.onChanged(selectedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(widget.label.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
        [
          Text(widget.label, style: getMediumBlack16Style()),
          Gap(10.h),
        ],) ,
        SizedBox(
          height: 60.h,
          child: TextFormField(
            controller: widget.controller,
            readOnly: true,
            onTap: _showDialog,
            validator: widget.validator,

            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: getRegularGray16Style(),
              filled: false,
              fillColor: Colors.transparent,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.h),
                borderSide: BorderSide(color: primary.withOpacity(0.1)),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.h),
                borderSide: BorderSide(color: primary.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.h),
                borderSide: BorderSide(color: primary),
              ),
              prefixIcon: widget.showPrefixIcon
                  ? (widget.prefixIconPath != null
                  ? Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Picture(getAssetIcon(widget.prefixIconPath!) , color: greyIconColors,),
              )
                  : const Icon(Icons.search))
                  : null,
              suffixIcon: const Icon(Icons.expand_more),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchDialog extends StatefulWidget {
  final List<String> items;
  final bool enableSearch;
  final String myLabel;

  const _SearchDialog({
    required this.items,
    required this.enableSearch,
    required this.myLabel,
  });

  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  late List<String> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.items); // Create a copy of items
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    setState(() {
      _filteredItems = widget.items
          .where((item) =>
          item.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ensure dialog takes full width within margin
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 100.h, // Minimum height for small content
          maxHeight: MediaQuery.of(context).size.height * 0.6, // Max height: 60% of screen
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Adjust height to content
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.myLabel,
                style: getBoldPrimary16Style(),
                textAlign: TextAlign.center,
              ),
              Gap(12.h),
              if (widget.enableSearch)
                TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: "بحث...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              Gap(12.h),
              Expanded(
                child: _buildItemList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemList() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _filteredItems.isEmpty
          ? const Center(
        key: ValueKey('empty'),
        child: Text("لم يتم العثور على نتائج"),
      )
          : SingleChildScrollView(
        key: const ValueKey('list'),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: List.generate(
            _filteredItems.length,
                (index) => Column(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context, _filteredItems[index]),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Text(
                        _filteredItems[index],
                        style: getMediumBlack16Style(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                if (index < _filteredItems.length - 1)
                  Divider(
                    height: 1,
                    color: primary.withOpacity(0.1),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
