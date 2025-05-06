class PanicNotification {
  final String eventType;
  final String fullName;
  final String studentId;
  final String email;
  final String phone;
  final String mapUrl;
  final List<double> coordinates;
  final String address;
  final String panicEventId;

  PanicNotification({
    required this.eventType,
    required this.fullName,
    required this.studentId,
    required this.email,
    required this.phone,
    required this.mapUrl,
    required this.coordinates,
    required this.address,
    required this.panicEventId,
  });

  factory PanicNotification.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final location = user['location'];

    return PanicNotification(
      eventType: json['eventType'],
      fullName: user['fullName'],
      studentId: user['studentId'],
      email: user['email'],
      phone: user['phone'],
      mapUrl: location['mapUrl'],
      coordinates: List<double>.from(location['coordinates']),
      address: location['name'],
      panicEventId: user['panicEventId'],
    );
  }
}
