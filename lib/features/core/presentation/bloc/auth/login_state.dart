import 'package:equatable/equatable.dart';
import 'package:safe_campus/features/auth/domain/entities/user.dart';
import 'package:safe_campus/features/core/presentation/bloc/auth/auth_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final User user;
  const LoginSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class LoginFailure extends LoginState {
  final String error;
  const LoginFailure(this.error);

  @override
  List<Object> get props => [error];
} 