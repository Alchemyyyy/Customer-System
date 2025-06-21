import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateOrderPage extends StatefulWidget {
  @override
  _CreateOrderPageState createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  String _product = '';
  int _quantity = 1;
  double _price = 0.0;
  int? _selectedCustomerId;

  List<dynamic> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  void _loadCustomers() async {
    try {
      List<dynamic> customers = await ApiService.getCustomers();
      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading customers: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedCustomerId != null) {
      _formKey.currentState!.save();

      bool success = await ApiService.createOrder(
        _product,
        _quantity,
        _price,
        _selectedCustomerId!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Order created successfully!' : 'Failed to create order',
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Order'),
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
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_shopping_cart,
                              size: 60,
                              color: Colors.deepPurple.shade700,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Order Details',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDarkMode
                                        ? Colors.white
                                        : Colors.deepPurple.shade800,
                              ),
                            ),
                            SizedBox(height: 30),
                            // Customer dropdown
                            DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                labelText: 'Select Customer',
                                labelStyle: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.deepPurple,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor:
                                    isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade50,
                              ),
                              dropdownColor:
                                  isDarkMode
                                      ? Colors.grey.shade900
                                      : Colors.white,
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
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
                              onChanged: (value) {
                                setState(() {
                                  _selectedCustomerId = value;
                                });
                              },
                              validator:
                                  (value) =>
                                      value == null
                                          ? 'Please select a customer'
                                          : null,
                            ),
                            SizedBox(height: 20),
                            // Product name field
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Product Name',
                                labelStyle: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                ),
                                prefixIcon: Icon(
                                  Icons.shopping_bag,
                                  color: Colors.deepPurple,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor:
                                    isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade50,
                              ),
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                              onSaved: (value) => _product = value!,
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? 'Please enter product name'
                                          : null,
                            ),
                            SizedBox(height: 20),
                            // Quantity field
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                labelStyle: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                ),
                                prefixIcon: Icon(
                                  Icons.format_list_numbered,
                                  color: Colors.deepPurple,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor:
                                    isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade50,
                              ),
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                              keyboardType: TextInputType.number,
                              initialValue: '1',
                              onSaved: (value) => _quantity = int.parse(value!),
                            ),
                            SizedBox(height: 20),
                            // Price field
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Price',
                                labelStyle: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                ),
                                prefixIcon: Icon(
                                  Icons.attach_money,
                                  color: Colors.deepPurple,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor:
                                    isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade50,
                              ),
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              initialValue: '0.0',
                              onSaved: (value) => _price = double.parse(value!),
                            ),
                            SizedBox(height: 30),
                            // Submit button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _submit,
                                child: Text(
                                  'CREATE ORDER',
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
              ),
    );
  }
}
