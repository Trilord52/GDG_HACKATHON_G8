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
  final String token;
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.studentId,
    this.trustedContacts,
    this.location,
    this.addressDescription,
   required this.token
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? 'id',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      studentId: json['studentId'],
      trustedContacts: json['trustedContacts'] != null
          ? List<Map<String, dynamic>>.from(json['trustedContacts'])
          : null,
      location: json['location'],
      addressDescription: json['addressDescription'],
      token: json['token'] ?? '', // Ensure token is always a string
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
      'token': token, 
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
        token,
      ];
} 