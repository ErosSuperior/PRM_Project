import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../screen/general/profile_screen.dart';
import '../../service/homeService.dart';
import '../../viewmodels/response/homeResponse.dart';
import '../booking/booking_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  final HomeService _homeService = HomeService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = true;
  AdminHomeResponse? _homeData;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() => _isLoading = true);
    try {
      String? token = await _secureStorage.read(key: 'access_token');
      if (token != null) {
        _homeData = await _homeService.getAdminHome(token);
      }
    } catch (e) {
      debugPrint('Error loading admin home: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BookingScreen())).then((_) => setState(() => _selectedIndex = 0));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())).then((_) => setState(() => _selectedIndex = 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadHomeData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: _homeData == null ? _buildError() : _buildContent(),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(_homeData!.name, 'Admin Dashboard', _homeData!.avatar),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4, // Increased height relative to width
          children: [
            _buildStatCard('Users', _homeData!.totalUsers.toString(), Icons.people, Colors.blue),
            _buildStatCard('Bookings', _homeData!.totalBookings.toString(), Icons.book, Colors.orange),
            _buildStatCard('Pending', _homeData!.pendingBookings.toString(), Icons.pending_actions, Colors.amber),
            _buildStatCard('Revenue', '\$${_homeData!.totalRevenue.toStringAsFixed(0)}', Icons.attach_money, Colors.green),
          ],
        ),
        const SizedBox(height: 32),
        const Text('Recent Bookings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._homeData!.recentBookings.map((b) => _buildBookingSummaryCard(b)).toList(),
      ],
    );
  }

  Widget _buildHeader(String name, String subtitle, String? avatar) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Welcome, $name! 👋', style: TextStyle(fontSize: 16, color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
            Text(subtitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 24,
          backgroundImage: (avatar != null && avatar.isNotEmpty) ? NetworkImage(avatar) : null,
          child: (avatar == null || avatar.isEmpty) ? const Icon(Icons.person) : null,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _buildBookingSummaryCard(BookingSummary booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.calendar_month, color: Colors.blue),
        const SizedBox(width: 16),
        Expanded(child: Text(booking.packageName ?? 'Booking', style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        Text('\$${booking.price?.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
      ]),
    );
  }

  Widget _buildError() {
    return const Center(child: Text('Failed to load data. Please pull to refresh.'));
  }
}
