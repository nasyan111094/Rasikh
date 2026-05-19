import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';
import '../../../core/widgets/auth_stepper.dart';

class ChooseSpecialtyScreen extends StatefulWidget {
  const ChooseSpecialtyScreen({Key? key}) : super(key: key);

  @override
  State<ChooseSpecialtyScreen> createState() => _ChooseSpecialtyScreenState();
}

class _ChooseSpecialtyScreenState extends State<ChooseSpecialtyScreen> {
  // -------------------------------
  // 🔹 Data
  // -------------------------------
  String? selectedMainCategory;
  final Set<String> selectedSubcategories = {};
  final TextEditingController searchController = TextEditingController();

  final List<String> quickFilters = ['تنفيذ', 'تجارية', 'أحوال', 'مرورية'];

  final List<Map<String, dynamic>> mainCategories = [
    {
      'title': 'قضايا تجارية',
      'description':
      'قضايا تجارية، نزاعات ومعاملات الشركات والتجارة وحماية الحقوق التجارية.',
      'icon': Icons.business_center_rounded,
      'subcategories': [
        'إثبات شراكة',
        'نزاعات شراكة',
        'بيع شراء',
        'مقاولات',
        'سمسرة',
        'تقسيط',
        'استيراد',
        'نقل',
        'وكالة تجارية',
      ],
    },
    {
      'title': 'حقوق عامة',
      'description':
      'قضايا تتعلق بالحقوق العامة والعلاقات القانونية بين الأفراد والجهات العامة.',
      'icon': Icons.gavel_rounded,
      'subcategories': [
        'مطالبات مالية',
        'تعويضات',
        'عقود مدنية',
        'ملكية فكرية',
      ],
    },
  ];

  // -------------------------------
  // 🔹 Computed
  // -------------------------------
  bool get canProceed =>
      selectedMainCategory != null && selectedSubcategories.isNotEmpty;

  List<Map<String, dynamic>> get filteredCategories {
    final query = searchController.text.trim();
    if (query.isEmpty) return mainCategories;

    return mainCategories
        .where((cat) =>
    cat['title'].toString().contains(query) ||
        (cat['subcategories'] as List<String>)
            .any((s) => s.contains(query)))
        .toList();
  }

  // -------------------------------
  // 🔹 UI
  // -------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: GeneralAppBar(title: "إختر التخصص"),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              AuthStepperWidget( activeStep: 1, totalSteps: 5,)   ,
              Gap(40.h) ,
              _buildSearchBar(theme),
              const Gap(10),
              Row(
                children: [
                  _buildQuickFilters(),
                ],
              ),
              const Gap(10),
              Expanded(child: _buildCategoryList(theme)),
              const Gap(12),
              _buildNextButton(theme),
              const Gap(12),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------
  // 🔹 Widgets
  // -------------------------------

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      controller: searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'ادخل كلمة مفتاحية مثل تنفيذ أو أموال ...',
        prefixIcon: const Icon(Icons.search_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: quickFilters
            .map((f) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child:GestureDetector(
            onTap: () {
              setState(() {
                searchController.text = f;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.transparent, // 🔹 fully transparent background
                borderRadius: BorderRadius.circular(40), // 🔹 pill shape
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  width: 1.2,
                ),
              ),
              child: Text(
                f,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          )


          ,
        ))
            .toList(),
      ),
    );
  }

  Widget _buildCategoryList(ThemeData theme) {
    if (filteredCategories.isEmpty) {
      return Center(
        child: Text(
          'لم يتم العثور على نتائج',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        final title = category['title'] as String;
        final isExpanded = selectedMainCategory == title;
        final subcategories = category['subcategories'] as List<String>;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isExpanded
                  ? theme.colorScheme.primary.withOpacity(0.6)
                  : theme.dividerColor.withOpacity(0.3),
            ),
          ),
          child: Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: PageStorageKey(title),
              initiallyExpanded: isExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  selectedMainCategory = expanded ? title : null;
                  if (!expanded) selectedSubcategories.clear();
                });
              },

              trailing: Radio<String>(
              value: title,
              groupValue: selectedMainCategory,
              onChanged: (v) {
                setState(() {
                  selectedMainCategory = v;
                  selectedSubcategories.clear();
                });
              },
            ),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(5.h),
                      decoration: BoxDecoration(border: Border.all(color: isExpanded
                          ? theme.colorScheme.primary.withOpacity(0.6)
                          : theme.dividerColor,) , shape: BoxShape.circle),
                      child: Picture(getAssetIcon("chat.svg" ) , width: 40.h,height: 40.h,color: isExpanded
                          ? theme.colorScheme.primary.withOpacity(0.6)
                          : theme.dividerColor,)) ,
                  const Gap(6),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isExpanded
                          ? theme.colorScheme.primary
                          : theme.textTheme.titleMedium?.color,
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  category['description'],
                  style:
                  theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                ),
              ),
              children: [
                if (subcategories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(8),
                        Text(
                          'اختر التخصص الفرعي',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'يمكنك اختيار أكثر من تخصص إذا لزم الأمر.',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.hintColor),
                        ),
                        const Gap(8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: subcategories.map((sub) {
                            final selected =
                            selectedSubcategories.contains(sub);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selected) {
                                    selectedSubcategories.remove(sub);
                                  } else {
                                    selectedSubcategories.add(sub);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? theme.colorScheme.primary.withOpacity(0.15)
                                      : Colors.transparent, // background transparent when not selected
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: selected
                                        ? theme.colorScheme.primary.withOpacity(0.6)
                                        : theme.dividerColor.withOpacity(0.3),
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  sub,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: selected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                    fontWeight:
                                    selected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            )
                            ;
                          }).toList(),
                        ),
                        const Gap(12),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity, // 🔹 full-width button
      child: ElevatedButton(
        onPressed: canProceed
            ? () {
           Nav.selectConsulationType(context) ;
        }
            : null,
        style: ButtonStyle(
          // ✅ Use the current theme colors dynamically
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                (states) {
              if (states.contains(WidgetState.disabled)) {
                return theme.colorScheme.surfaceContainerHighest
                    .withOpacity(0.4);
              }
              return theme.colorScheme.primary;
            },
          ),
          foregroundColor: WidgetStateProperty.all(
            theme.colorScheme.onPrimary,
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 14),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          elevation: WidgetStateProperty.all(0), // flat modern look
        ),
        child: Text(
          'التالي',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

}
