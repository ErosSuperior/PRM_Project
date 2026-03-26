// lib/screen/dashboard/customer_dashboard.dart
import 'package:flutter/material.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text(
          'Welcome to HomeServiceApp!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}