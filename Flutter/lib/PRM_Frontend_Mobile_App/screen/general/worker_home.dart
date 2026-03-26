import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../screen/general/profile_screen.dart';
import '../../service/homeService.dart';
import '../../viewmodels/response/homeResponse.dart';
import '../booking/booking_screen.dart';
import '../worker/accept_booking_screen.dart';
import '../worker/worker_booking_detail_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({Key? key}) : super(key: key);

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  int _selectedIndex = 0;
  final HomeService _homeService = HomeService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = true;
  WorkerHomeResponse? _homeData;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      String? token = await _secureStorage.read(key: 'access_token');
      if (token != null) {
        final data = await _homeService.getWorkerHome(token);
        if (mounted) {
          setState(() {
            _homeData = data;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading worker home: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BookingScreen())).then((_) {
        if (mounted) setState(() => _selectedIndex = 0);
      });
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())).then((_) {
        if (mounted) setState(() => _selectedIndex = 0);
      });
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
        _buildHeader(_homeData!.name, 'Worker Dashboard', _homeData!.avatar),
        const SizedBox(height: 24),
        
        // New: Accept Booking Button
        _buildAcceptBookingAction(),
        
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildStatCard('Rating', _homeData!.averageRating.toStringAsFixed(1), Icons.star, Colors.amber)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Experience', '${_homeData!.experienceYears}y', Icons.work, Colors.blue)),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _homeData!.isAvailable ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _homeData!.isAvailable ? Colors.green : Colors.red),
          ),
          child: Row(children: [
            Icon(_homeData!.isAvailable ? Icons.check_circle : Icons.do_not_disturb_on, color: _homeData!.isAvailable ? Colors.green : Colors.red),
            const SizedBox(width: 12),
            Text(_homeData!.isAvailable ? 'Available' : 'Busy', style: TextStyle(fontWeight: FontWeight.bold, color: _homeData!.isAvailable ? Colors.green[800] : Colors.red[800])),
          ]),
        ),
        const SizedBox(height: 32),
        const Text('Upcoming Bookings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._homeData!.upcomingBookings.map((b) => _buildBookingSummaryCard(b)).toList(),
      ],
    );
  }

  Widget _buildAcceptBookingAction() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.blue]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AcceptBookingScreen()),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.assignment_turned_in, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Accept New Services', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('View pending booking requests', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String subtitle, String? avatar) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome, $name! 👋', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Text(subtitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ]),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ]),
    );
  }

  Widget _buildBookingSummaryCard(BookingSummary booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkerBookingDetailScreen(bookingId: booking.bookingId),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Icon(Icons.calendar_month, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.packageName ?? 'Booking', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year} at ${booking.startTime ?? 'N/A'}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  )
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return const Center(child: Text('Failed to load data. Please pull to refresh.'));
  }
}
