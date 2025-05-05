import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactList extends StatefulWidget {
  final List<Map<String, String>> contacts;
  final Function(int) onDelete;

  const ContactList({
    super.key,
    required this.contacts,
    required this.onDelete,
  });

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final List<bool> _isExpanded = [];

  @override
  void initState() {
    super.initState();
    _isExpanded.addAll(List.generate(widget.contacts.length, (index) => false));
  }

  @override
  void didUpdateWidget(ContactList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.contacts.length != _isExpanded.length) {
      _isExpanded.clear();
      _isExpanded.addAll(List.generate(widget.contacts.length, (index) => false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.contacts.length,
      itemBuilder: (context, index) {
        final contact = widget.contacts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ExpansionTile(
            title: Text(
              contact['name'] ?? '',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              child: Text(
                contact['name']?.substring(0, 1).toUpperCase() ?? '',
                style: GoogleFonts.poppins(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => widget.onDelete(index),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContactInfo(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: contact['phone'] ?? '',
                    ),
                    const SizedBox(height: 10),
                    _buildContactInfo(
                      icon: Icons.email,
                      label: 'Email',
                      value: contact['email'] ?? '',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}