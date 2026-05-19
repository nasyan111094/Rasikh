// features/help_center/logic/contact/contact_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Repo/help_center_repo.dart';
import '../../models/help_center_models.dart';


part 'contact_state.dart';

class ContactCubit extends Cubit<ContactState> {
  ContactCubit(this._repo) : super(ContactInitial());

  final HelpCenterRepo _repo;

  Future<void> fetchContact() async {
    emit(ContactLoading());

    final result = await _repo.getContactInfo();

    result.fold(
      (error) => emit(ContactFailure(error)),
      (contact) => emit(ContactLoaded(contact)),
    );
  }

  Future<void> refreshContact() async {
    final current = state;

    if (current is ContactLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(ContactLoading());
    }

    final result = await _repo.getContactInfo();

    result.fold(
      (error) {
        if (current is ContactLoaded) {
          emit(current.copyWith(isRefreshing: false));
        }
        emit(ContactFailure(error));
      },
      (contact) => emit(ContactLoaded(contact)),
    );
  }
}
