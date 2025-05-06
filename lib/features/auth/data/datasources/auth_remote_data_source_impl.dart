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
    static const String baseUrl = 'https://safe-campus-backend.onrender.com/api';


  AuthRemoteDataSourceImpl({
    required this.client,
    required this.prefs,
  });
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

    // Send login request
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

    developer.log('Status Code: ${response.statusCode}');
    developer.log('Response Body: ${response.body}');

    late final Map<String, dynamic> responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (e) {
      developer.log('JSON decode error: $e');
      return {
        'success': false,
        'error': 'Invalid response format from server: ${response.body}',
      };
    }

    if (response.statusCode == 200) {
      final data = responseBody['data'];
      String? token = data?['token'];
      final userJson = data?['user'];

      if (token != null && userJson != null) {
        // Add token to user JSON before saving
        userJson['token'] = token;

        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(userJson));

        token = prefs.getString('token');

        developer.log(token.toString());

        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Token or user data missing in server response',
        };
      }
    } else if (response.statusCode == 400) {
      return {
        'success': false,
        'error': responseBody['message'] ?? 'Invalid email or password',
      };
    } else if (response.statusCode == 401) {
      return {
        'success': false,
        'error': 'Invalid credentials',
      };
    } else if (response.statusCode == 404) {
      return {
        'success': false,
        'error': 'User not found',
      };
    } else {
      return {
        'success': false,
        'error': responseBody['message'] ?? 'Login failed',
      };
    }
  } catch (e, stack) {
    developer.log('Unexpected error during login: $e', stackTrace: stack);
    return {
      'success': false,
      'error': 'An error occurred during login: ${e.toString()}',
    };
  }
}



@override
Future<Map<String, dynamic>> register(String email, String password, String name) async {
  try {
    // Log input
    developer.log('Attempting to register user', name: 'Register', error: {
      'email': email,
      'name': name,
    });

    // Send request
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

    developer.log('Status Code: ${response.statusCode}', name: 'Register');
    developer.log('Response Body: ${response.body}', name: 'Register');

    late final Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (e) {
      developer.log('JSON decode error: $e', name: 'Register');
      return {
        'success': false,
        'error': 'Invalid response format from server: ${response.body}',
      };
    }

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
  } catch (e, stack) {
    developer.log('Unexpected error during registration: $e', name: 'Register', stackTrace: stack);
    return {
      'success': false,
      'error': 'An unexpected error occurred during registration: ${e.toString()}',
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