

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/get_it_service/get_it_service.dart';
import '../repo/home_repo.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeInitialState());


  Future<void> getAdevertisingDataWithDataBase() async {
    emit(const HomeLoadingState());
    final f = await getIt.get<HomeRepo>().getAdvertisingData();
    await f.fold(
      (error) async {
        debugPrint("error is $error");
        emit(HomeFailedState(error: error));
      },
      (model) async {
        emit(HomeSuccessState(advertismentResponseModel: model));
      },
    );
  }
}
