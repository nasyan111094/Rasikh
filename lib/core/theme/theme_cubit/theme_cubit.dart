import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'package:rasikh/config/navigation/nav.dart';

import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/theme/theme_cubit/theme_states.dart';

import '../../cache/cache_helper.dart';
import '../../cache/pref_keys.dart';

enum ThemeEnums { light, dark, system }



class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitState());
  static AppCubit get(context) => BlocProvider.of(context);
  final SharedPrefs = getIt<CacheHelper>();
  final authService = getIt<CacheHelper>();


  ThemeMode? themeMode;
  

  void setThemeMode() {
    
   
    
    if (SharedPrefs.getData(PrefKeys.themeModeKey) == ThemeEnums.dark.name) {
      themeMode = ThemeMode.dark;
    } else if (SharedPrefs.getData(PrefKeys.themeModeKey) ==
        ThemeEnums.light.name) {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.system;
    }
    Logger().d("Currrrrrrrent Theme is " + "$themeMode") ;

  }

  void setDarkMode() {
    themeMode = ThemeMode.dark;
    SharedPrefs.saveData(key:PrefKeys.themeModeKey,value:  ThemeEnums.dark.name);
    reRender();
    emit(ThemeChangeToDarkState());
  }

  void reRender() {
    emit(ReRenderState());
  }

  void setLightMode() {
    themeMode = ThemeMode.light;
    SharedPrefs.saveData(key:PrefKeys.themeModeKey,value:  ThemeEnums.light.name);
    reRender();
    emit(ThemeChangeToLightState());
  }

  void setFollowSystemMode() {
    themeMode = ThemeMode.system;
    SharedPrefs.saveData(key : PrefKeys.themeModeKey,value:  ThemeEnums.system.name);
    reRender();
    emit(ThemeChangeToSystemState());
  }

  bool get isDarkMode =>
      Theme.of(Nav.mainNavKey.currentState!.context).brightness == Brightness.dark;

  bool get isTablet {
    final firstView = WidgetsBinding.instance.platformDispatcher.views.first;
    final logicalShortestSide =
        firstView.physicalSize.shortestSide / firstView.devicePixelRatio;
    return logicalShortestSide > 580;
  }

  bool get isPortrait {
    return MediaQuery.of(Nav.mainNavKey.currentState!.context).orientation ==
        Orientation.portrait;
  }
}
