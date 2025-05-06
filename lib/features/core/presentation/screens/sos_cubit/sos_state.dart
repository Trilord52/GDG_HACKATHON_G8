part of 'sos_cubit.dart';

class SosState extends Equatable {
  final bool isEmergencyMode;

  const SosState({required this.isEmergencyMode});

  @override
  List<Object> get props => [isEmergencyMode];
}

