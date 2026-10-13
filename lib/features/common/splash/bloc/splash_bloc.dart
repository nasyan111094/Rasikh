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

    // A session is valid only when the access token, the refresh token
    // AND the selected vendor are all present; otherwise fall back to auth.
    final hasToken = _cacheHelper.currentToken?.isNotEmpty == true;
    final refreshToken = await _cacheHelper.getRefreshToken();
    final vendorType = await _cacheHelper.getCachedVendorType();
    final loggedIn = hasToken &&
        (refreshToken?.isNotEmpty == true) &&
        vendorType != null;
    final onBoardingDone = _cacheHelper.onBoardingDone;

    emit(state.asLoadingSuccess(loggedIn, onBoardingDone));
  }

  /// Alias kept for call-sites that use checkOnBoarding()
  Future<void> checkOnBoarding() => checkUser();
}