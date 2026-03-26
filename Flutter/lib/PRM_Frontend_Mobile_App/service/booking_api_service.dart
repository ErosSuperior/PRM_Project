import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configuration/appsetting.dart';
import '../viewmodels/request/bookingRequest.dart';
import '../viewmodels/request/paginationRequest.dart';
import '../viewmodels/response/bookingResponse.dart';
import '../viewmodels/response/pagination_response.dart';

class BookingApiService {
  final String _baseUrl = AppSetting.apiUrl.endsWith('/') 
      ? AppSetting.apiUrl.substring(0, AppSetting.apiUrl.length - 1) 
      : AppSetting.apiUrl;

  Map<String, String> _getHeaders({String? accessToken}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  // Get all bookings (Paginated) - for Workers to browse
  Future<PaginationResponse<BookingResponse>> getAllBookings(
      PaginationRequest request, {String? accessToken}) async {
    try {
      final queryParams = 'pageNumber=${request.pageNumber}&pageSize=${request.pageSize}${request.searchTerm != null ? '&searchTerm=${request.searchTerm}' : ''}';
      final url = Uri.parse('$_baseUrl/book/Booking?$queryParams');
      
      final response = await http.get(
        url,
        headers: _getHeaders(accessToken: accessToken),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PaginationResponse.fromJson(
          data,
          (json) => BookingResponse.fromJson(json),
        );
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  // Get all bookings for a customer (Paginated)
  Future<PaginationResponse<BookingResponse>> getBookingsByCustomerId(
      int customerId, PaginationRequest request, {String? accessToken}) async {
    try {
      final queryParams = 'pageNumber=${request.pageNumber}&pageSize=${request.pageSize}${request.searchTerm != null ? '&searchTerm=${request.searchTerm}' : ''}';
      final url = Uri.parse('$_baseUrl/book/Booking/customer/$customerId?$queryParams');
      
      final response = await http.get(
        url,
        headers: _getHeaders(accessToken: accessToken),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PaginationResponse.fromJson(
          data,
          (json) => BookingResponse.fromJson(json),
        );
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  // Get all bookings for a worker (Paginated)
  Future<PaginationResponse<BookingResponse>> getBookingsByWorkerId(
      int workerId, PaginationRequest request, {String? accessToken}) async {
    try {
      final queryParams = 'pageNumber=${request.pageNumber}&pageSize=${request.pageSize}${request.searchTerm != null ? '&searchTerm=${request.searchTerm}' : ''}';
      final url = Uri.parse('$_baseUrl/book/Booking/worker/$workerId?$queryParams');
      
      final response = await http.get(
        url,
        headers: _getHeaders(accessToken: accessToken),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PaginationResponse.fromJson(
          data,
          (json) => BookingResponse.fromJson(json),
        );
      } else {
        throw Exception('Failed to load worker bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching worker bookings: $e');
    }
  }

  // Get booking by ID
  Future<BookingResponse> getBookingById(int bookingId, {String? accessToken}) async {
    try {
      final url = Uri.parse('$_baseUrl/book/Booking/$bookingId');
      final response = await http.get(
        url,
        headers: _getHeaders(accessToken: accessToken),
      );

      if (response.statusCode == 200) {
        return BookingResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load booking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching booking: $e');
    }
  }

  // Create a new booking
  Future<BookingResponse> createBooking(CreateBookingRequest request, {String? accessToken}) async {
    try {
      final url = Uri.parse('$_baseUrl/book/Booking');
      final response = await http.post(
        url,
        headers: _getHeaders(accessToken: accessToken),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BookingResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        final errorMessage = errorBody?['message'] ?? 'Failed to create booking: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  // Update a booking
  Future<BookingResponse> updateBooking(int bookingId, UpdateBookingRequest request, {String? accessToken}) async {
    try {
      final url = Uri.parse('$_baseUrl/book/Booking/$bookingId');
      final response = await http.put(
        url,
        headers: _getHeaders(accessToken: accessToken),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return BookingResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        final errorMessage = errorBody?['message'] ?? 'Failed to update booking: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error updating booking: $e');
    }
  }

  // Delete a booking
  Future<bool> deleteBooking(int bookingId, {String? accessToken}) async {
    try {
      final url = Uri.parse('$_baseUrl/user/Booking/$bookingId');
      final response = await http.delete(
        url,
        headers: _getHeaders(accessToken: accessToken),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete booking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting booking: $e');
    }
  }

  // Update booking status
  Future<BookingResponse> updateBookingStatus(int bookingId, String status, {String? accessToken}) async {
    final request = UpdateBookingRequest(status: status);
    return await updateBooking(bookingId, request, accessToken: accessToken);
  }

  // Assign worker to booking (Accept booking)
  Future<BookingResponse> acceptBooking(int bookingId, int workerId, {String? accessToken}) async {
    final request = UpdateBookingRequest(workerId: workerId, status: 'confirmed');
    return await updateBooking(bookingId, request, accessToken: accessToken);
  }

  // Specific call for the assign-worker endpoint
  Future<BookingResponse> assignWorker(int bookingId, int workerId, {String? accessToken}) async {
    try {
      // The URL matches your [HttpPut("{id:int}/assign-worker")] attribute
      final url = Uri.parse('$_baseUrl/book/Booking/$bookingId/assign-worker');

      // Creating the body payload matching BookingRequest.AssignWorkerRequest
      final body = jsonEncode({
        'workerId': workerId,
      });

      final response = await http.put(
        url,
        headers: _getHeaders(accessToken: accessToken),
        body: body,
      );

      if (response.statusCode == 200) {
        return BookingResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        final errorMessage = errorBody?['message'] ?? 'Failed to assign worker: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error assigning worker: $e');
    }
  }
}
