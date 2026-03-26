import 'package:flutter/material.dart';
import '../../service/auth_helper.dart';
import '../../service/booking_api_service.dart';
import '../../viewmodels/request/paginationRequest.dart';
import '../../viewmodels/response/bookingResponse.dart';

class AcceptBookingScreen extends StatefulWidget {
  const AcceptBookingScreen({Key? key}) : super(key: key);

  @override
  State<AcceptBookingScreen> createState() => _AcceptBookingScreenState();
}

class _AcceptBookingScreenState extends State<AcceptBookingScreen> {
  final BookingApiService _apiService = BookingApiService();
  final AuthHelper _authHelper = AuthHelper.instance;

  List<BookingResponse> _availableBookings = [];
  bool _isLoading = true;
  bool _isCheckingAvailability = true;
  bool _hasActiveService = false;
  int _currentPage = 1;
  bool _hasNextPage = false;
  final int _pageSize = 10;
  String? _accessToken;
  int? _currentWorkerId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _accessToken = await _authHelper.getAccessToken();
      _currentWorkerId = await _authHelper.getCurrentWorkerId(); 
      
      // Log the worker ID
      if (_currentWorkerId != null) {
        debugPrint('Current Worker ID: $_currentWorkerId');
      } else {
        debugPrint('no id found');
      }
      
      // Execute both checks
      await _checkWorkerAvailability();
      await _loadBookings();
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isCheckingAvailability = false;
        });
      }
    }
  }

  Future<void> _checkWorkerAvailability() async {
    // Ensure we reset state even if ID is missing
    if (_currentWorkerId == null || _accessToken == null) {
      if (mounted) setState(() => _isCheckingAvailability = false);
      return;
    }
    
    if (mounted) setState(() => _isCheckingAvailability = true);
    
    try {
      final response = await _apiService.getBookingsByWorkerId(
        _currentWorkerId!,
        PaginationRequest(pageNumber: 1, pageSize: 50),
        accessToken: _accessToken,
      );
      
      final activeBooking = response.items.any((b) => 
        (b.status?.toLowerCase() != 'completed') && (b.status?.toLowerCase() != 'cancelled')
      );
      
      if (mounted) {
        setState(() {
          _hasActiveService = activeBooking;
          _isCheckingAvailability = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking availability: $e');
      if (mounted) setState(() => _isCheckingAvailability = false);
    }
  }

  Future<void> _loadBookings({int page = 1}) async {
    if (mounted) {
      setState(() {
        if (page == 1) _isLoading = true;
        _currentPage = page;
      });
    }

    try {
      final request = PaginationRequest(pageNumber: _currentPage, pageSize: _pageSize);
      final response = await _apiService.getAllBookings(request, accessToken: _accessToken);

      if (mounted) {
        setState(() {
          final newItems = response.items.where((b) => 
            (b.status?.toLowerCase() == 'pending') && (b.workerId == 6)
          ).toList();
          
          if (page == 1) {
            _availableBookings = newItems;
          } else {
            _availableBookings.addAll(newItems);
          }
          _hasNextPage = response.currentPage < response.totalPages;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading bookings: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading requests: $e')),
        );
      }
    }
  }

  Future<void> _acceptBooking(BookingResponse booking) async {
    // 1. Validation checks
    if (_hasActiveService) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must complete your active service before accepting a new one.'),
            backgroundColor: Colors.orange
        ),
      );
      return;
    }

    if (_currentWorkerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Worker ID not found. Please log in again.'))
      );
      return;
    }

    // 2. Show loading indicator (Optional but recommended)
    setState(() => _isLoading = true);

    try {
      // 3. Call the specific assignWorker API endpoint we created
      await _apiService.assignWorker(
          booking.bookingId,
          _currentWorkerId!,
          accessToken: _accessToken
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Booking accepted successfully!'),
              backgroundColor: Colors.green
          ),
        );

        // 4. REFRESH SCREEN: Re-run initialization to check new availability
        // and reload the list from the server
        await _initialize();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  String _getCategoryFromPackageName(String? packageName) {
    if (packageName == null) return 'Service';
    final parts = packageName.split('-');
    if (parts.length > 1) return parts.sublist(1).join('-');
    return 'Service';
  }

  String _getPackageLabel(String? packageName) {
    if (packageName == null) return 'General';
    final parts = packageName.split('-');
    if (parts.isNotEmpty) {
      final id = parts[0];
      switch (id) {
        case '1': return '1 - 50k';
        case '2': return '2 - 100k';
        case '3': return '3 - 200k';
        case '4': return '4 - 500k';
        case '5': return '5 - Deal';
        default: return id;
      }
    }
    return 'General';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Available Requests'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: (_isLoading || _isCheckingAvailability)
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _checkWorkerAvailability();
                await _loadBookings();
              },
              child: Column(
                children: [
                  if (_hasActiveService)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: Colors.orange[100],
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'You have an active service. Complete it to accept more.',
                              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: _availableBookings.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 100),
                              Center(child: Text('No pending requests available.')),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _availableBookings.length + (_hasNextPage ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _availableBookings.length) {
                                return Center(
                                  child: TextButton(
                                    onPressed: () => _loadBookings(page: _currentPage + 1),
                                    child: const Text('Load More'),
                                  ),
                                );
                              }

                              final booking = _availableBookings[index];
                              final category = _getCategoryFromPackageName(booking.packageName);
                              final package = _getPackageLabel(booking.packageName);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            category,
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.blueAccent.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              package,
                                              style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(Icons.person, booking.customerName ?? 'Unknown Customer'),
                                      const SizedBox(height: 8),
                                      _buildInfoRow(Icons.calendar_today, '${booking.bookingDate} at ${booking.startTime.substring(0, 5)}'),
                                      const SizedBox(height: 8),
                                      _buildInfoRow(Icons.location_on, booking.address),
                                      const SizedBox(height: 8),
                                      _buildInfoRow(Icons.payments, booking.totalPrice != null ? '${booking.totalPrice!.toStringAsFixed(0)} VND' : 'Deal (Negotiable)'),
                                      if (booking.note != null && booking.note!.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        const Text('Note:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        Text(booking.note!, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.black54)),
                                      ],
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _availableBookings.removeAt(index);
                                                });
                                              },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                side: const BorderSide(color: Colors.red),
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                              ),
                                              child: const Text('Decline'),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _hasActiveService ? null : () => _acceptBooking(booking),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _hasActiveService ? Colors.grey : Colors.green,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                              ),
                                              child: const Text('Accept'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 14))),
      ],
    );
  }
}
