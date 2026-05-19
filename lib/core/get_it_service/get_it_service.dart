// service_locator.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rasikh/config/localization/lang_repo.dart';
import 'package:rasikh/core/app/app_bloc.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/connectivity/cubit/connectivity_cubit.dart';
import 'package:rasikh/core/utils/api/api_handler.dart';
import 'package:rasikh/core/utils/api/api_helper.dart';
import 'package:rasikh/core/utils/api/dio_helper.dart';

import 'package:rasikh/features/common/Auth/bloc/auth_cubit.dart';
import 'package:rasikh/features/common/Auth/repo/auth_repo.dart';
import 'package:rasikh/features/common/splash/bloc/splash_bloc.dart';

import 'package:rasikh/features/Lawyer/lawer_register_compilation/Repo/lawyer_register_complation_repo.dart';
import 'package:rasikh/features/Lawyer/lawer_register_compilation/cubit/lawyer_registeration_complation_cubit.dart';

import 'package:rasikh/features/User/home/cubit/home_cubit.dart';
import 'package:rasikh/features/User/home/repo/home_repo.dart';
import 'package:rasikh/features/User/profile/repo/profile_repo.dart';

import '../../features/Company/company_register_completion/bloc/company_completion_cubit.dart';
import '../../features/Company/company_register_completion/repo/company_completion_repo.dart';
import '../../features/Lawyer/lawyer_Settings/Repo/lawyer_profile_repo.dart';
import '../../features/Lawyer/lawyer_Settings/bloc/lawyer_cubit.dart';
import '../../features/User/user_register_completion/bloc/user_completion_cubit.dart';
import '../../features/User/user_register_completion/repo/user_completion_repo.dart';
import '../theme/theme_cubit/theme_cubit.dart';

export 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  try {
    // ─── SharedPreferences ────────────────────────────────────────────────────
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);

    // ─── CacheHelper ──────────────────────────────────────────────────────────
    // Init once here; never call init() again in main.dart
    final cacheHelper = CacheHelper();
    await cacheHelper.init();
    getIt.registerSingleton<CacheHelper>(cacheHelper);

    // ─── Networking ───────────────────────────────────────────────────────────
    getIt.registerSingleton<Dio>(Dio());

    // ApiHandler depends on Dio → registered after
    getIt.registerLazySingleton<ApiHandler>(() => ApiHandler());
    getIt.registerLazySingleton<ApiHelper>(() => ApiImpl());
    getIt.registerLazySingleton<DioHelper>(() => DioImpl());

    // ─── Lang ─────────────────────────────────────────────────────────────────
    getIt.registerSingleton<LangRepo>(LangRepo());

    // ─── Auth ─────────────────────────────────────────────────────────────────
    getIt.registerFactory<GeneralAuthRepo>(() => GeneralAuthRepo());
    getIt.registerLazySingleton<AuthCubit>(
          () => AuthCubit(getIt<GeneralAuthRepo>()),
    );

    // ─── Lawyer ───────────────────────────────────────────────────────────────
    getIt.registerLazySingleton<UserCompletionRepo>(
          () => UserCompletionRepo(),
    );
    getIt.registerLazySingleton<UserCompletionCubit>(
          () => UserCompletionCubit(getIt()),
    );


    // ─── Lawyer ───────────────────────────────────────────────────────────────
    getIt.registerLazySingleton<CompanyCompletionRepo>(
          () => CompanyCompletionRepo(),
    );
    getIt.registerLazySingleton<CompanyCompletionCubit>(
          () => CompanyCompletionCubit(getIt()),
    );


    // ─── Lawyer ───────────────────────────────────────────────────────────────
    getIt.registerLazySingleton<LawyerCompletionRepo>(
          () => LawyerCompletionRepo(),
    );
    getIt.registerLazySingleton<LawyerCompletionCubit>(
          () => LawyerCompletionCubit(getIt()),
    );

    // ─── App / Theme ──────────────────────────────────────────────────────────
    // registerFactory: a fresh AppCubit per BlocProvider
    getIt.registerFactory<AppCubit>(() => AppCubit());

    // ─── Splash ───────────────────────────────────────────────────────────────
    // SplashBloc receives CacheHelper + GeneralAuthRepo via constructor
    getIt.registerFactory<SplashBloc>(
          () => SplashBloc(
        getIt<CacheHelper>(),
        getIt<GeneralAuthRepo>(),
      ),
    );

    // ─── Home ─────────────────────────────────────────────────────────────────
    getIt.registerLazySingleton<HomeRepo>(() => HomeRepo());
    // registerLazySingleton so the same HomeCubit instance is reused
    getIt.registerLazySingleton<HomeCubit>(() => HomeCubit());

    // ─── Profile ──────────────────────────────────────────────────────────────
    getIt.registerLazySingleton<ProfileRepo>(() => ProfileRepo());

    // ─── Connectivity ─────────────────────────────────────────────────────────
    getIt.registerLazySingleton<ConnectivityCubit>(() => ConnectivityCubit());


    // Repo — lazySingleton so it is created once and reused
    getIt.registerLazySingleton<LawyerProfileRepo>(
          () => LawyerProfileRepo(),
    );

    // Cubit — factory so each navigation push gets a fresh instance
    // (or use lazySingleton if you want state persisted across screens)
    getIt.registerFactory<LawyerProfileCubit>(
          () => LawyerProfileCubit(getIt<LawyerProfileRepo>()),
    );


    // ─── Logger ───────────────────────────────────────────────────────────────
    getIt.registerLazySingleton<Logger>(
          () => Logger(
        level: kReleaseMode ? Level.off : Level.debug,
      ),
    );
  } catch (e, stackTrace) {
    print('Error in initializeDependencies: $e');
    print('StackTrace: $stackTrace');
    rethrow;
  }
}

/// Shared logger instance available app-wide
final logger = getIt.get<Logger>();