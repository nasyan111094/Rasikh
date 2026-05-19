import 'package:flutter_bloc/flutter_bloc.dart';




import '../../features/common/Auth/models/auth_model.dart';
import '../get_it_service/get_it_service.dart';
import 'app_state.dart';

export 'app_state.dart';

class AppBloc extends Cubit<AppState> {
  AppBloc._() : super(const AppState());

  factory AppBloc() {
    if (!getIt.isRegistered<AppBloc>()) {
      getIt.registerSingleton<AppBloc>(AppBloc._());
    }
    return getIt<AppBloc>();
  }

  @override
  Future<void> close() {
    getIt.unregister<AppBloc>();
    return super.close();
  }

  loggedIn(SharedOtpSentModel auth) => emit(state.copyWith(user: auth));

  loggedOut() => emit(state.copyWith(user: null, userNull: true));
}
