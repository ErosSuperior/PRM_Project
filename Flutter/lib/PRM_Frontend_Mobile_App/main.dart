import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'screen/authorization/login.dart';
import 'screen/general/home.dart';
import 'screen/general/customer_home.dart';
import 'screen/general/admin_home.dart';
import 'screen/general/worker_home.dart';
import 'screen/booking/booking_screen.dart';
import 'screen/authorization/register_screen.dart';
import 'screen/dashboard/customer_dashboard.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');

    if (token == null || JwtDecoder.isExpired(token)) {
      return const LoginScreen();
    }

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String role = (decodedToken['role'] ?? decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'])?.toString().toLowerCase() ?? 'customer';

      if (role == 'admin') return const AdminHomeScreen();
      if (role == 'worker') return const WorkerHomeScreen();
      return const CustomerHomeScreen();
    } catch (e) {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Service App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data ?? const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/customer_dashboard': (context) => const CustomerDashboard(),
        '/home': (context) => const HomeScreen(),
        '/bookings': (context) => const BookingScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
// admin@homeservice.com
// worker@homeservice.com
// customer@homeservice.com