import 'package:equatable/equatable.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final String message;
  const RegisterSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class RegisterFailure extends RegisterState {
  final String error;
  const RegisterFailure(this.error);

  @override
  List<Object> get props => [error];
} 