import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/theme/font_weights.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:size_config/size_config.dart';

import '../../../config/theme/colors.dart';
import '../../../core/widgets/picture.dart';

class LawyerDetailsScreen extends StatefulWidget {
  const LawyerDetailsScreen({Key? key}) : super(key: key);

  @override
  State<LawyerDetailsScreen> createState() => _LawyerDetailsScreenState();
}

class _LawyerDetailsScreenState extends State<LawyerDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> reviews = [
    {
      'id': 1,
      'rating': 4.8,
      'author': 'نواف الحربي',
      'text': 'محامي محترف جدا، رد على كل التفاصيل القانونية بطريقة سهلة وواضحة.',
      'avatar': 'https://i.pravatar.cc/150?img=12'
    },
    {
      'id': 2,
      'rating': 4.7,
      'author': 'محمد بن سعود القحطاني',
      'text': 'سرعة في الرد والتعامل وخبرته واضحة بالتفاصيل وهو في أي مشكلة تحتاجه.',
      'avatar': 'https://i.pravatar.cc/150?img=13'
    },
    {
      'id': 3,
      'rating': 4.7,
      'author': 'ناصر بن علي الحربي',
      'text': 'خدمة ممتازة واحترافية عالية، ساعدني في حل قضيتي.',
      'avatar': 'https://i.pravatar.cc/150?img=14'
    }
  ];

  final List<String> specializations = [
    'تسويق',
    'استشراف',
    'أعمال',
    'إفلاس وتركات',
    'الأحوال الشخصية',
    'عقارات',
    'مقاولات',
    'جنائي',
    'إدارية تجارية',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(

      appBar: GeneralAppBar(
        title: "تفاصيل المحامي",
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Gap(16.h),
                  _buildProfileCard(theme, colorScheme),
                  Expanded(child: _buildTabsAndContent(theme, colorScheme)),
                  Gap(24.h),
                ],
              ),
            ),
          ),
          _buildBookButton(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(16.h),

      ),
      child: Column(
        children: [
          Container(
            height: 70.h,
            width: double.infinity,
            child: Row(
              children: [
                /// Avatar
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    /// Lawyer Image
                    CircleAvatar(
                      radius: 35.w,
                      child: ClipRRect(borderRadius :BorderRadius.circular(1000.h) , child: Picture("https://amrlaw.com.sa/wp-content/uploads/2024/12/%D8%A7%D8%B3%D8%AA%D8%B4%D8%A7%D8%B1%D8%A9-%D9%82%D8%A7%D9%86%D9%88%D9%86%D9%8A%D8%A9-%D9%85%D9%87%D9%86%D9%8A%D8%A9-%D9%85%D9%86-%D9%85%D8%AD%D8%A7%D9%85%D9%8A-%D9%81%D9%8A-%D8%AC%D8%AF%D8%A9-%D8%A7%D9%84%D9%85%D9%85%D9%84%D9%83%D8%A9-%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9-%D8%A7%D9%84%D8%B3%D8%B9%D9%88%D8%AF%D9%8A%D8%A9.png")),
                    ),

                    /// Online Status Dot
                    if (true)
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
                              3.5.toStringAsFixed(1),
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
                        'عبدالله بن فهد الشمري',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap(10.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 16.w, color: theme.hintColor),
                          Gap(4.w),
                          Text(
                            ' جده - مكة المكرمه',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
          ) ,
          GeneralDivider(height: 40.h,) ,
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(theme, 'سنوات الخبرة', '4.2'),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: theme.dividerColor.withOpacity(0.3),
              ),
              Expanded(
                child: _buildInfoItem(theme, 'يبدأ بـ', '1200 ريال'),
              ),
            ],
          ),
          GeneralDivider(height: 20.h,) ,
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(ThemeData theme, ColorScheme colorScheme) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 68.w,
          height: 68.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.dividerColor.withOpacity(0.1), width: 2),
            image: const DecorationImage(
              image: NetworkImage('https://i.pravatar.cc/150?img=33'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              color: const Color(0xFF34C759),
              shape: BoxShape.circle,
              border: Border.all(color: theme.cardColor, width: 3),
            ),
          ),
        ),
        Positioned(
          bottom: -4.h,
          right: -4.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(6.h),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'متاح الآن',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 13,
            color: theme.hintColor,
          ),
          textAlign: TextAlign.center,
        ),
        Gap(6.h),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabsAndContent(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: colorScheme.primary,
              padding: EdgeInsets.zero,
              unselectedLabelColor: theme.hintColor,
              labelStyle: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).primaryColor , fontWeight: fw900),
              unselectedLabelStyle: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.grey),
              tabs: const [
                Tab(text: 'التقييمات'),
                Tab(text: 'الخبرات والمؤهلات'),
                Tab(text: 'الملف الشخصي'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReviewsContent(theme, colorScheme),
                _buildExperienceContent(theme, colorScheme),
                _buildAboutContent(theme, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsContent(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(20.h),
          _buildRatingSummary(theme, colorScheme),
          Gap(20.h),
          Text(
            'التقييمات (${reviews.length * 10})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(20.h),
          ...reviews.map((review) => Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: _buildReviewItem(theme, colorScheme, review),
          )),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(
              '4.5',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
                height: 1,
              ),
            ),
            Gap(4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                return Icon(
                  index < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                  color: colorScheme.primary,
                  size: 22,
                );
              }),
            ),
            Gap(6.h),
            Text(
              'بناءً على 32 تقييماً',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: theme.hintColor,
              ),
            ),
          ],
        ),
        Gap(24.w),
        Expanded(
          child: Row(
            children: [
              Column(
                children: List.generate(5, (index) {
                  final barIndex = 4 - index;
                  final widthFactors = [0.95, 0.85, 0.65, 0.45, 0.25];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 7.h),
                    child: Container(
                      width: 220.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.h),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: widthFactors[barIndex],
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(4.h),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        Gap(10.w),
      ],
    );
  }

  Widget _buildReviewItem(ThemeData theme, ColorScheme colorScheme, Map<String, dynamic> review) {
    return Container(

      decoration: BoxDecoration
        (
        border: Border.all(color: greyFA),
        borderRadius: BorderRadius.circular(10.h) ,
      ),

      child: Padding(
        padding: EdgeInsets.all(10.0.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25.w,
              backgroundImage: NetworkImage(review['avatar']),
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Text(
                        review['author'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(

                          borderRadius: BorderRadius.circular(10.h),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              review['rating'].toString(),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontFamily: "cairo",
                                fontSize: 14,
                              ),
                            ),
                            Gap(4.w),
                            Icon(
                              Icons.star_rounded,
                              color: colorScheme.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap(6.h) ,
                  Text(
                    review['text'],
                    textAlign: TextAlign.right,
                    style: theme.textTheme.labelMedium?.copyWith(


                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceContent(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الخبرات السابقة',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
          Gap(16.h),
          Container(
            padding: EdgeInsets.all(10.h),
            decoration: BoxDecoration
              (
                borderRadius: BorderRadius.circular(10.h) ,
              border: Border.all(color: greyFA) ,
              ),
            child: Text(
              'عمل كمستشار قانوني في مكتب العدالة للاستشارات القانونية لمدة 5 سنوات حيث قدم الاستشارات في مجالات العقود التجارية وحل النزاعات المدنية.',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                height: 1.7,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
              ),
            ),
          ),
          GeneralDivider(height: 20.h,) ,
  
        ],
      ),
    );
  }

  Widget _buildAboutContent(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical : 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نبذة عن المحامي',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
          Gap(16.h),
          Text(
            'محامي متخصص يقدم استشارات قانونية شاملة للأفراد والشركات في مجالات متنوعة من القانون. يمتلك خبرة واسعة في حل القضايا المعقدة وإعداد العقود، مع التركيز على تحقيق أفضل النتائج للعملاء بطريقة سريعة وفعالة.',
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              height: 1.5,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
            ),
          ),
          Gap(28.h),
          Text(
            'التخصصات',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
          Gap(16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 10.h,
            alignment: WrapAlignment.start,
            children: specializations.map((spec) => _buildSpecChip(theme, colorScheme, spec)).toList(),
          ),
          Gap(28.h),
          Text(
            'رخصة مزاولة المهنة',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
          Gap(16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16.h),
            ),
            child: Column(
              children: [
                Image.network(
                  'https://media.licdn.com/dms/image/v2/D4E22AQERnlw_egZWWg/feedshare-shrink_800/feedshare-shrink_800/0/1705996372601?e=2147483647&v=beta&t=qsZ2QXTD4G_7PEXjNbDCnrHtNV30O1fs0JiMqhtEOUY',
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
                Gap(12.h),
                Text(
                  'وزارة العدل - المملكة العربية السعودية',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: theme.hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip(ThemeData theme, ColorScheme colorScheme, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? const Color(0xFFF5F5F5)
            : theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24.h),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildBookButton(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 54.h,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم الحجز بنجاح!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.h),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.h),
              ),
            ),
            child: const Text(
              'احجز الآن',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}