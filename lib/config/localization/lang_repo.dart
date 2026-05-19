import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:rasikh/core/cache/pref_keys.dart';

import '../../core/cache/cache_helper.dart';
import '../../core/get_it_service/get_it_service.dart';
import '../../core/utils/translation_helper.dart';

class LangRepo {
  String? lang;
  LangRepo();

  Future<Either<String, void>> setLang(
      String lang, BuildContext context) async {
    try {
      this.lang = lang;
      getIt<CacheHelper>().saveData(key:PrefKeys.userLangKey,value:  lang);
      context.setLocale(
        Locale(
          lang,
        ),
      );
      return const Right(null);
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
      return Left(getServerError());
    }
  }

  Future<Either<String, String>> getLang() async {
    try {
      final kLang = await getIt<CacheHelper>().getData(PrefKeys.userLangKey);
      lang = kLang;
      return Right(lang ?? 'ar');
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
      return Left(getServerError());
    }
  }
}
