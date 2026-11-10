import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rasikh/Shared/terms/terms_and_conditions_screen.dart';
import 'package:rasikh/core/theme/theme.dart';
import 'package:size_config/size_config.dart';

Future<void> _loadFonts() async {
  final loader = FontLoader('Abel');
  for (final file in const [
    'assets/fonts/taja/Tajawal-Regular.ttf',
    'assets/fonts/taja/Tajawal-Medium.ttf',
    'assets/fonts/taja/Tajawal-Bold.ttf',
    'assets/fonts/taja/Tajawal-ExtraBold.ttf',
  ]) {
    loader.addFont(rootBundle.load(file));
  }
  await loader.load();

  final almarai = FontLoader('almarai')
    ..addFont(rootBundle.load('assets/fonts/almaria/Almarai-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/almaria/Almarai-Bold.ttf'));
  await almarai.load();
}

Widget _app({required ThemeData theme}) {
  return EasyLocalization(
    supportedLocales: const [Locale('ar'), Locale('en')],
    path: 'assets/langs',
    fallbackLocale: const Locale('ar'),
    startLocale: const Locale('ar'),
    child: Builder(
      builder: (context) => MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        localeResolutionCallback: context.localeResolutionCallback,
        theme: theme,
        home: SizeConfigInit(
          referenceHeight: 926,
          referenceWidth: 428,
          child: const TermsAndConditionsScreen(),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFonts();
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1080, 2400);
    view.devicePixelRatio = 3;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('terms page light', (tester) async {
    await tester.pumpWidget(_app(theme: TAppTheme.lightTheme));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TermsAndConditionsScreen),
      matchesGoldenFile('goldens/terms_light_top.png'),
    );
  });

  testWidgets('terms page scrolled', (tester) async {
    await tester.pumpWidget(_app(theme: TAppTheme.lightTheme));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -1500),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TermsAndConditionsScreen),
      matchesGoldenFile('goldens/terms_light_scrolled.png'),
    );
  });

  testWidgets('terms page dark', (tester) async {
    await tester.pumpWidget(_app(theme: TAppTheme.darkTheme));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TermsAndConditionsScreen),
      matchesGoldenFile('goldens/terms_dark_top.png'),
    );
  });
}
