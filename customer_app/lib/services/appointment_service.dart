import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment.dart';

class AppointmentService {
  static const String baseUrl =
      'http://127.0.0.1:8000/api'; // Adjust if using Android/iOS emulator

  static Future<List<Appointment>> getAppointments() async {
    final response = await http.get(Uri.parse('$baseUrl/appointments'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  static Future<void> createAppointment(
    Map<String, dynamic> appointment,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(appointment),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create appointment');
    }
  }

  static Future<void> deleteAppointment(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/appointments/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete appointment');
    }
  }

  static Future<void> updateAppointment(
    int id,
    Map<String, dynamic> appointment,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/appointments/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(appointment),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update appointment');
    }
  }

  static Future<List<Appointment>> getAppointmentsByCustomer(
    int customerId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/customers/$customerId/appointments'),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load customer appointments');
    }
  }
}
