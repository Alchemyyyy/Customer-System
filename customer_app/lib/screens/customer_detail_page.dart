import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'edit_customer_page.dart'; // Make sure this import exists

class CustomerDetailPage extends StatefulWidget {
  final int customerId;

  const CustomerDetailPage({Key? key, required this.customerId})
    : super(key: key);

  @override
  _CustomerDetailPageState createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  Map<String, dynamic>? customerData;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchCustomerDetails();
  }

  Future<void> fetchCustomerDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/customers/${widget.customerId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          customerData = json.decode(response.body);
          isLoading = false;
          isError = false;
        });
      } else {
        throw Exception('Failed to fetch customer details');
      }
    } catch (e) {
      print('Error fetching customer details: $e');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  Future<void> deleteCustomer() async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/customers/${widget.customerId}'),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        throw Exception('Failed to delete customer');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete customer'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      print('Error: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    await fetchCustomerDetails();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final secondaryTextColor =
        isDarkMode ? Colors.white70 : Colors.grey.shade600;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Customer Details',
            style: TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade700,
                  Colors.deepPurple.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      );
    }

    if (isError || customerData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Customer Details',
            style: TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade700,
                  Colors.deepPurple.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Failed to load customer details',
                style: TextStyle(fontSize: 18, color: textColor),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                child: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final customer = customerData!;
    final orders = customer['orders'] as List<dynamic>;
    final appointments = customer['appointments'] as List<dynamic>;
    final events = customer['event_registrations'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          customer['name'] ?? 'Customer Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text(
                          customer['name'][0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.deepPurple.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.person,
                      'Name',
                      customer['name'],
                      secondaryTextColor,
                      textColor,
                    ),
                    _buildDetailRow(
                      Icons.email,
                      'Email',
                      customer['email'],
                      secondaryTextColor,
                      textColor,
                    ),
                    if (customer['phone'] != null)
                      _buildDetailRow(
                        Icons.phone,
                        'Phone',
                        customer['phone'],
                        secondaryTextColor,
                        textColor,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            _buildSectionCard(
              context,
              'Orders',
              orders,
              Icons.shopping_bag,
              (order) => '- ${order['product']} (Qty: ${order['quantity']})',
              cardColor,
              textColor,
              secondaryTextColor,
            ),
            SizedBox(height: 16),
            _buildSectionCard(
              context,
              'Appointments',
              appointments,
              Icons.calendar_today,
              (appointment) {
                final date = DateTime.parse(appointment['appointment_date']);
                return '- ${DateFormat.yMMMd().format(date)} at ${appointment['appointment_time']}';
              },
              cardColor,
              textColor,
              secondaryTextColor,
            ),
            SizedBox(height: 16),
            _buildSectionCard(
              context,
              'Events',
              events,
              Icons.event,
              (event) =>
                  '- ${event['event_name']} on ${DateFormat.yMMMd().format(DateTime.parse(event['event_date']))}',
              cardColor,
              textColor,
              secondaryTextColor,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Edit functionality - preserved and enhanced
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => EditCustomerPage(
                                customerId: widget.customerId,
                                currentName: customer['name'],
                                currentEmail: customer['email'],
                                currentPhone: customer['phone'] ?? '',
                              ),
                        ),
                      );

                      if (updated == true) {
                        await fetchCustomerDetails(); // Refresh data after edit
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Customer updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.edit, size: 20, color: Colors.white),
                    label: Text('EDIT', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text(
                                'Confirm Delete',
                                style: TextStyle(color: textColor),
                              ),
                              content: Text(
                                'Are you sure you want to delete this customer? This action cannot be undone.',
                                style: TextStyle(color: textColor),
                              ),
                              backgroundColor: cardColor,
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'CANCEL',
                                    style: TextStyle(color: Colors.deepPurple),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    deleteCustomer();
                                  },
                                  child: Text(
                                    'DELETE',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                    icon: Icon(Icons.delete, size: 20, color: Colors.white),
                    label: Text(
                      'DELETE',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String? value,
    Color secondaryTextColor,
    Color primaryTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurple, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: secondaryTextColor),
                ),
                SizedBox(height: 2),
                Text(
                  value ?? 'Not provided',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    List<dynamic> items,
    IconData icon,
    String Function(dynamic) itemBuilder,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Card(
      elevation: 4,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            Divider(height: 24, thickness: 1, color: secondaryTextColor),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'No $title found',
                  style: TextStyle(color: secondaryTextColor),
                ),
              ),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  itemBuilder(item),
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
