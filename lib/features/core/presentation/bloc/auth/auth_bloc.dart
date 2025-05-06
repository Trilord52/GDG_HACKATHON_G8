import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:safe_campus/features/auth/data/services/auth_service.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_campus/features/auth/domain/entities/user.dart';

// class User {
//   final String id;
//   final String email;
//   final String role;

//   const User({
//     required this.id,
//     required this.email,
//     required this.role,
//   });
// }

// abstract class AuthState extends Equatable {
//   const AuthState();

//   @override
//   List<Object> get props => [];
// }

// class AuthInitial extends AuthState {}

// class AuthLoading extends AuthState {}

// class AuthAuthenticated extends AuthState {
//   final User user;

//   const AuthAuthenticated(this.user);

//   @override
//   List<Object> get props => [user];
// }

// class AuthUnauthenticated extends AuthState {}

// class AuthError extends AuthState {
//   final String message;

//   const AuthError(this.message);

//   @override
//   List<Object> get props => [message];
// }

// abstract class AuthEvent extends Equatable {
//   const AuthEvent();

//   @override
//   List<Object> get props => [];
// }

// class CheckAuthStatus extends AuthEvent {}

// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   AuthBloc() : super(AuthInitial()) {
//     on<CheckAuthStatus>(_onCheckAuthStatus);
//   }

//   void _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
//     emit(AuthLoading());
//     try {
//       // TODO: Implement actual auth check with backend
//       // For now, using mock data
//       final user = User(
//         id: '1',
//         email: 'admin@example.com',
//         role: 'admin',
//       );
//       emit(AuthAuthenticated(user));
//     } catch (e) {
//       emit(AuthError(e.toString()));
//     }
//   }
// }

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late final AuthService _authService;

  AuthBloc() : super(AuthInitial()) {
    _initializeAuthService();
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  Future<void> _initializeAuthService() async {
  
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
} 