import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_event_app/models/event_model.dart';
import 'package:uas_event_app/models/user_model.dart';

void _log(String message) {
  if (kDebugMode) {
    print(message);
  }
}

class ApiService {
  static const String _baseUrl = 'http://103.160.63.165/api';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final String token = data['token'];
    await prefs.setString('auth_token', token);
    _log('Token saved!');
    final Map<String, dynamic> userData = data['user'];
    await prefs.setString('user_data', jsonEncode(userData));
    _log('User data saved!');
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    _log('Auth data cleared!');
  }

  Future<User> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString('user_data');
    if (userDataString == null) {
      throw Exception('No user data found locally.');
    }
    final Map<String, dynamic> userData = jsonDecode(userDataString);
    return User.fromJson(userData);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _log('Token saved!');
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _log('Token removed!');
  }

  Future<List<Event>> getEvents() async {
    final Uri url = Uri.parse('$_baseUrl/events');
    _log('--> GET: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      _log('<-- RESPONSE [${response.statusCode}] from GET: $url');
      _log('Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final Map<String, dynamic> dataMap = responseBody['data'];
        final List<dynamic> eventsList = dataMap['events'];
        return eventsList.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat events. Status: ${response.statusCode}');
      }
    } catch (e) {
      _log('XXX ERROR from GET: $url -> $e');
      throw Exception('Gagal menghubungi server. Error: $e');
    }
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String studentNumber,
    required String password,
    required String major,
    required String classYear,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/register');

    final requestBody = {
      'name': name,
      'email': email,
      'student_number': studentNumber,
      'password': password,
      'password_confirmation': password,
      'major': major,
      'class_year': classYear,
    };

    _log('--> POST: $url');
    _log('Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      _log('<-- RESPONSE [${response.statusCode}] from POST: $url');
      _log('Body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        await _saveAuthData(responseBody['data']);
      } else {
        final errorMessage =
            responseBody['message'] ?? 'Unknown registration error';
        throw Exception('Registrasi gagal: $errorMessage');
      }
    } catch (e) {
      _log('XXX ERROR from POST: $url -> $e');
      rethrow;
    }
  }

  Future<void> loginUser({
    required String studentNumber,
    required String password,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/login');

    final requestBody = {
      'student_number': studentNumber,
      'password': password,
    };

    _log('--> POST: $url');
    _log('Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      _log('<-- RESPONSE [${response.statusCode}] from POST: $url');
      _log('Body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveAuthData(responseBody['data']);
      } else {
        final errorMessage = responseBody['message'] ?? 'Unknown login error';
        throw Exception('Login gagal: $errorMessage');
      }
    } catch (e) {
      _log('XXX ERROR from POST: $url -> $e');
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated. No token found.');

    final url = Uri.parse('$_baseUrl/user');
    _log('--> GET: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _log('<-- RESPONSE [${response.statusCode}] from GET: $url');
      _log('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception(
          'Gagal memuat data user. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log('XXX ERROR from GET: $url -> $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return;

    final url = Uri.parse('$_baseUrl/logout');
    _log('--> POST: $url');
    try {
      await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } finally {
      await _clearAuthData();
    }
  }
}
