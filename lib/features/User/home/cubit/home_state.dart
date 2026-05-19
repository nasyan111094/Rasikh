import 'package:rasikh/core/utils/loading_state.dart';

import 'package:equatable/equatable.dart';

import '../models/advertising_response_model.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitialState extends HomeState {
  const HomeInitialState();
}

class HomeLoadingState extends HomeState {
  const HomeLoadingState();
}

class HomeFailedState extends HomeState {
  final String? error;
  const HomeFailedState({required this.error});
}

class HomeSuccessState extends HomeState {
  final AdvertismentResponseModel advertismentResponseModel;
  const HomeSuccessState({required this.advertismentResponseModel});
}

class GetAdsDataState extends Equatable {
  final bool? success;
  final LoadingState loadingState;
  final String? error;
  final AdvertismentResponseModel? advertismentResponseModel;

  const GetAdsDataState({
    this.success,
    this.loadingState = const LoadingState(),
    this.error,
    this.advertismentResponseModel,
  });

  GetAdsDataState asLoading() => const GetAdsDataState(
        loadingState: LoadingState.loading(),
      );

  GetAdsDataState asLoadingSuccess({
    bool? success,
    bool? isNewUser,
    AdvertismentResponseModel? adverismentResponseModel,
  }) =>
      GetAdsDataState(
        success: success,
        advertismentResponseModel: adverismentResponseModel,
      );

  GetAdsDataState asLoadingFailed(String error) => GetAdsDataState(
        error: error,
      );

  @override
  List<Object?> get props => [
        success,
        loadingState,
        error,
        advertismentResponseModel,
      ];
}
