import 'package:safe_campus/features/auth/domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String email, String password, String name);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getToken();
  Future<User?> getUser();
} 