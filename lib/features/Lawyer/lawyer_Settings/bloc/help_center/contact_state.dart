// features/help_center/logic/contact/contact_state.dart

part of 'contact_cubit.dart';

sealed class ContactState {}

final class ContactInitial extends ContactState {}

final class ContactLoading extends ContactState {}

final class ContactLoaded extends ContactState {
  final ContactModel contact;
  final bool isRefreshing;

  ContactLoaded(this.contact, {this.isRefreshing = false});

  ContactLoaded copyWith({ContactModel? contact, bool? isRefreshing}) {
    return ContactLoaded(
      contact ?? this.contact,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

final class ContactFailure extends ContactState {
  final String message;
  ContactFailure(this.message);
}
final class FaqLoading extends ContactState {}

final class FaqLoaded extends ContactState {
   FaqLoaded(this.faqs);
  final List<FaqModel> faqs;
  @override
  List<Object?> get props => [faqs];
}

final class FaqFailure extends ContactState {
  FaqFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}