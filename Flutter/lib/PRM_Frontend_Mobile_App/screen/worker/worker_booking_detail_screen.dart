import 'package:flutter/material.dart';
import '../../service/auth_helper.dart';
import '../../service/booking_api_service.dart';
import '../../viewmodels/response/bookingResponse.dart';

class WorkerBookingDetailScreen extends StatefulWidget {
  final int bookingId;

  const WorkerBookingDetailScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  State<WorkerBookingDetailScreen> createState() => _WorkerBookingDetailScreenState();
}

class _WorkerBookingDetailScreenState extends State<WorkerBookingDetailScreen> {
  final BookingApiService _apiService = BookingApiService();
  final AuthHelper _authHelper = AuthHelper.instance;
  
  BookingResponse? _booking;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    setState(() => _isLoading = true);
    try {
      final token = await _authHelper.getAccessToken();
      final data = await _apiService.getBookingById(widget.bookingId, accessToken: token);
      setState(() {
        _booking = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading booking: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      final token = await _authHelper.getAccessToken();
      await _apiService.updateBookingStatus(widget.bookingId, newStatus, accessToken: token);
      _loadBookingDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking marked as $newStatus'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _booking == null 
          ? const Center(child: Text('Booking not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBanner(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Service Info'),
                  _buildInfoCard([
                    _buildInfoRow(Icons.work, 'Service', _getCategory(_booking!.packageName)),
                    _buildInfoRow(Icons.layers, 'Package', _getPackage(_booking!.packageName)),
                    _buildInfoRow(Icons.payments, 'Price', _booking!.totalPrice != null ? '${_booking!.totalPrice!.toStringAsFixed(0)} VND' : 'Deal'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Schedule & Location'),
                  _buildInfoCard([
                    _buildInfoRow(Icons.calendar_today, 'Date', _booking!.bookingDate),
                    _buildInfoRow(Icons.access_time, 'Time', _booking!.startTime),
                    _buildInfoRow(Icons.location_on, 'Address', _booking!.address),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Customer Info'),
                  _buildInfoCard([
                    _buildInfoRow(Icons.person, 'Name', _booking!.customerName ?? 'N/A'),
                  ]),
                  if (_booking!.note != null && _booking!.note!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('Customer Notes'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        _booking!.note!,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  if (_booking!.status?.toLowerCase() == 'confirmed')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _updateStatus('completed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Mark as Completed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusBanner() {
    Color color = Colors.orange;
    String status = _booking!.status?.toUpperCase() ?? 'PENDING';
    
    if (status == 'COMPLETED') color = Colors.green;
    if (status == 'CANCELLED') color = Colors.red;
    if (status == 'CONFIRMED') color = Colors.blue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Center(
        child: Text(
          status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 2),
              SizedBox(
                width: MediaQuery.of(context).size.width - 120,
                child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCategory(String? packageName) {
    if (packageName == null) return 'Service';
    final parts = packageName.split('-');
    return parts.length > 1 ? parts.sublist(1).join('-') : 'Service';
  }

  String _getPackage(String? packageName) {
    if (packageName == null) return 'General';
    final id = packageName.split('-')[0];
    switch (id) {
      case '1': return '1 - 50k';
      case '2': return '2 - 100k';
      case '3': return '3 - 200k';
      case '4': return '4 - 500k';
      case '5': return '5 - Deal';
      default: return id;
    }
  }
}
