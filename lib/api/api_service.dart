import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uas_event_app/models/event_model.dart';

void _log(String message) {
  if (kDebugMode) {
    print(message);
  }
}

class ApiService {
  static const String _baseUrl = 'http://103.160.63.165/api';

  Future<List<Event>> getEvents() async {
    final Uri url = Uri.parse('$_baseUrl/events');
    _log('--> GET: $url'); // Log the request

    try {
      final response = await http.get(url);

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
    required String studentNumber,
    required String password,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/register');
    final requestBody = {
      'name': name,
      'student_number': studentNumber,
      'password': password,
      'password_confirmation': password,
    };

    _log('--> POST: $url');
    _log('Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      _log('<-- RESPONSE [${response.statusCode}] from POST: $url');
      _log('Body: ${response.body}');

      if (response.statusCode != 201) {
        final responseBody = jsonDecode(response.body);
        final errorMessage =
            responseBody['message'] ?? 'Unknown registration error';
        throw Exception('Registrasi gagal: $errorMessage');
      }
    } catch (e) {
      _log('XXX ERROR from POST: $url -> $e');
      // Re-throw the exception to be handled by the UI
      rethrow;
    }
  }

  Future<String> loginUser({
    required String studentNumber,
    required String password,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/login');
    final requestBody = {'student_number': studentNumber, 'password': password};

    _log('--> POST: $url');
    _log('Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      _log('<-- RESPONSE [${response.statusCode}] from POST: $url');
      _log('Body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final String token = responseBody['token'];
        return token;
      } else {
        final errorMessage = responseBody['message'] ?? 'Unknown login error';
        throw Exception('Login gagal: $errorMessage');
      }
    } catch (e) {
      _log('XXX ERROR from POST: $url -> $e');
      rethrow;
    }
  }
}
