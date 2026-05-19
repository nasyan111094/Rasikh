import 'package:equatable/equatable.dart';



import '../../features/common/Auth/models/auth_model.dart';


class AppState extends Equatable {
  final SharedOtpSentModel? authData;

  const AppState({
    this.authData,
  });

  AppState copyWith({
    SharedOtpSentModel? user,
    bool userNull = false,
  }) =>
      AppState(
        authData: userNull ? user : user ?? authData,
      );

  bool get isLoggedIn => authData != null;

  @override
  List<Object?> get props => [authData];
}
