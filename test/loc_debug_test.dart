import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/localization.dart' as internal;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _SyncJsonAssetLoader extends AssetLoader {
  const _SyncJsonAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) {
    final file = File('$path/${locale.languageCode}.json');
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    print('LOADED ${file.path} ${data.length} keys direct=${data['termsAndConditions']}');
    return SynchronousFuture(data);
  }
}

void main() {
  testWidgets('debug loc', (tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ar')],
        path: 'assets/langs',
        assetLoader: const _SyncJsonAssetLoader(),
        fallbackLocale: const Locale('ar'),
        startLocale: const Locale('ar'),
        child: Builder(
          builder: (context) {
            return MaterialApp(
              locale: const Locale('ar'),
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              home: const Scaffold(body: Text('x')),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    print('AFTER exists=${internal.Localization.instance.exists('termsAndConditions')}');
  });
}
