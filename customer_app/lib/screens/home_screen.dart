import 'package:flutter/material.dart';
import 'create_customer_page.dart';
import 'create_order_page.dart';
import 'create_appointment_page.dart';
import 'create_event_registration_page.dart';
import 'customer_list_page.dart';
import 'login_page.dart';

class HomeScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  const HomeScreen({
    Key? key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer System'),
        actions: [
          // Dark mode toggle
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: onToggleDarkMode,
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text('Logout?'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close dialog
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => LoginPage(
                                      isDarkMode: isDarkMode,
                                      onToggleDarkMode: onToggleDarkMode,
                                    ),
                              ),
                            );
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              _buildMenuButton(
                context,
                icon: Icons.person_add,
                label: 'Register New Customer',
                page: CreateCustomerPage(),
              ),
              _buildMenuButton(
                context,
                icon: Icons.shopping_cart,
                label: 'Create Order',
                page: CreateOrderPage(),
              ),
              _buildMenuButton(
                context,
                icon: Icons.calendar_today,
                label: 'Booking Appointment',
                page: CreateAppointmentPage(),
              ),
              _buildMenuButton(
                context,
                icon: Icons.event_available,
                label: 'Register for Event',
                page: CreateEventRegistrationPage(),
              ),
              _buildMenuButton(
                context,
                icon: Icons.people,
                label: 'View Customers',
                page: CustomerListPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget page,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: Icon(icon),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(label),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          },
        ),
      ),
    );
  }
}
