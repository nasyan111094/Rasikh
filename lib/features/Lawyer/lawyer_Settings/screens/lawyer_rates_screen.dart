import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart'; // 💥
import 'package:rasikh/core/theme/font_weights.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/features/Lawyer/lawyer_Settings/widgets/dialogs/report_comment_dialog.dart';
import 'package:size_config/size_config.dart';
import '../../../../config/theme/colors.dart';
import '../../../../core/widgets/picture.dart';

class LawyerRatesScreen extends StatefulWidget {
  const LawyerRatesScreen({Key? key}) : super(key: key);

  @override
  State<LawyerRatesScreen> createState() => _LawyerRatesScreenState();
}

class _LawyerRatesScreenState extends State<LawyerRatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> reviews = [
    {
      'id': 1,
      'rating': 4.8,
      'author': 'نواف الحربي',
      'text': 'محامي محترف جدا، رد على كل التفاصيل القانونية بطريقة سهلة وواضحة.',
      'avatar': 'https://i.pravatar.cc/150?img=12',
      'date': '16 / 10 / 2025',
    },
    {
      'id': 2,
      'rating': 4.7,
      'author': 'محمد بن سعود القحطاني',
      'text': 'سرعة في الرد والتعامل وخبرته واضحة بالتفاصيل وهو في أي مشكلة تحتاجه.',
      'avatar': 'https://i.pravatar.cc/150?img=13',
      'date': '18 / 10 / 2025',
    },
    {
      'id': 3,
      'rating': 4.7,
      'author': 'ناصر بن علي الحربي',
      'text': 'خدمة ممتازة واحترافية عالية، ساعدني في حل قضيتي.',
      'avatar': 'https://i.pravatar.cc/150?img=14',
      'date': '20 / 10 / 2025',
    },    {
      'id': 4,
      'rating': 4.7,
      'author': 'ناصر بن علي الحربي',
      'text': 'خدمة ممتازة واحترافية عالية، ساعدني في حل قضيتي.',
      'avatar': 'https://i.pravatar.cc/150?img=14',
      'date': '20 / 10 / 2025',
    },    {
      'id': 5,
      'rating': 4.7,
      'author': 'ناصر بن علي الحربي',
      'text': 'خدمة ممتازة واحترافية عالية، ساعدني في حل قضيتي.',
      'avatar': 'https://i.pravatar.cc/150?img=14',
      'date': '20 / 10 / 2025',
    },    {
      'id': 6,
      'rating': 4.7,
      'author': 'ناصر بن علي الحربي',
      'text': 'خدمة ممتازة واحترافية عالية، ساعدني في حل قضيتي.',
      'avatar': 'https://i.pravatar.cc/150?img=14',
      'date': '20 / 10 / 2025',
    },    {
      'id': 7,
      'rating': 4.7,
      'author': 'ناصر بن علي الحربي',
      'text': 'خدمة ممتازة واحترافية عالية، ساعدني في حل قضيتي.',
      'avatar': 'https://i.pravatar.cc/150?img=14',
      'date': '20 / 10 / 2025',
    },    {
      'id': 8,
      'rating': 4.7,
      'author': 'ناصر بن علي الحربي',
      'text': 'خدمة ممتازة واحترافية عالية، ساعدني في حل قضيتي.',
      'avatar': 'https://i.pravatar.cc/150?img=14',
      'date': '20 / 10 / 2025',
    },    {
      'id': 9,
      'rating': 4.7,
      'author': 'ناصر بن علي الحربي',
      'text': 'خدمة ممتازة واحترافية عالية، ساعدني في حل قضيتي.',
      'avatar': 'https://i.pravatar.cc/150?img=14',
      'date': '20 / 10 / 2025',
    },
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
      appBar: const GeneralAppBar(title: "تقييماتي"),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Gap(40.h),

                    // 💫 Rating summary enters with shimmer and slight bounce
                    _buildRatingSummary(theme, colorScheme)
                        .animate()
                        .fadeIn(duration: 700.ms)
                        .slideY(begin: 0.3, end: 0)
                        .then()
                        .shimmer(duration: 1.seconds),

                    Gap(30.h),

                    Text(
                      'التقييمات الأخيره',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap(10.h),
                    Expanded(
                      // ✅ شاشة تدخل بحركة لطيفة: fade + slide + scale
                      child: _buildReviewsContent(theme, colorScheme)
                          .animate()
                          .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                          .slideY(begin: 0.2, end: 0, duration: 700.ms)
                          .scaleXY(begin: 0.97, end: 1.0, duration: 500.ms),
                    ),
                    Gap(24.h),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsContent(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [



          // 🎯 كل review يدخل واحد وراء التاني بتأخير بسيط وانيميشن ناعم
          ...reviews.asMap().entries.map((entry) {
            final i = entry.key;
            final review = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 5.h),
              child: _buildReviewItem(theme, colorScheme, review)
                  .animate(delay: (i * 200).ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.4, end: 0, curve: Curves.easeOut)
                  .scaleXY(begin: 0.9, end: 1.0, duration: 400.ms),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(ThemeData theme, ColorScheme colorScheme) {
    return Row(
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
          child: Column(
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
        ),
      ],
    );
  }

  Widget _buildReviewItem(
      ThemeData theme, ColorScheme colorScheme, Map<String, dynamic> review) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: const Color(0xFFF3F3F3)),

        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25.w,
                            backgroundImage: NetworkImage(review['avatar']),
                          )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scaleXY(
                            begin: 1,
                            end: 1.05,
                            duration: 800.ms,
                            curve: Curves.easeInOut,
                          ), // نبضة خفيفة على الصورة
                          Gap(6.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['author'],
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                ),
                              ),
                              Gap(5),
                              Row(
                                children: [
                                  Picture(getAssetIcon("Calendar.svg"),
                                      width: 20.w, height: 20.h),
                                  Gap(4.w),
                                  Text(
                                    review['date'],
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                      fontFamily: "Cairo",
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Picture(getAssetIcon("golden_start.svg"),
                              width: 20.w, height: 20.h),
                          Gap(4.w),
                          Text(
                            review['rating'].toString(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontFamily: "Cairo",
                              fontSize: 14.sp,
                            ),
                          ),
                          Gap(25.w),
                          WarningButton(onTap: () {
                            showReportDialog(context);
                          }),
                        ],
                      ),
                    ],
                  ),
                  Gap(8.h),
                  Text(
                    review['text'],
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                      fontSize: 13.sp,
                      height: 1.4,
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
}

class WarningButton extends StatelessWidget {
  final VoidCallback onTap;

  const WarningButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.w),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 20.w,
            )
            // 💢 عند الضغط تهتز بشكل ناعم
                .animate(onPlay: (c) => c.forward(from: 0))
                .shakeX(
                hz: 4,
                duration: 400.ms,
                curve: Curves.elasticInOut,
                amount: 8),
          ),
        ),
      ),
    );
  }
}
