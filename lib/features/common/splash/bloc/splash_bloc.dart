import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/features/common/Auth/repo/auth_repo.dart';
import 'package:rasikh/features/common/splash/bloc/splash_state.dart';

class SplashBloc extends Cubit<SplashState> {
  SplashBloc(this._cacheHelper, this._authRepo) : super(const SplashState());

  final CacheHelper _cacheHelper;
  final GeneralAuthRepo _authRepo;

  /// Called on first launch to decide: onboarding → auth → home
  Future<void> checkUser() async {
    emit(state.asLoading());

    // Token is null when never logged in, empty string is treated as absent
    final hasToken = _cacheHelper.currentToken?.isNotEmpty == true;
    final onBoardingDone = _cacheHelper.onBoardingDone;

    emit(state.asLoadingSuccess(hasToken, onBoardingDone));
  }

  /// Alias kept for call-sites that use checkOnBoarding()
  Future<void> checkOnBoarding() => checkUser();
}