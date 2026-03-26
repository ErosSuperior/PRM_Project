import '../models/booking.dart';
import '../models/rating.dart';
import 'booking_api_service.dart';
import 'rating_api_service.dart';
import '../viewmodels/request/bookingRequest.dart';
import '../viewmodels/request/ratingRequest.dart';
import '../viewmodels/request/paginationRequest.dart';
import '../viewmodels/response/bookingResponse.dart';
import '../viewmodels/response/ratingResponse.dart';

class BookingService {
  final BookingApiService _apiService = BookingApiService();
  final RatingApiService _ratingApiService = RatingApiService();

  String? _accessToken;
  int? _currentCustomerId;

  void setAuthToken(String? token) {
    _accessToken = token;
  }

  void setCurrentCustomerId(int? customerId) {
    _currentCustomerId = customerId;
  }

  // Convert API BookingResponse to local Booking model
  Booking _bookingResponseToBooking(BookingResponse response) {
    // Parse date and time
    // Backend returns DateOnly (YYYY-MM-DD) and TimeOnly (HH:mm:ss)
    DateTime dateTime;
    try {
      final dateParts = response.bookingDate.split('-');
      final timeParts = response.startTime.split(':');
      dateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    } catch (e) {
      dateTime = DateTime.now();
    }

    double? rating;
    // Note: In flattened model, ratings info might be handled differently or missing.
    // Assuming no ratings array in flattened response based on your C# snippet.

    return Booking(
      id: response.bookingId.toString(),
      serviceName: response.packageName ?? 'Service',
      category: _getCategoryFromPackageName(response.packageName),
      dateTime: dateTime,
      address: response.address,
      notes: response.note ?? '',
      status: response.status ?? 'pending',
      rating: rating,
      createdAt: response.createdAt != null ? DateTime.parse(response.createdAt!) : DateTime.now(),
      bookingId: response.bookingId,
      customerId: response.customerId,
      workerId: response.workerId,
      packageId: response.packageId,
    );
  }

  String _getCategoryFromPackageName(String? packageName) {
    if (packageName == null) return 'General';
    final parts = packageName.split('-');
    if (parts.length > 1) return parts.sublist(1).join('-');
    return 'General';
  }

  // Convert local Booking to API CreateBookingRequest
  CreateBookingRequest _bookingToCreateRequest(Booking booking, int packageId) {
    final dateStr = '${booking.dateTime.year}-${booking.dateTime.month.toString().padLeft(2, '0')}-${booking.dateTime.day.toString().padLeft(2, '0')}';
    final timeStr = '${booking.dateTime.hour.toString().padLeft(2, '0')}:${booking.dateTime.minute.toString().padLeft(2, '0')}:00';

    return CreateBookingRequest(
      customerId: booking.customerId ?? _currentCustomerId ?? 0,
      workerId: booking.workerId,
      packageId: packageId == 0 ? '1' : packageId.toString(),
      bookingDate: dateStr,
      startTime: timeStr,
      address: booking.address,
      note: booking.notes.isNotEmpty ? booking.notes : null,
    );
  }

  // Convert API RatingResponse to local Rating model
  Rating _ratingResponseToRating(RatingResponse response) {
    return Rating(
      id: response.ratingId.toString(),
      bookingId: response.bookingId.toString(),
      rating: response.ratingScore ?? 0,
      comment: response.comment,
      createdAt: response.createdAt != null ? DateTime.parse(response.createdAt!) : DateTime.now(),
    );
  }

  // --- Booking Operations ---

  Future<String> createBooking(Booking booking, {int? packageId}) async {
    if (_currentCustomerId == null || packageId == null) {
      throw Exception('Customer ID or Package ID is missing.');
    }

    final request = _bookingToCreateRequest(booking, packageId);
    final response = await _apiService.createBooking(request, accessToken: _accessToken);
    final createdBooking = _bookingResponseToBooking(response);

    return createdBooking.id;
  }

  Future<List<Booking>> getAllBookings() async {
    if (_currentCustomerId == null) return [];

    final responses = await _apiService.getBookingsByCustomerId(
        _currentCustomerId!,
        PaginationRequest(pageNumber: 1, pageSize: 10),
        accessToken: _accessToken
    );

    return responses.items.map((r) => _bookingResponseToBooking(r)).toList();
  }

  Future<Booking?> getBooking(String id) async {
    final bookingId = int.tryParse(id);
    if (bookingId == null) return null;

    final response = await _apiService.getBookingById(bookingId, accessToken: _accessToken);
    return _bookingResponseToBooking(response);
  }

  Future<bool> updateBooking(Booking booking) async {
    if (booking.bookingId == null) return false;

    final dateStr = '${booking.dateTime.year}-${booking.dateTime.month.toString().padLeft(2, '0')}-${booking.dateTime.day.toString().padLeft(2, '0')}';
    final timeStr = '${booking.dateTime.hour.toString().padLeft(2, '0')}:${booking.dateTime.minute.toString().padLeft(2, '0')}:00';

    final request = UpdateBookingRequest(
      address: booking.address,
      note: booking.notes.isNotEmpty ? booking.notes : null,
      status: booking.status,
      bookingDate: dateStr,
      startTime: timeStr,
    );

    await _apiService.updateBooking(booking.bookingId!, request, accessToken: _accessToken);
    return true; 
  }

  Future<bool> deleteBooking(String id) async {
    final bookingId = int.tryParse(id);
    if (bookingId == null) return false;

    await _apiService.deleteBooking(bookingId, accessToken: _accessToken);
    return true; 
  }

  Future<List<Booking>> getBookingsByStatus(String status) async {
    final allBookings = await getAllBookings();
    return allBookings.where((b) => b.status == status).toList();
  }

  // --- Rating Operations ---

  Future<String> createRating(Rating rating) async {
    final bookingId = int.tryParse(rating.bookingId);

    if (bookingId == null || _currentCustomerId == null) {
      throw Exception('Invalid booking ID or missing customer ID.');
    }

    final booking = await getBooking(rating.bookingId);
    if (booking?.workerId == null) {
      throw Exception('Worker ID not found for this booking.');
    }

    final request = CreateRatingRequest(
      bookingId: bookingId,
      customerId: _currentCustomerId!,
      workerId: booking!.workerId!,
      ratingScore: rating.rating,
      comment: rating.comment,
    );

    final response = await _ratingApiService.createRating(request, accessToken: _accessToken);
    final createdRating = _ratingResponseToRating(response);

    return createdRating.id;
  }

  Future<Rating?> getRatingByBookingId(String bookingId) async {
    final id = int.tryParse(bookingId);
    if (id == null) return null;

    final response = await _ratingApiService.getRatingByBookingId(id, accessToken: _accessToken);
    if (response != null) {
      return _ratingResponseToRating(response);
    }
    return null;
  }

  Future<List<Rating>> getAllRatings() async {
    if (_currentCustomerId == null) return [];

    final responses = await _ratingApiService.getRatingsByCustomerId(_currentCustomerId!, accessToken: _accessToken);
    return responses.map((r) => _ratingResponseToRating(r)).toList();
  }

  Future<bool> updateRating(Rating rating) async {
    final ratingId = int.tryParse(rating.id);
    if (ratingId == null) return false;

    final request = UpdateRatingRequest(
      ratingScore: rating.rating,
      comment: rating.comment,
    );

    await _ratingApiService.updateRating(ratingId, request, accessToken: _accessToken);
    return true;
  }

  Future<bool> deleteRating(String id) async {
    final ratingId = int.tryParse(id);
    if (ratingId == null) return false;

    await _ratingApiService.deleteRating(ratingId, accessToken: _accessToken);
    return true;
  }


}
