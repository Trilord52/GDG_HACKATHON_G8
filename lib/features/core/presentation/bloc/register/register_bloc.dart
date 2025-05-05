import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_campus/features/auth/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  late final AuthService _authService;

  RegisterBloc() : super(RegisterInitial()) {
    _initializeAuthService();
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _initializeAuthService() async {
    final prefs = await SharedPreferences.getInstance();
    _authService = AuthService(prefs);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());

    try {
      final result = await _authService.register(
        event.email,
        event.password,
        event.fullName,
      
      );

      if (result['success'] == true) {
        emit(const RegisterSuccess('Registration successful!'));
      } else {
        emit(RegisterFailure(result['error'] ?? 'Registration failed'));
      }
    } catch (e) {
      emit(RegisterFailure('An error occurred during registration'));
    }
  }
} 