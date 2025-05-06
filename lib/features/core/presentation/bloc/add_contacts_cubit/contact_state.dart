import 'package:safe_campus/features/core/data/models/contacts_model.dart';

abstract class ContactState {}

class ContactInitial extends ContactState {}

class ContactLoading extends ContactState {}

class ContactSuccess extends ContactState {
  final List<Contact> contacts;
  ContactSuccess(this.contacts);
}

class ContactError extends ContactState {
  final String message;
  ContactError(this.message);
}
