// lib/api/api_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_event_app/models/event_model.dart';
import 'package:uas_event_app/models/user_model.dart';

// Helper function untuk logging hanya saat mode debug
void _log(String message) {
  if (kDebugMode) {
    print(message);
  }
}

class ApiService {
  // --- KONSTANTA ---
  static const String _baseUrl = 'http://103.160.63.165/api';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // --- FUNGSI INTERNAL (HELPERS) UNTUK MANAJEMEN DATA LOKAL ---

  /// [INTERNAL] Menyimpan token, data user, dan pre-fetch event yang diikuti ke SharedPreferences.
  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final String token = data['token'];
    await prefs.setString('auth_token', token);
    _log('Token saved!');

    final Map<String, dynamic> userData = data['user'];
    await prefs.setString('user_data', jsonEncode(userData));
    _log('User data saved!');

    try {
      await _fetchAndSaveMyEvents();
    } catch (e) {
      _log("Could not pre-fetch user's events after auth: $e");
    }
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('my_events');
    _log('Auth data cleared!');
  }

  Future<void> _saveMyEvents(Set<int> eventIds) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> idList = eventIds.map((id) => id.toString()).toList();
    await prefs.setStringList('my_events', idList);
    _log('Saved my events to local storage: $idList');
  }

  Future<Set<int>> _fetchAndSaveMyEvents() async {
    final token = await getToken();
    if (token == null) return {};
    final url = Uri.parse('$_baseUrl/my-events');
    _log('--> GET (for saving): $url');
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      _log('<-- RESPONSE [${response.statusCode}] from GET: $url');
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> eventsList = responseBody['data']['events'];
        final eventIds = eventsList
            .map((eventData) => eventData['id'] as int)
            .toSet();
        await _saveMyEvents(eventIds);
        return eventIds;
      } else {
        return {};
      }
    } catch (e) {
      _log('XXX ERROR from GET: $url -> $e');
      return {};
    }
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

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Set<int>> getSavedRegisteredEventIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? idList = prefs.getStringList('my_events');
    if (idList == null) {
      return {};
    }
    return idList.map((id) => int.parse(id)).toSet();
  }

  Future<void> loginUser({
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

  Future<void> logout() async {
    final token = await getToken();
    if (token == null) {
      await _clearAuthData();
      return;
    }
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
    } catch (e) {
      _log('XXX ERROR from POST: $url -> $e');
    } finally {
      await _clearAuthData();
    }
  }

  Future<User> getCurrentUser() async {
    final token = await getToken();
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
        return User.fromJson(jsonDecode(response.body));
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

  Future<List<Event>> getEvents() async {
    final url = Uri.parse('$_baseUrl/events');
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
        final List<dynamic> eventsList = responseBody['data']['events'];
        return eventsList.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat events. Status: ${response.statusCode}');
      }
    } catch (e) {
      _log('XXX ERROR from GET: $url -> $e');
      throw Exception('Gagal menghubungi server. Error: $e');
    }
  }

  Future<List<Event>> getMyRegisteredEvents() async {
    final token = await getToken();
    if (token == null) return [];

    final url = Uri.parse('$_baseUrl/my-events');
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
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> eventsList = responseBody['data']['events'];
        return eventsList.map((json) => Event.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      _log('XXX ERROR from getMyRegisteredEvents: $e');
      return [];
    }
  }

  Future<List<Event>> getCreatedEvents() async {
    try {
      final user = await getSavedUser();

      final allEvents = await getEvents();

      final createdEvents = allEvents
          .where((event) => event.creator.id == user.id)
          .toList();

      _log(
        'Ditemukan ${createdEvents.length} event yang dibuat oleh user ID ${user.id}',
      );
      return createdEvents;
    } catch (e) {
      _log('XXX ERROR from getCreatedEvents (client-side filter): $e');
      return [];
    }
  }

  Future<void> registerForEvent(int eventId) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final url = Uri.parse('$_baseUrl/events/$eventId/register');
    _log('--> POST: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _log('<-- RESPONSE [${response.statusCode}] from POST: $url');
      _log('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final currentIds = await getSavedRegisteredEventIds();
        currentIds.add(eventId);
        await _saveMyEvents(currentIds);
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage =
            responseBody['message'] ?? 'Gagal mendaftar event.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      _log('XXX ERROR from POST: $url -> $e');
      rethrow;
    }
  }

  Future<Event> createEvent({
    required String title,
    required String description,
    required String startDate,
    required String endDate,
    required String location,
    required String category,
    required int maxAttendees,
    required int price,
    String? imageUrl,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Otentikasi dibutuhkan. Silakan login kembali.');
    }

    final url = Uri.parse('$_baseUrl/events');
    final requestBody = {
      'title': title,
      'description': description,
      'start_date': startDate,
      'end_date': endDate,
      'location': location,
      'max_attendees': maxAttendees,
      'price': price,
      'category': category,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
    };
    _log('--> POST: $url');
    _log('Body: ${jsonEncode(requestBody)}');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      _log('<-- RESPONSE [${response.statusCode}] from POST: $url');
      _log('Body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return Event.fromJson(responseBody['data']);
      } else {
        final errorMessage = responseBody['message'] ?? 'Gagal membuat event.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      _log('XXX ERROR from POST: $url -> $e');
      rethrow;
    }
  }
}
