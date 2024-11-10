import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://hamzadev.atwebpages.com';

  static Future<Map<String, dynamic>> fetchReservedHours(String date) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_reserved_hours.php?date=$date'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': 'Server error'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<bool> submitReservation(String name, String phone, DateTime date, String hour, String terrain) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservation.php'),
        body: {
          'name': name,
          'phone': phone,
          'date': date.toIso8601String().substring(0, 10),
          'hour': hour,
          'terrain': terrain,
        },
      );
      return response.statusCode == 200 && json.decode(response.body)['success'];
    } catch (e) {
      return false;
    }
  }
}
