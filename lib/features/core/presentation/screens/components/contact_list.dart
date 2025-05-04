import 'package:flutter/material.dart';

class ContactList extends StatelessWidget {
  final List<Map<String, String>> contacts;

  const ContactList({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.grey[700]),
          ),
          title: Text(contact['name'] ?? '', style: TextStyle(fontSize: 16)),
          subtitle: Text(contact['phone'] ?? '', style: TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        );
      },
    );
  }
}