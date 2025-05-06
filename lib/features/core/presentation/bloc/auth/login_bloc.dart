import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_campus/features/auth/data/services/auth_service.dart';
import 'package:safe_campus/features/core/presentation/bloc/auth/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_campus/features/auth/domain/entities/user.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  late final AuthService _authService;

  LoginBloc() : super(LoginInitial()) {
    _initializeAuthService();
    on<LoginSubmitted>(_onLoginSubmitted);
    on<CheckLoginStatus>(_onCheckLoginStatus);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _initializeAuthService() async {
    final prefs = await SharedPreferences.getInstance();
    _authService = AuthService(prefs);
    add(CheckLoginStatus());
  }

  Future<void> _onCheckLoginStatus(
    CheckLoginStatus event,
    Emitter<LoginState> emit,
  ) async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getUser();
        if (user != null) {
          emit(LoginSuccess(user));
        } else {
          emit(LoginInitial());
        }
      } else {
        emit(LoginInitial());
      }
    } catch (e) {
      emit(LoginFailure('Error checking login status: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LoginState> emit,
  ) async {
    try {
      await _authService.logout();
      emit(LoginInitial());
    } catch (e) {
      emit(LoginFailure('Error during logout: ${e.toString()}'));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      final result = await _authService.login(event.email, event.password);

      if (result['success'] == true) {
        final userData = result['data']['user'];
        if (userData != null) {
          final user = User.fromJson(userData);
          emit(LoginSuccess(user));
        } else {
          emit(LoginFailure('Invalid user data received from server'));
        }
      } else {
        final errorMessage = result['error'] ?? 'Login failed';
        emit(LoginFailure(errorMessage));
      }
    } catch (e) {
      emit(LoginFailure('An error occurred during login: ${e.toString()}'));
    }
  }
}
