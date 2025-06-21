import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateAppointmentPage extends StatefulWidget {
  @override
  _CreateAppointmentPageState createState() => _CreateAppointmentPageState();
}

class _CreateAppointmentPageState extends State<CreateAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serviceController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;
  bool _isLoadingCustomers = true;

  List<Map<String, dynamic>> _customers = [];
  int? _selectedCustomerId;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/customers'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _customers =
              data.map<Map<String, dynamic>>((item) {
                return {'id': item['id'], 'name': item['name']};
              }).toList();
          _isLoadingCustomers = false;
        });
      } else {
        throw Exception('Failed to load customers');
      }
    } catch (e) {
      print('❌ Error loading customers: $e');
      setState(() => _isLoadingCustomers = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load customers. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate() ||
        _selectedCustomerId == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final appointmentDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final appointmentTime = _selectedTime!.format(context);

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/appointments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_id': _selectedCustomerId,
          'appointment_date': appointmentDate,
          'appointment_time': appointmentTime,
          'service': _serviceController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedCustomerId = null;
          _selectedDate = null;
          _selectedTime = null;
        });
      } else {
        throw Exception('Failed to create appointment');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create appointment. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      print('Error: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.white,
              onSurface:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
            ),
            dialogBackgroundColor:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.white,
              onSurface:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
            ),
            dialogBackgroundColor:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book Appointment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body:
          _isLoadingCustomers
              ? Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 60,
                            color: Colors.deepPurple.shade700,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'New Appointment',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : Colors.deepPurple.shade800,
                            ),
                          ),
                          SizedBox(height: 24),
                          // Customer Dropdown
                          DropdownButtonFormField<int>(
                            value: _selectedCustomerId,
                            decoration: InputDecoration(
                              labelText: 'Select Customer',
                              labelStyle: TextStyle(
                                color:
                                    isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor:
                                  isDarkMode
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade50,
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.deepPurple,
                              ),
                            ),
                            dropdownColor:
                                isDarkMode
                                    ? Colors.grey.shade900
                                    : Colors.white,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            items:
                                _customers.map((customer) {
                                  return DropdownMenuItem<int>(
                                    value: customer['id'],
                                    child: Text(
                                      customer['name'],
                                      style: TextStyle(
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedCustomerId = value);
                            },
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Please select a customer'
                                        : null,
                          ),
                          SizedBox(height: 20),
                          // Service Field
                          TextFormField(
                            controller: _serviceController,
                            decoration: InputDecoration(
                              labelText: 'Service',
                              labelStyle: TextStyle(
                                color:
                                    isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor:
                                  isDarkMode
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade50,
                              prefixIcon: Icon(
                                Icons.design_services,
                                color: Colors.deepPurple,
                              ),
                            ),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Please enter service'
                                        : null,
                          ),
                          SizedBox(height: 20),
                          // Date Picker
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      isDarkMode
                                          ? Colors.grey.shade600
                                          : Colors.grey.shade400,
                                ),
                                color:
                                    isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade50,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.deepPurple,
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    _selectedDate == null
                                        ? 'Select Appointment Date'
                                        : DateFormat.yMMMMd().format(
                                          _selectedDate!,
                                        ),
                                    style: TextStyle(
                                      color:
                                          _selectedDate == null
                                              ? isDarkMode
                                                  ? Colors.white70
                                                  : Colors.black54
                                              : isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(Icons.edit, color: Colors.deepPurple),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Time Picker
                          InkWell(
                            onTap: _pickTime,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      isDarkMode
                                          ? Colors.grey.shade600
                                          : Colors.grey.shade400,
                                ),
                                color:
                                    isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade50,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.deepPurple,
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    _selectedTime == null
                                        ? 'Select Appointment Time'
                                        : _selectedTime!.format(context),
                                    style: TextStyle(
                                      color:
                                          _selectedTime == null
                                              ? isDarkMode
                                                  ? Colors.white70
                                                  : Colors.black54
                                              : isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(Icons.edit, color: Colors.deepPurple),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 32),
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  _isSubmitting ? null : _submitAppointment,
                              child:
                                  _isSubmitting
                                      ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : Text(
                                        'BOOK APPOINTMENT',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
