import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../screen/general/profile_screen.dart';
import '../../service/homeService.dart';
import '../../viewmodels/request/paginationRequest.dart';
import '../../viewmodels/response/homeResponse.dart';
import '../booking/booking_screen.dart';
import '../booking/worker_list_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;
  final HomeService _homeService = HomeService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = true;
  CustomerHomeResponse? _homeData;

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
        _homeData = await _homeService.getCustomerHome(token, PaginationRequest(pageSize: 10));
      }
    } catch (e) {
      debugPrint('Error loading customer home: $e');
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
        _buildHeader(_homeData!.name, 'Home Service', _homeData!.avatar),
        const SizedBox(height: 24),
        _buildSearchBar(),
        const SizedBox(height: 32),
        const Text('Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: _homeData!.categories.items.length,
          itemBuilder: (context, index) {
            final cat = _homeData!.categories.items[index];
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WorkerListScreen(categoryName: cat.categoryName))),
              child: _buildCategoryCard(cat.categoryName),
            );
          },
        ),
        const SizedBox(height: 32),
        _buildPromoCard(),
      ],
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

  Widget _buildCategoryCard(String name) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.cleaning_services, color: Colors.blue, size: 28),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: const TextField(decoration: InputDecoration(hintText: 'What service do you need?', border: InputBorder.none, icon: Icon(Icons.search, color: Colors.blueAccent))),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue]), borderRadius: BorderRadius.circular(16)),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Deep Home Cleaning', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text('Get 20% off your first booking.', style: TextStyle(color: Colors.white70)),
      ]),
    );
  }

  Widget _buildError() {
    return const Center(child: Text('Failed to load data. Please pull to refresh.'));
  }
}
