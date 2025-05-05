import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:safe_campus/features/auth/domain/entities/user.dart';
import 'auth_remote_data_source.dart';
import 'dart:developer' as developer;
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final SharedPreferences prefs;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static const String baseUrl = 'https://safe-campus-api.onrender.com/api';

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.prefs,
  });

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'error': 'Email and password are required',
        };
      }

      // Get device token
      String? deviceToken = await _firebaseMessaging.getToken();
      
      final response = await client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'deviceToken': deviceToken,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Verify the response structure
        if (data['success'] == true && 
            data['data'] != null && 
            data['data']['token'] != null && 
            data['data']['user'] != null) {
          
          // Save token and user data
          await prefs.setString('token', data['data']['token']);
          await prefs.setString('user', jsonEncode(data['data']['user']));
          
          return {
            'success': true,
            'data': data['data'],
          };
        } else {
          developer.log('Invalid response format: $data');
          return {
            'success': false,
            'error': 'Invalid response format from server',
          };
        }
      } else if (response.statusCode == 400) {
        // Handle validation errors
        return {
          'success': false,
          'error': data['message'] ?? 'Invalid email or password',
        };
      } else if (response.statusCode == 401) {
        // Handle authentication errors
        return {
          'success': false,
          'error': 'Invalid credentials',
        };
      } else if (response.statusCode == 404) {
        // Handle user not found
        return {
          'success': false,
          'error': 'User not found',
        };
      } else {
        // Handle other errors
        return {
          'success': false,
          'error': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      developer.log('Error during login: $e');
      return {
        'success': false,
        'error': 'An error occurred during login: ${e.toString()}',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'An error occurred during registration',
      };
    }
  }

  @override
  Future<void> logout() async {
    // Get the current device token before logging out
    final deviceToken = await _firebaseMessaging.getToken();
    final userToken = prefs.getString('token');

    if (deviceToken != null && userToken != null) {
      try {
        // Remove the device token from the backend
        await client.post(
          Uri.parse('$baseUrl/auth/remove-device-token'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $userToken',
          },
          body: jsonEncode({
            'deviceToken': deviceToken,
          }),
        );
      } catch (e) {
        print('Failed to remove device token: $e');
      }
    }

    await prefs.remove('token');
    await prefs.remove('user');
  }

  @override
  Future<bool> isLoggedIn() async {
    return prefs.containsKey('token');
  }

  @override
  Future<String?> getToken() async {
    return prefs.getString('token');
  }

  @override
  Future<User?> getUser() async {
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }
} 