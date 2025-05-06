class Contact {
  final String fullName;
  final String email;
  final String phoneNumber;

  Contact({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
      };

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        fullName: json['fullName'],
        email: json['email'],
        phoneNumber: json['phoneNumber'],
      );
}
