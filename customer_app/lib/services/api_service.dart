import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://localhost:8000/api'; // ← Android emulator
  // Use your real IP for physical devices or iOS simulator

  static Future<bool> createCustomer(
    String name,
    String email,
    String phone,
  ) async {
    final url = Uri.parse('$baseUrl/customers');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'phone': phone}),
    );

    return response.statusCode == 201;
  }

  static Future<bool> createOrder(
    String productName,
    int quantity,
    double price,
    int customerId,
  ) async {
    final url = Uri.parse('$baseUrl/orders');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'product_name': productName,
        'quantity': quantity,
        'price': price,
        'customer_id': customerId,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<List<dynamic>> getCustomers() async {
    final url = Uri.parse('$baseUrl/customers');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load customers');
    }
  }

  static Future<bool> createAppointment({
    required int customerId,
    required String appointmentDate,
    required String appointmentTime,
    required String service,
  }) async {
    final url = Uri.parse('$baseUrl/appointments');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customer_id': customerId,
        'appointment_date': appointmentDate,
        'appointment_time': appointmentTime,
        'service': service,
      }),
    );

    print('Status Code: ${response.statusCode}');
    print(
      'Response Body: ${response.body}',
    ); // 👈 this shows Laravel error message

    return response.statusCode == 201;
  }

  static Future<bool> createEventRegistration({
    required int customerId,
    required String eventName,
    required String eventDate,
  }) async {
    final url = Uri.parse('$baseUrl/event-registrations');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customer_id': customerId,
        'event_name': eventName,
        'event_date': eventDate,
      }),
    );

    return response.statusCode == 201;
  }
}
