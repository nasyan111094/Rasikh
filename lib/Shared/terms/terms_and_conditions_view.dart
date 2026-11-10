import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:size_config/size_config.dart';

import 'terms_and_conditions_data.dart';

const _brandGold = Color(0xffB29569);
const _brandGreen = Color(0xff1C3522);

/// Shared, presentation-ready view for the platform's legal documents.
///
/// Used by both the full screen page and the modal bottom sheet so the
/// wording and the design always stay in sync.
class TermsAndConditionsView extends StatelessWidget {
  const TermsAndConditionsView({
    super.key,
    this.isSheet = false,
  });

  final bool isSheet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Container(
          color: theme.scaffoldBackgroundColor,
          child: Column(
            children: [
              if (isSheet) _SheetHeader() else const _HeroHeader(),
              _TabSelector(isSheet: isSheet),
              Expanded(
                child: TabBarView(
                  children: [
                    _TermsDocumentBody(
                      document: termsForClients,
                      isSheet: isSheet,
                    ),
                    _TermsDocumentBody(
                      document: termsForServiceProviders,
                      isSheet: isSheet,
                    ),
                  ],
                ),
              ),
              if (isSheet)
                Container(
                  height: 1,
                  color: cs.outlineVariant.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Headers
// ─────────────────────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xff142718),
            _brandGreen,
            Color(0xff2A4A34),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _brandGreen.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -18.w,
            bottom: -26.h,
            child: Icon(
              Icons.balance_rounded,
              size: 118.sp,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 66.w,
                  height: 66.w,
                  fit: BoxFit.cover,
                ),
              ),
              Gap(14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Loc.termsBrandName(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _brandGold,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                        height: 1.5,
                      ),
                    ),
                    Gap(4.h),
                    Text(
                      Loc.termsAndConditions(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 21.sp,
                        height: 1.3,
                      ),
                    ),
                    Gap(8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 14.sp,
                          color: _brandGold,
                        ),
                        Gap(4.w),
                        Flexible(
                          child: Text(
                            Loc.termsLegalDocument(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 10.5.sp,
                            ),
                          ),
                        ),
                        Container(
                          width: 3,
                          height: 3,
                          margin: EdgeInsets.symmetric(horizontal: 7.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            Loc.termsLastUpdated(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 10.5.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Gap(10.h),
        Container(
          width: 42.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: cs.outlineVariant.withOpacity(0.65),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 10.h),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 40.w,
                  height: 40.w,
                  fit: BoxFit.cover,
                ),
              ),
              Gap(10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Loc.termsAndConditions(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    Gap(2.h),
                    Text(
                      Loc.termsLastUpdated(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10.5.sp,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              Gap(8.w),
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 19.sp,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: cs.outlineVariant.withOpacity(0.4),
        ),
      ],
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({required this.isSheet});

  final bool isSheet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.w,
        isSheet ? 12.h : 8.h,
        16.w,
        8.h,
      ),
      child: Container(
        height: 44.h,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color:
              isDark ? Colors.white.withOpacity(0.06) : const Color(0xffF4F1EA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : _brandGold.withOpacity(0.14),
          ),
        ),
        child: TabBar(
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: isDark ? const Color(0xff2A4A34) : _brandGreen,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: _brandGreen.withOpacity(0.16),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: EdgeInsets.zero,
          splashBorderRadius: BorderRadius.circular(10),
          labelColor: Colors.white,
          unselectedLabelColor: cs.onSurfaceVariant,
          labelStyle: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 12.5.sp,
          ),
          unselectedLabelStyle: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 12.5.sp,
          ),
          tabs: [
            Tab(
              height: 36.h,
              text: Loc.termsCustomersTab(),
            ),
            Tab(
              height: 36.h,
              text: Loc.termsProvidersTab(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Document body
// ─────────────────────────────────────────────────────────────────────────────

class _TermsDocumentBody extends StatefulWidget {
  const _TermsDocumentBody({
    required this.document,
    required this.isSheet,
  });

  final TermsDocument document;
  final bool isSheet;

  @override
  State<_TermsDocumentBody> createState() => _TermsDocumentBodyState();
}

class _TermsDocumentBodyState extends State<_TermsDocumentBody>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _articleKeys = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    for (final article in widget.document.articles) {
      _articleKeys[article.number] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _jumpToArticle(int number) {
    final target = _articleKeys[number]?.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
      alignment: 0.04,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SelectionArea(
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          16.w,
          widget.isSheet ? 12.h : 4.h,
          16.w,
          28.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PreambleCard(paragraphs: widget.document.preamble),
            Gap(12.h),
            _TableOfContentsCard(
              articles: widget.document.articles,
              onArticleTap: _jumpToArticle,
            ),
            Gap(12.h),
            for (final article in widget.document.articles)
              Padding(
                key: _articleKeys[article.number],
                padding: EdgeInsets.only(bottom: 12.h),
                child: _ArticleCard(article: article),
              ),
            const _DocumentFooter(),
          ],
        ),
      ),
    );
  }
}

class _PreambleCard extends StatelessWidget {
  const _PreambleCard({required this.paragraphs});

  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            _brandGold.withOpacity(0.12),
            cs.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _brandGold.withOpacity(0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: _brandGold.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 18.sp,
                  color: _brandGold,
                ),
              ),
              Gap(10.w),
              Text(
                Loc.termsIntroduction(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          for (final paragraph in paragraphs) ...[
            Gap(10.h),
            Text(
              paragraph,
              textAlign: TextAlign.justify,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12.8.sp,
                height: 1.95,
                color: cs.onSurface.withOpacity(0.86),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TableOfContentsCard extends StatelessWidget {
  const _TableOfContentsCard({
    required this.articles,
    required this.onArticleTap,
  });

  final List<TermsArticle> articles;
  final ValueChanged<int> onArticleTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 2.h),
          childrenPadding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
          iconColor: _brandGold,
          collapsedIconColor: cs.onSurfaceVariant,
          leading: Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: _brandGreen.withOpacity(
                theme.brightness == Brightness.dark ? 0.5 : 0.08,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.format_list_numbered_rounded,
              size: 18.sp,
              color: theme.brightness == Brightness.dark
                  ? _brandGold
                  : _brandGreen,
            ),
          ),
          title: Text(
            Loc.termsTocTitle(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 3.h),
            child: Text(
              Loc.termsTocHint(articles.length),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11.sp,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          children: [
            Wrap(
              spacing: 7.w,
              runSpacing: 7.h,
              children: [
                for (final article in articles)
                  _TocChip(
                    article: article,
                    onTap: () => onArticleTap(article.number),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TocChip extends StatelessWidget {
  const _TocChip({required this.article, required this.onTap});

  final TermsArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: _brandGold.withOpacity(
            theme.brightness == Brightness.dark ? 0.14 : 0.09,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _brandGold.withOpacity(0.2)),
        ),
        child: Text(
          '${article.number}. ${article.title}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10.8.sp,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});

  final TermsArticle article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    var numberedIndex = 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : cs.outlineVariant.withOpacity(0.55),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xffC9AE7E),
                        _brandGold,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: _brandGold.withOpacity(0.25),
                        blurRadius: 9,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${article.number}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ),
                Gap(11.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'المادة ${termsArticleOrdinal(article.number)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _brandGold,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5.sp,
                        ),
                      ),
                      Gap(2.h),
                      Text(
                        article.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5.sp,
                          color: cs.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: cs.outlineVariant.withOpacity(isDark ? 0.3 : 0.4),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.intro != null) ...[
                  Text(
                    article.intro!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.5.sp,
                      height: 1.8,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Gap(10.h),
                ],
                for (final clause in article.clauses)
                  _ClauseView(
                    clause: clause,
                    number: clause.numbered ? ++numberedIndex : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClauseView extends StatelessWidget {
  const _ClauseView({required this.clause, required this.number});

  final TermsClause clause;
  final int? number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (clause.term != null) {
      return Padding(
        padding: EdgeInsets.only(bottom: 9.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: _brandGold.withOpacity(
              theme.brightness == Brightness.dark ? 0.08 : 0.07,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _brandGold.withOpacity(0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clause.term!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5.sp,
                  color: theme.brightness == Brightness.dark
                      ? _brandGold
                      : _brandGreen,
                ),
              ),
              Gap(3.h),
              Text(
                clause.text,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12.2.sp,
                  height: 1.8,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (number == null) {
      return Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Text(
          clause.text,
          textAlign: TextAlign.justify,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12.8.sp,
            height: 1.95,
            color: cs.onSurface.withOpacity(0.88),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 9.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            margin: EdgeInsets.only(top: 1.h),
            decoration: BoxDecoration(
              color: _brandGold.withOpacity(
                theme.brightness == Brightness.dark ? 0.16 : 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _brandGold,
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
          Gap(9.w),
          Expanded(
            child: Text(
              clause.text,
              textAlign: TextAlign.justify,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12.6.sp,
                height: 1.9,
                color: cs.onSurface.withOpacity(0.88),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentFooter extends StatelessWidget {
  const _DocumentFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        Gap(4.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                _brandGreen,
                Color(0xff2A4A34),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.verified_user_rounded,
                      size: 18.sp,
                      color: _brandGold,
                    ),
                  ),
                  Gap(10.w),
                  Expanded(
                    child: Text(
                      Loc.termsAcceptanceTitle(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
              Gap(10.h),
              Text(
                Loc.termsAcceptanceNote(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 11.8.sp,
                  height: 1.9,
                ),
              ),
              Gap(12.h),
              Divider(
                color: Colors.white.withOpacity(0.16),
                height: 1,
                thickness: 1,
              ),
              Gap(12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.translate_rounded,
                    size: 15.sp,
                    color: _brandGold,
                  ),
                  Gap(7.w),
                  Expanded(
                    child: Text(
                      Loc.termsArabicReference(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.68),
                        fontSize: 10.8.sp,
                        height: 1.7,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Gap(12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.update_rounded,
              size: 12.sp,
              color: cs.onSurfaceVariant,
            ),
            Gap(5.w),
            Text(
              '${Loc.termsLastUpdated()} • ${Loc.termsVersion()}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10.sp,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Gap(4.h),
      ],
    );
  }
}
