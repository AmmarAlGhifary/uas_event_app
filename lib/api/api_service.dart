
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uas_event_app/models/event_model.dart';

class ApiService {
  static const String _baseUrl = 'http://103.160.63.165/api';

  Future<List<Event>> getEvents() async {
    final Uri url = Uri.parse('$_baseUrl/events');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        final Map<String, dynamic> dataMap = responseBody['data'];

        final List<dynamic> eventsList = dataMap['events'];

        return eventsList.map((json) => Event.fromJson(json)).toList();

      } else {
        throw Exception('Gagal memuat events. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal menghubungi server. Error: $e');
    }
  }
}