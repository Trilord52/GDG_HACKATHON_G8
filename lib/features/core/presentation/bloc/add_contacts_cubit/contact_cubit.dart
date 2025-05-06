import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_campus/features/core/data/models/contacts_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'contact_state.dart';

class ContactCubit extends Cubit<ContactState> {
  final String token;

  ContactCubit({required this.token}) : super(ContactInitial()) {
    _loadContactsFromPrefs();
  }

  Future<void> addContact(Contact contact) async {
    emit(ContactLoading());

    log(token);

    try {
      final url = Uri.parse('https://safe-campus-backend.onrender.com/api/auth/update_contacts');

      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(contact.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final currentContacts = state is ContactSuccess
            ? (state as ContactSuccess).contacts
            : [];
        log(currentContacts.toString());
        final List<Contact> updatedContacts = List<Contact>.from(currentContacts)..add(contact);
        log(updatedContacts.toString());


        await _saveContactsToPrefs(updatedContacts);
        emit(ContactSuccess(updatedContacts));
      } else {
        emit(ContactError('Failed to update contact: ${response.statusCode}'));
      }
    } catch (e) {
      log(e.toString());
      emit(ContactError('Error: ${e.toString()}'));
    }
  }

  Future<void> _saveContactsToPrefs(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(contacts.map((e) => e.toJson()).toList());
    await prefs.setString('contacts', encoded);
  }

  Future<void> _loadContactsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('contacts');

    if (stored != null) {
      final decoded = jsonDecode(stored) as List;
      final contactList = decoded.map((e) => Contact.fromJson(e)).toList();
      emit(ContactSuccess(contactList));
    } else {
      emit(ContactInitial());
    }
  }
}
