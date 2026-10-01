import 'dart:convert';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rasikh/features/Lawyer/lawyer_Settings/Repo/lawyer_profile_repo.dart';
import 'package:rasikh/features/Lawyer/lawyer_Settings/bloc/Profile_cubit/lawyer_cubit.dart';
import 'package:rasikh/features/User/application/bloc/consulation_application_cubit.dart';
import 'package:rasikh/features/User/profile/cubit/profile_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:size_config/size_config.dart';

import 'package:rasikh/config/navigation/nav.dart';
import 'package:rasikh/config/theme/theme.dart';
import 'package:rasikh/core/app/app_bloc.dart';
import 'package:rasikh/core/app_bloc_observer.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/cache/pref_keys.dart';
import 'package:rasikh/core/connectivity/cubit/connectivity_cubit.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/constants.dart';

import 'config/app_config.dart';
import 'config/navigation/nav_obs.dart';
import 'core/app_wrapper.dart';
import 'core/connectivity/app_connectivity_wrapper.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_cubit/theme_cubit.dart';
import 'core/theme/theme_cubit/theme_states.dart';
import 'features/Lawyer/consultation/Bloc/consultations_cubit.dart';
import 'features/Lawyer/consultation/repo/consultations_repo.dart';
import 'features/Lawyer/lawyer-appointments/bloc/lawyer_appointments_cubit.dart';
import 'features/Lawyer/lawyer-appointments/repo/lawyer_appointments_repo.dart';
import 'features/Lawyer/lawyer-home/bloc/avaiabilty_cubit.dart';
import 'features/Lawyer/lawyer-home/bloc/lawyer_consultations_cubit.dart';
import 'features/Lawyer/lawyer-home/repo/lawyer_consultations_repo.dart';
import 'features/Lawyer/lawyer_Settings/Repo/specializations_repo.dart';
import 'features/Lawyer/lawyer_Settings/bloc/Specializations_cubit/specializations_cubit.dart';
import 'features/Lawyer/lawyer_Settings/screens/lawyer_specializations_screen.dart';
import 'features/User/home/cubit/home_cubit.dart';
import 'features/common/splash/screens/splash_page.dart';

const int _lastVersion = 4;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Register all singletons (includes CacheHelper.init()) ──────────────────
  await initializeDependencies();

  // ── Agora Chat SDK initialization ──────────────────────────────────────────
  try {
    final options = ChatOptions(
      appKey: AppConfig.agoraChatAppKey,
      autoLogin: false,
    );
    await ChatClient.getInstance.init(options);
    await ChatClient.getInstance.startCallback().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('[STARTUP] Agora startCallback TIMEOUT - continuing');
      },
    );
  } catch (e) {
    // Log error but continue - chat features will fail gracefully
    debugPrint('Failed to initialize Agora Chat SDK: $e');
  }

  // ── Portrait lock ──────────────────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // ── HydratedBloc storage ───────────────────────────────────────────────────
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  // ── Version migration (preserves user data) ────────────────────────────────
  final prefs = getIt<SharedPreferences>();
  final savedVersion = prefs.getInt('saved_version') ?? 0;

  if (_lastVersion != savedVersion) {
    final userData = prefs.getString(PrefKeys.userKey);
    await prefs.clear();
    if (userData != null) {
      await prefs.setString(PrefKeys.userKey, userData);
    }
    await prefs.setInt('saved_version', _lastVersion);
    await HydratedBloc.storage.clear();
  }

  // ── Localization ───────────────────────────────────────────────────────────
  await EasyLocalization.ensureInitialized();

  // ── Bloc observer ──────────────────────────────────────────────────────────
  Bloc.observer = AppBlocObserver();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: Constants.localizationPath,
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      saveLocale: true,
      useOnlyLangCode: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ConnectivityCubit>(
            create: (_) => getIt<ConnectivityCubit>()..checkConnectivity(),
          ),
          BlocProvider<AppCubit>(
            create: (_) => getIt<AppCubit>()..setThemeMode(),
          ),

          BlocProvider<ConsultationApplicationCubit>(
            create: (_) => getIt<ConsultationApplicationCubit>(),
          ),
          BlocProvider<HomeCubit>(
            create: (_) => getIt<HomeCubit>(),
          ),
          BlocProvider<LawyerProfileCubit>(
            create: (_) => getIt<LawyerProfileCubit>(),
          ),
          BlocProvider<ProfileCubit>(
            create: (_) => getIt<ProfileCubit>(),
          ),

          // ✅ Add this
          BlocProvider<LawyerAvailabilityCubit>(
            create: (_) => getIt<LawyerAvailabilityCubit>(),
          ),

          BlocProvider(
            create: (_) => ConsultationsCubit(repo: ConsultationsRepo()),
          ),

          BlocProvider(
            create: (_) => LawyerConsultationsCubit(LawyerConsultationsRepo()),
          ),

          BlocProvider(
            create: (_) => LawyerAppointmentsCubit(LawyerAppointmentsRepo()),
          ),

        ],
        child: const AppWithOverlay(),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class RashikhApp extends StatefulWidget {
  const RashikhApp({super.key});

  @override
  State<RashikhApp> createState() => _RashikhAppState();
}

class _RashikhAppState extends State<RashikhApp> {
  @override
  void initState() {
    super.initState();




    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizeConfigInit(
      referenceHeight: 926,
      referenceWidth: 428,
      builder: (context, _) {
          return BlocBuilder<AppCubit, AppStates>(
            builder: (context, state) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: const SystemUiOverlayStyle(
                  statusBarColor: Colors.white,
                  statusBarBrightness: Brightness.light,
                  statusBarIconBrightness: Brightness.dark,
                  systemNavigationBarColor: Colors.white,
                  systemNavigationBarIconBrightness: Brightness.dark,
                  systemNavigationBarDividerColor: Colors.transparent,
                ),
                child: MaterialApp(
                  theme: TAppTheme.lightTheme,
                  darkTheme: TAppTheme.darkTheme,
                  themeMode:  ThemeMode.light /*getIt<AppCubit>().themeMode*/,
                  debugShowCheckedModeBanner: false,
                  navigatorKey: Nav.mainNavKey,
                  navigatorObservers: [NavObs.instance],
                  localizationsDelegates: [
                    CountryLocalizations.delegate,
                    ...context.localizationDelegates,
                  ],
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  home: const SplashPage(),
                  builder: (context, child) {
                    return SafeArea(
                        bottom: true,
                        top: false,

                        child: child!);
                  },
                ),
              );
            },
          );
        },
      );
  }
}