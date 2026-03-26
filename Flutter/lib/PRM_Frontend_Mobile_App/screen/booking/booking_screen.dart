import 'package:flutter/material.dart';
import '../../service/auth_helper.dart';
import '../../service/booking_api_service.dart';
import '../../service/rating_api_service.dart';
import '../../viewmodels/request/paginationRequest.dart';
import '../../viewmodels/request/ratingRequest.dart';
import '../../viewmodels/response/bookingResponse.dart';
import '../../widgets/rating_bar.dart';
import '../../screen/rating/rating_dialog.dart';
import 'create_booking_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingApiService _apiService = BookingApiService();
  final RatingApiService _ratingApiService = RatingApiService();
  final AuthHelper _authHelper = AuthHelper.instance;

  String? _accessToken;
  int? _currentCustomerId;

  List<BookingResponse> _bookings = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  int _currentPage = 1;
  bool _hasNextPage = false;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _accessToken = await _authHelper.getAccessToken();
    _currentCustomerId = await _authHelper.getCurrentCustomerId();
    _loadBookings();
  }

  Future<void> _loadBookings({int page = 1}) async {
    if (_currentCustomerId == null) return;

    setState(() {
      if (page == 1) _isLoading = true;
      _currentPage = page;
    });

    try {
      final paginationRequest = PaginationRequest(pageNumber: _currentPage, pageSize: _pageSize);
      final response = await _apiService.getBookingsByCustomerId(
          _currentCustomerId!,
          paginationRequest,
          accessToken: _accessToken
      );

      setState(() {
        if (page == 1) {
          _bookings = response.items;
        } else {
          _bookings.addAll(response.items);
        }
        _hasNextPage = response.currentPage < response.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bookings: $e')),
        );
      }
    }
  }

  List<BookingResponse> get _filteredBookings {
    if (_selectedFilter == 'all') return _bookings;
    return _bookings.where((b) => (b.status ?? '').toLowerCase() == _selectedFilter.toLowerCase()).toList();
  }

  void _openNewBookingForm() async {
    final bookingCreated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateBookingScreen(),
      ),
    );

    if (bookingCreated == true) {
      _loadBookings();
    }
  }

  Future<void> _openRatingDialog(BookingResponse booking) async {
    // Note: RatingDialog logic might need adjustment for flattened model
  }

  Future<void> _updateBookingStatus(BookingResponse booking, String newStatus) async {
    try {
      await _apiService.updateBookingStatus(booking.bookingId, newStatus, accessToken: _accessToken);
      _loadBookings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking status updated to $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating booking: $e')),
        );
      }
    }
  }

  Future<void> _deleteBooking(BookingResponse booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text('Are you sure you want to delete this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteBooking(booking.bookingId, accessToken: _accessToken);
        _loadBookings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting booking: $e')),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryFromPackageName(String? packageName) {
    if (packageName == null) return 'Service';
    final parts = packageName.split('-');
    if (parts.length > 1) {
      return parts.sublist(1).join('-'); 
    }
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
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedFilter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'confirmed', child: Text('Confirmed')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
              const PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredBookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No bookings yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredBookings.length + (_hasNextPage ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == _filteredBookings.length) {
                        return Center(
                          child: TextButton(
                            onPressed: () => _loadBookings(page: _currentPage + 1),
                            child: const Text('Load More'),
                          ),
                        );
                      }

                      final booking = _filteredBookings[index];
                      final categoryName = _getCategoryFromPackageName(booking.packageName);
                      final packageLabel = _getPackageLabel(booking.packageName);

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      categoryName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(booking.status ?? 'pending').withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      (booking.status ?? 'PENDING').toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _getStatusColor(booking.status ?? 'pending'),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  packageLabel,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${booking.bookingDate} ${booking.startTime.substring(0, 5)}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(Icons.location_on, size: 18, color: Colors.black54),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      booking.address,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (booking.note != null && booking.note!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  booking.note!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Rating: ',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                      const RatingBar(
                                        rating: null, 
                                        onRatingSelected: null,
                                        iconSize: 20,
                                      ),
                                      TextButton(
                                        onPressed: () => _openRatingDialog(booking),
                                        child: const Text('Rate now'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if ((booking.status ?? '').toLowerCase() == 'pending')
                                    TextButton(
                                      onPressed: () => _updateBookingStatus(booking, 'confirmed'),
                                      child: const Text('Confirm', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                                    ),
                                  if ((booking.status ?? '').toLowerCase() == 'confirmed')
                                    TextButton(
                                      onPressed: () => _updateBookingStatus(booking, 'completed'),
                                      child: const Text('Complete', style: TextStyle(color: Color(0xFF5C6BC0), fontWeight: FontWeight.bold)),
                                    ),
                                  if ((booking.status ?? '').toLowerCase() != 'cancelled' && (booking.status ?? '').toLowerCase() != 'completed')
                                    TextButton(
                                      onPressed: () => _updateBookingStatus(booking, 'cancelled'),
                                      child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _deleteBooking(booking),
                                    tooltip: 'Delete',
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewBookingForm,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
