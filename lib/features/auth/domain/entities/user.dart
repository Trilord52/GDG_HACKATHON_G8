import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? studentId;
  final List<Map<String, dynamic>>? trustedContacts;
  final Map<String, dynamic>? location;
  final String? addressDescription;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.studentId,
    this.trustedContacts,
    this.location,
    this.addressDescription,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      studentId: json['studentId'],
      trustedContacts: json['trustedContacts'] != null
          ? List<Map<String, dynamic>>.from(json['trustedContacts'])
          : null,
      location: json['location'],
      addressDescription: json['addressDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'studentId': studentId,
      'trustedContacts': trustedContacts,
      'location': location,
      'addressDescription': addressDescription,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        role,
        studentId,
        trustedContacts,
        location,
        addressDescription,
      ];
} 