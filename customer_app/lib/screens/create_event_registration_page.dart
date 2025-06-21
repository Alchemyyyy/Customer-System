import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class CreateEventRegistrationPage extends StatefulWidget {
  @override
  _CreateEventRegistrationPageState createState() =>
      _CreateEventRegistrationPageState();
}

class _CreateEventRegistrationPageState
    extends State<CreateEventRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedCustomerId;
  String _eventName = '';
  DateTime? _eventDate;

  List<dynamic> _customers = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  void _loadCustomers() async {
    try {
      final customers = await ApiService.getCustomers();
      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading customers: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load customers. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() &&
        _selectedCustomerId != null &&
        _eventDate != null) {
      setState(() => _isSubmitting = true);
      _formKey.currentState!.save();

      try {
        final dateStr = DateFormat('yyyy-MM-dd').format(_eventDate!);

        final success = await ApiService.createEventRegistration(
          customerId: _selectedCustomerId!,
          eventName: _eventName,
          eventDate: dateStr,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Event registration successful!'
                  : 'Registration failed',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        if (success) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting registration. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(Duration(days: 365)),
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
    if (picked != null) setState(() => _eventDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Event Registration',
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
          _isLoading
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
                            Icons.event,
                            size: 60,
                            color: Colors.deepPurple.shade700,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Register for Event',
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
                                _customers.map<DropdownMenuItem<int>>((
                                  customer,
                                ) {
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
                            onChanged:
                                (value) =>
                                    setState(() => _selectedCustomerId = value),
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Please select a customer'
                                        : null,
                          ),
                          SizedBox(height: 20),
                          // Event Name Field
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Event Name',
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
                                Icons.event_note,
                                color: Colors.deepPurple,
                              ),
                            ),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Please enter event name'
                                        : null,
                            onSaved: (value) => _eventName = value!,
                          ),
                          SizedBox(height: 20),
                          // Date Picker Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.calendar_today, size: 20),
                              label: Text(
                                _eventDate == null
                                    ? 'Select Event Date'
                                    : 'Event Date: ${DateFormat('MMM d, yyyy').format(_eventDate!)}',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: _pickDate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              child:
                                  _isSubmitting
                                      ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : Text(
                                        'SUBMIT REGISTRATION',
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
