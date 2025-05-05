import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:safe_campus/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:safe_campus/features/auth/domain/entities/user.dart';
import 'dart:developer' as developer;

class AuthService {
  late final AuthRemoteDataSourceImpl _dataSource;
  late final SharedPreferences _prefs;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  AuthService(SharedPreferences prefs) {
    _prefs = prefs;
    _dataSource = AuthRemoteDataSourceImpl(
      client: http.Client(),
      prefs: prefs,
    );
    _setupTokenRefresh();
  }

  void _setupTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      final userToken = _prefs.getString('token');
      if (userToken != null) {
        try {
          await http.post(
            Uri.parse('https://safe-campus-backend.onrender.com/api/auth/update_token'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $userToken',
            },
            body: jsonEncode({
              'deviceToken': newToken,
            }),
          );
        } catch (e) {
          developer.log('Failed to update device token: $e');
        }
      }
    });
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _dataSource.login(email, password);
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    return await _dataSource.register(email, password, name);
  }

  Future<void> logout() async {
    await _dataSource.logout();
  }

  Future<bool> isLoggedIn() async {
    return await _dataSource.isLoggedIn();
  }

  Future<String?> getToken() async {
    return await _dataSource.getToken();
  }

  Future<User?> getUser() async {
    return await _dataSource.getUser();
  }
} 