import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';




import '../../app/app_bloc.dart';

class UserSelector extends StatelessWidget {
  const UserSelector({super.key, required this.builder});
  final Widget Function(BuildContext context, SharedOtpSentModel? user) builder;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppBloc, AppState, SharedOtpSentModel?>(
        bloc: AppBloc(),
        selector: (state) => state.authData,
        builder: (context, user) => builder(context, user));
  }
}
