import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:rasikh/core/widgets/picture.dart';

import 'package:size_config/size_config.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';

import '../../../config/navigation/nav.dart';
import '../../../config/theme/colors.dart';
import '../../../core/widgets/auth_stepper.dart';
import 'consultation_type_screen(2).dart';

class ChooseLawyerScreen extends StatefulWidget {
  const ChooseLawyerScreen({super.key});

  @override
  State<ChooseLawyerScreen> createState() => _ChooseLawyerScreenState();
}

class _ChooseLawyerScreenState extends State<ChooseLawyerScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;



    Future<void> showSortBottomSheet(BuildContext context) async {
      final theme = Theme.of(context);
      String? selectedOption = 'الأعلى تقييماً';

      final options = [
        'الأعلى تقييماً',
        'الأقل سعراً',
        'الأكثر خبرة',
        'الأقرب موقعاً',
        'المتاح الآن',
      ];

      await showModalBottomSheet(
        context: context,
        backgroundColor: theme.colorScheme.onSecondary,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close Button + Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الترتيب حسب',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(

                            decoration: BoxDecoration(  color: greyFA , shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () { Navigator.pop(context); },
                            ),
                          ),


                        ],
                      ),
                      GeneralDivider(height: 20.h,) ,

                      // Options
                      ...options.map(
                            (opt) => InkWell(
                              onTap: () {
                            setState(() => selectedOption = opt);
                                                      },
                              child: Padding(
                                padding:  EdgeInsets.symmetric(vertical: 5.h),
                                child: Container(
                                  height: 60.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: theme.dividerColor)
                                  ),
                                  child: Padding(
                                padding:  EdgeInsets.symmetric(vertical: 4.0 ,horizontal: 10.w),
                                child: Row(
                                  children: [
                                    Text(
                                      opt,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: selectedOption == opt
                                            ? theme.colorScheme.primary
                                            : theme.textTheme.bodyLarge?.color,
                                        fontWeight: selectedOption == opt
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    Spacer() ,
                                    Checkbox(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      side: BorderSide(
                                        color: theme.colorScheme.outline.withOpacity(0.5),
                                      ),
                                      activeColor: theme.colorScheme.primary,
                                      value: selectedOption == opt,
                                      onChanged: (val) => setState(() => selectedOption = opt),
                                    ),


                                  ],
                                ),
                                                          ),
                                ),
                              ),
                            ),
                      ),

                      const SizedBox(height: 12),

                      // Apply Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, selectedOption);
                          },
                          child: Text(
                            'تطبيق التصفية',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }
    Future<void> showCityBottomSheet(BuildContext context) async {
      final theme = Theme.of(context);
      String? selectedOption = 'الأعلى تقييماً';

      final cities = [
        'القاهرة',
        'الجيزة',
        'الإسكندرية',
        'المنصورة',
        'أسيوط',
        'الفيوم',
        'طنطا',
        'الزقازيق',
        'بورسعيد',
        'الأقصر',
        'أسوان',
        'السويس',
        'دمياط',
        'قنا',
        'بني سويف',
        'المنيا',
        'سوهاج',
        'كفر الشيخ',
        'مرسى مطروح',
        'العريش',
      ];


      await showModalBottomSheet(
        context: context,
        backgroundColor: theme.colorScheme.onSecondary,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close Button + Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الترتيب حسب',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(

                            decoration: BoxDecoration(  color: greyFA , shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () { Navigator.pop(context); },
                            ),
                          ),


                        ],
                      ),
                      GeneralDivider(height: 20.h,) ,
                      TextField(
                        controller: searchController,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: 'بحث عن مدينه محدده...',
                          hintStyle: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.hintColor),
                          prefixIcon: Padding(
                            padding:  EdgeInsets.all(15.0.h),
                            child: Picture(getAssetIcon("search.svg") , width:20.h,height: 20.h,),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.h),
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.h),
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.h),
                            borderSide: BorderSide(color: colorScheme.primary),
                          ),
                        ),
                      ),
                      Gap(10.h)  ,
                      // Options
                      Container(
                        height: 300.h,
                        child: ListView.separated(
                          itemCount: cities.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final opt = cities[index];
                            final selected = selectedOption == opt;

                            return InkWell(
                              onTap: () => setState(() => selectedOption = opt),
                              child: Container(
                                height: 60.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: theme.dividerColor),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.w),
                                child: Row(
                                  children: [
                                    Text(
                                      opt,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: selected
                                            ? theme.colorScheme.primary
                                            : theme.textTheme.bodyLarge?.color,
                                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    const Spacer(),
                                    Checkbox(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      side: BorderSide(
                                        color: theme.colorScheme.outline.withOpacity(0.5),
                                      ),
                                      activeColor: theme.colorScheme.primary,
                                      value: selected,
                                      onChanged: (val) => setState(() => selectedOption = opt),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ) ,


                      const SizedBox(height: 12),

                      // Apply Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, selectedOption);
                          },
                          child: Text(
                            'تطبيق التصفية',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }
    Future<void> showTypeBottomSheet(BuildContext context) async {
      final theme = Theme.of(context);
      String? selectedOption = 'الأعلى تقييماً';

      final types = [
       "الكل"  ,
        "محامي"  ,
        "محاميه"
      ];


      await showModalBottomSheet(
        context: context,
        backgroundColor: theme.colorScheme.onSecondary,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close Button + Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الترتيب حسب',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(

                            decoration: BoxDecoration(  color: greyFA , shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () { Navigator.pop(context); },
                            ),
                          ),


                        ],
                      ),
                      GeneralDivider(height: 20.h,) ,

                      // Options
                      Container(
                        height: 60.h,
                        child: ListView.separated(
                          itemCount: types.length,
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (_, __) => SizedBox(width: 10.w),
                          itemBuilder: (context, index) {
                            final opt = types[index];
                            final selected = selectedOption == opt;

                            return InkWell(
                              onTap: () => setState(() => selectedOption = opt),
                              child: Container(
                                height: 30.h,
                                width: 125.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: theme.dividerColor),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.w),
                                child: Row(
                                  children: [
                                    Text(
                                      opt,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: selected
                                            ? theme.colorScheme.primary
                                            : theme.textTheme.bodyLarge?.color,
                                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    const Spacer(),
                                    Checkbox(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      side: BorderSide(
                                        color: theme.colorScheme.outline.withOpacity(0.5),
                                      ),
                                      activeColor: theme.colorScheme.primary,
                                      value: selected,
                                      onChanged: (val) => setState(() => selectedOption = opt),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ) ,


                      const SizedBox(height: 12),

                      // Apply Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, selectedOption);
                          },
                          child: Text(
                            'تطبيق التصفية',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }



    return Scaffold(
      appBar: GeneralAppBar(
        title: "اختر المحامي",
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              Padding(
                padding:  EdgeInsets.symmetric(vertical: 24.h ),
                child: const AuthStepperWidget(activeStep: 4, totalSteps: 5),
              ),
              TextField(
                controller: searchController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ابحث عن المحامي المناسب...',
                  hintStyle: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.hintColor),
                  prefixIcon: Icon(Icons.search, color: theme.hintColor),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.h),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.h),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.h),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                ),
              ),
              Gap(12.h),

              // ---------------- Filter Row ----------------
              Container(
                height: 45.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      icon: "filter.svg",
                      title: 'الترتيب حسب',
                      onTap: ()
                      {
                        showSortBottomSheet(context) ;
                      },
                    ),

                    _FilterChip(
                      icon: "users.svg",
                      title: 'محامي أو محامية',
                      onTap: ()
                      {
                        showTypeBottomSheet(context) ;
                      },
                    ),
                    _FilterChip(
                      icon: "City.svg",
                      title: 'المدينه',
                      onTap: ()
                      {
                        showCityBottomSheet(context) ;
                      },
                    ),
                  ],
                ),
              ),
              Gap(20.h),

              // ---------------- Lawyers List ----------------
              Expanded(
                child: ListView.separated(

                  itemCount: 3,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    return LawyerCard(
                      name: 'عبدالله بن فهد الشمري',
                      city: 'جدة',
                      region: 'مكة المكرمة',
                      rating: 4.5,
                      specialization: 'القانون المدني',
                      experience: '2-4',
                      price: 1200,
                      imageUrl: 'https://amrlaw.com.sa/wp-content/uploads/2024/12/%D8%A7%D8%B3%D8%AA%D8%B4%D8%A7%D8%B1%D8%A9-%D9%82%D8%A7%D9%86%D9%88%D9%86%D9%8A%D8%A9-%D9%85%D9%87%D9%86%D9%8A%D8%A9-%D9%85%D9%86-%D9%85%D8%AD%D8%A7%D9%85%D9%8A-%D9%81%D9%8A-%D8%AC%D8%AF%D8%A9-%D8%A7%D9%84%D9%85%D9%85%D9%84%D9%83%D8%A9-%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9-%D8%A7%D9%84%D8%B3%D8%B9%D9%88%D8%AF%D9%8A%D8%A9.png',
                      available: true,
                      onConsult: () {
                        if(selectedTypeIndex == 2)
                        Nav.appointmentBookingScreen(context)  ;
                        else
                        Nav.paymentScreen(context)  ;
                      },
                    );
                  },
                )
                ,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Lawyer Card Widget
// -----------------------------------------------------------------------------


class LawyerCard extends StatelessWidget {
  final String name;
  final String city;
  final String region;
  final double rating;
  final String specialization;
  final String experience;
  final double price;
  final String imageUrl;
  final bool available;
  final VoidCallback onConsult;

  const LawyerCard({
    super.key,
    required this.name,
    required this.city,
    required this.region,
    required this.rating,
    required this.specialization,
    required this.experience,
    required this.price,
    required this.imageUrl,
    required this.available,
    required this.onConsult,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: ()
      {
        Nav.lawyerDetailsScreen(context) ; 
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(color: theme.dividerColor),

        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header Row (Photo, Name, Availability)
            Row(
              children: [
                /// Avatar
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    /// Lawyer Image
                    CircleAvatar(
                      radius: 35.w,
                     child: ClipRRect(borderRadius :BorderRadius.circular(1000.h) , child: Picture(imageUrl)),
                    ),

                    /// Online Status Dot
                    if (available)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 15.w,
                          height: 15.w,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).cardColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                    /// Rating Badge
                    Positioned(
                      bottom: -10.h,
                      left: 3.w,
                      right: 3.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal:2.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10.h),

                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                            SizedBox(width: 4.w),
                            Text(
                              rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontFamily: "almarai"
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ) ,

                Gap(12.w),

                /// Info (Name, Location)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap(4.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 16.w, color: theme.hintColor),
                          Gap(4.w),
                          Text(
                            '$city - $region',
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// Rating

              ],
            ),

            Gap(12.h),
            GeneralDivider(height: 20.h,),

            /// Details Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoColumn(
                  title: 'سنوات الخبرة',
                  value: experience,
                ),
                Container(height: 40.h,width: 1, color: theme.dividerColor,) ,
                _InfoColumn(
                  title: 'التخصص',
                  value: specialization,
                ),
                Container(height: 40.h,width: 1   , color: theme.dividerColor,) ,
                _InfoColumn(
                  title: 'سعر الإستشارة',
                  value: '${price.toStringAsFixed(0)} ريال',
                  valueColor: theme.colorScheme.primary,
                ),
              ],
            ),


            GeneralDivider(height: 20.h,),


            /// Button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD1B28E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.h),
                  ),
                ),
                onPressed: onConsult,
                child: const Text(
                  'استشر المحامي',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoColumn({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: textTheme.bodySmall),
        Gap(4.h),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}


// -----------------------------------------------------------------------------
// Filter Chip Widget
// -----------------------------------------------------------------------------
class _FilterChip extends StatelessWidget {
  final String  icon;
  final String title;
  final VoidCallback onTap;

  const _FilterChip({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.0.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(10.h),

          ),
          child: Row(
            children: [
              Picture(getAssetIcon(icon) , color: theme.colorScheme.onSurface,),
              Gap(4.w),
              Text(
                title,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurface),
              ),
              Gap(4.w),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: greyF4,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                   Icons.keyboard_arrow_down,
                  size: 13,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
